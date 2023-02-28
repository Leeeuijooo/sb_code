#!/bin/bash

CLUSTER_NAME=eks-cluster
#your eks cluster name

ACCOUNT_ID=236747833953
#your aws account ID, You can check on AWS 'IAM'

VPC_ID=vpc-0a110806635354f2d
#your VPC ID , EKS installed

EKS_REGION=ap-northeast-2
#Region with EKS installed

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json

#정책내용 다운로드

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json 1> /dev/null

#다운로드한 정책내용이 반영된 AWSLoadBalancerControllerIAMPolicy라는 정책 생성
sleep 1

eksctl create iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
#eksctl을 통해 aws-load-balancer-controller 라는 serviceaccount 생성

curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
echo 'DOWNLOAD helm_scrpits'
sleep 2
chmod +x get_helm.sh
./get_helm.sh

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=${CLUSTER_NAME} \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.repository=602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller \
    --set region=${EKS_REGION} \
    --set vpcId=${VPC_ID}

#aws-load-balancer-controller를 serviceaccount로 하는  aws-load-balancer-controller 헬름차트 설치


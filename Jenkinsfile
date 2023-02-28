pipeline {
    agent any
    // any, none, label, node, docker, dockerfile, kubernetes
    tools {
        maven 'my_maven'
    }

    environment {
        gitName = 'Leeeuijooo'
        gitEmail = 'euijoo3233@gmail.com'
        gitWebaddress = 'https://github.com/Leeeuijooo/sb_code.git'
        gitSshaddress = 'git@github.com:Leeeuijooo/sb_code.git'
        gitCredential = 'git_cre' //github credential 생성시 ID
        dockerHubRegistry = 'leeeuijoo/sbimage'
        dockerHubRegistryCredential = 'docker_cre'

    }

    stages {
        stage('Checkout Github') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: gitCredential, url: gitWebaddress]]])
            }
            post {
                failure {
                    echo 'Reppository clone failure'
                }
                success {
                    echo 'Reppository clone success'
                }
            }
        }
        stage('Maven Build') {
         steps {
            sh 'mvn clean install'
            //maven 플러그인이 미리 설치되어 있어야함
         }
            post {
                failure {
                    echo 'Maven build failure'
                }
                success {
                    echo 'Maven build success'
                }
            }
        }
        stage('Docker image Build') {
         steps {
            sh "docker build -t ${dockerHubRegistry}:${currentBuild.number} ."
            sh "docker build -t ${dockerHubRegistry}:latest ."
            //jang1023/sbimage:x 이런 식으로 빌드가 될 것이다.
            //currentBuild.number 젠킨스에서 제공하는 빌드 수
         }
            post {
                failure {
                    echo 'docker image build failure'
                    sh "docker image rm -f ${dockerHubRegistry}:${currentBuild.number}"
                    sh "docker image rm -f ${dockerHubRegistry}:latest "
                }
                success {
                    echo 'docker image build success'
                    
                }
            }
        }
        stage('docker image push') {
          steps {
            withDockerRegistry(credentialsId: dockerHubRegistryCredential, url: '') {
          // withDockerRegistry : docker pipeline 플러그인 설치시 사용가능.
          // dockerHubRegistryCredential : environment에서 선언한 docker_cre  
            sh "docker push ${dockerHubRegistry}:${currentBuild.number}"
            sh "docker push ${dockerHubRegistry}:latest"
            
          }
        }
      }
      stage('docker container deploy') {
        steps {
          sh "docker rm -f sb"
          sh "docker run -dp 5656:8085 --name sb ${dockerHubRegistry}:${currentBuild.number}"
          sh "docker image rm -f ${dockerHubRegistry}:${currentBuild.number}"
          sh "docker image rm -f ${dockerHubRegistry}:latest "
        }
        post {
          failure {
            echo 'docker constainer deploy fail'
            slackSend (color: '#FF0000', message: "FAILURE: docker container deployment '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
          }
          success {
            echo 'docker container deploy success'
            slackSend (color: '#0000FF', message: "SUCCESS: docker container deployment '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
          }
        }
      }
      stage('k8s manifest file update') {
      steps {
        git credentialsId: gitCredential,
            url: gitWebaddress,
            branch: 'main'
        
        // 이미지 태그 변경 후 메인 브랜치에 푸시
        sh "git config --global user.email ${gitEmail}"
        sh "git config --global user.name ${gitName}"
        sh "sed -i 's@${dockerHubRegistry}:.*@${dockerHubRegistry}:${currentBuild.number}@g' deploy/deploy.yml"
        sh "git add ."
        sh "git commit -m 'fix:${dockerHubRegistry} ${currentBuild.number} image versioning'"
        sh "git branch -M main"
        sh "git remote remove origin"
        sh "git remote add origin ${gitSshaddress}"
        sh "git push -u origin main"

      }
      post {
        failure {
          echo 'Container Deploy failure'
        }
        success {
          echo 'Container Deploy success'  
        }
      }
    }

    }
    
}

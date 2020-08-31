pipeline { 
    environment { 
        registry = "gcr.io/dev-range-287412/testcicd" 
        registryCredential = 'dockerhub_credentials' 
        dockerImage = '' 
    }
    agent any 
    stages { 
        stage('Git Clone') { 
            steps { 
                checkout scm
            }
        } 
        stage('Build Image') { 
            steps { 
                script { 
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                }
            } 
        }
        stage('Push Image') { 
            steps { 
                script { 
                    withDockerRegistry(credentialsId: 'gcr:dev-range-287412', url: 'https://gcr.io') {
			    dockerImage.push()
			}
                } 
            }
        } 
        stage('Run playbook') { 
            steps {
               script{
                def image = registry + ":$BUILD_NUMBER" 
                sh "sudo ansible-playbook ./ansible/playbook.yaml --extra-vars \"image=${image}\"" 
               }
            }
        } 
    }
}

def image
def env_version = "alpha"
def config = "k8sconfig"
def file_name = env_version + "_" + BUILD_NUMBER
def app_name = "demo"
def registry_url = "10.58.244.249"
def app_version = "0.0.1-SNAPSHOT"
def git_revision = "blobla"
def branch = ""
if (env_version == "alpha") {
    branch = "dev"
} else {
    branch = "master"
}

pipeline {
    agent any
    
    stages {
        stage('Fetch from github') {
            steps {
                script {
                    sh "rm -rf *"
                    def mcExisted = fileExists 'k8sjenkins'
                    if (!mcExisted) {
                        sh "mkdir k8sjenkins"
                        dir('k8sjenkins') {
                            git 'https://github.com/minhnhatbka/k8sjenkins.git'   
                        }
                    }
                    sh "rm -rf ${app_name}"
                    sh "mkdir ${app_name}"
                    dir("${app_name}") {
                        git branch: "${branch}", url: 'https://github.com/minhnhatbka/hello.git'
                    }
                    
                    sh "rm -rf k8sconfig"
                    sh "mkdir k8sconfig"
                    dir('k8sconfig') {
                        git 'https://github.com/minhnhatbka/k8sconfig.git'
                    }
                }
            }
        }
        stage('Push to minio') {
            steps {
                sh "rm -rf ${WORKSPACE}/config"
                sh "mkdir ${WORKSPACE}/config"
                dir("${WORKSPACE}/k8sconfig/${env_version}") {
                    sh "tar -cvf ${WORKSPACE}/config/${file_name}.zip *"
                }
                sh "chmod +x k8sjenkins/mc"
                sh "chmod +x k8sjenkins/configmc.sh && ./k8sjenkins/configmc.sh"
                sh "./k8sjenkins/mc cp ${WORKSPACE}/config/${file_name}.zip minio/${env_version}"
            }
        }
        stage('Maven build') {
            steps {
                dir("${app_name}") {
                    sh 'mvn -B -DskipTests clean package' 
                }
            }
        }
        stage('Docker build') {
            steps {
                dir('k8sjenkins') {
                    script {
                        sh "sed -i 's/#app_version#/${app_version}/g' Dockerfile"
                        sh "sed -i 's/#git_revision#/${git_revision}/g' Dockerfile"
                        sh "sed -i 's/#app_name#/${app_name}/g' Dockerfile"
                        sh "cp startup.sh ../${app_name}"
                        sh "cp Dockerfile ../${app_name}"
                        sh "cp mc ../${app_name}"
                        image = docker.build("${registry_url}/hello/hello:$BUILD_NUMBER", "../${app_name}")
                    }
                }
            }
        }
        stage('Push harbor') {
            steps {
                script {
                    sh "docker login ${registry_url} -u nhattm2 -p N123123a@"
                    image.push()
                }
            }
        }
        stage('Deploy k8s') {
            steps {
                dir('k8sjenkins') {
                    script {
                        sh "sed -i 's|#IMAGE#|${registry_url}/hello/hello:$BUILD_NUMBER|g' hello-deployment.yaml"
                        sh "sed -i 's/#env_name#/${env_version}/g' hello-deployment.yaml"
                        sh "sed -i 's/#app_name#/${app_name}/g' hello-deployment.yaml"
                        sh "sed -i 's/#BUILD_NUMBER#/$BUILD_NUMBER/g' hello-deployment.yaml"
                        sh "kubectl apply -f hello-deployment.yaml"
                    }
                }
            }
        }
    }
}

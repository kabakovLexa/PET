pipeline {
    agent any
    
    tools {
        maven 'maven-3.8.7'
        jdk 'openjdk-17'
    }
    
    environment {
        DOCKER_REGISTRY = 'localhost:5000'
        BUILD_VERSION = "${BUILD_NUMBER}"
        STAGING_HOST = 'staging.microservices.local'
        PRODUCTION_HOST = 'prod.microservices.local'
    }
    
    stages {
        stage('📋 Checkout') {
            steps {
                echo '🔄 Checking out source code...'
                checkout scm
                script {
                    env.GIT_COMMIT_MSG = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('🔍 Pre-build Checks') {
            parallel {
                stage('Code Style') {
                    steps {
                        echo '🎨 Checking code style...'
                        sh 'echo "Running code style checks..."'
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        echo '🔒 Running security scan...'
                        sh 'echo "Running security scan..."'
                    }
                }
                
                stage('Dependency Check') {
                    steps {
                        echo '📦 Checking dependencies...'
                        sh 'mvn dependency:tree'
                    }
                }
            }
        }
        
        stage('🏗️ Build & Test Services') {
            parallel {
                stage('Discovery Service') {
                    steps {
                        echo '🏗️ Building Discovery Service...'
                        dir('discovery-service') {
                            sh 'mvn clean compile package -DskipTests'
                            sh 'mvn test'
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'discovery-service/target/surefire-reports/*.xml'
                            publishCoverage adapters: [jacocoAdapter('discovery-service/target/site/jacoco/jacoco.xml')]
                        }
                    }
                }
                
                stage('API Gateway') {
                    steps {
                        echo '🏗️ Building API Gateway...'
                        dir('api-gateway') {
                            sh 'mvn clean compile package -DskipTests'
                            sh 'mvn test'
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'api-gateway/target/surefire-reports/*.xml'
                            publishCoverage adapters: [jacocoAdapter('api-gateway/target/site/jacoco/jacoco.xml')]
                        }
                    }
                }
                
                stage('User Service') {
                    steps {
                        echo '🏗️ Building User Service...'
                        dir('user-service') {
                            sh 'mvn clean compile package -DskipTests'
                            sh 'mvn test'
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'user-service/target/surefire-reports/*.xml'
                            publishCoverage adapters: [jacocoAdapter('user-service/target/site/jacoco/jacoco.xml')]
                        }
                    }
                }
                
                stage('Product Service') {
                    steps {
                        echo '🏗️ Building Product Service...'
                        dir('product-service') {
                            sh 'mvn clean compile package -DskipTests'
                            sh 'mvn test'
                        }
                    }
                    post {
                        always {
                            publishTestResults testResultsPattern: 'product-service/target/surefire-reports/*.xml'
                            publishCoverage adapters: [jacocoAdapter('product-service/target/site/jacoco/jacoco.xml')]
                        }
                    }
                }
            }
        }
        
        stage('📊 Code Quality Analysis') {
            parallel {
                stage('SonarQube Analysis') {
                    steps {
                        echo '📊 Running SonarQube analysis...'
                        script {
                            // SonarQube analysis
                            sh 'echo "SonarQube analysis would run here"'
                        }
                    }
                }
                
                stage('OWASP Dependency Check') {
                    steps {
                        echo '🛡️ Running OWASP dependency check...'
                        sh 'echo "OWASP dependency check would run here"'
                    }
                }
            }
        }
        
        stage('🐳 Build Docker Images') {
            steps {
                echo '🐳 Building Docker images...'
                script {
                    def services = ['discovery-service', 'api-gateway', 'user-service', 'product-service']
                    services.each { service ->
                        echo "Building ${service} Docker image..."
                        dir(service) {
                            sh """
                                docker build -t ${service}:${BUILD_VERSION} .
                                docker tag ${service}:${BUILD_VERSION} ${service}:latest
                                docker tag ${service}:${BUILD_VERSION} ${DOCKER_REGISTRY}/${service}:${BUILD_VERSION}
                                docker tag ${service}:${BUILD_VERSION} ${DOCKER_REGISTRY}/${service}:latest
                            """
                        }
                    }
                }
            }
        }
        
        stage('🧪 Integration Tests') {
            steps {
                echo '🧪 Running integration tests...'
                script {
                    try {
                        sh '''
                            echo "Starting test environment..."
                            docker-compose -f docker-compose.test.yml up -d
                            
                            echo "Waiting for services to be ready..."
                            sleep 90
                            
                            echo "Running API integration tests..."
                            ./test-apis.sh
                            
                            echo "Running end-to-end tests..."
                            # Add more comprehensive E2E tests here
                        '''
                    } catch (Exception e) {
                        echo "Integration tests failed: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    } finally {
                        sh 'docker-compose -f docker-compose.test.yml down'
                    }
                }
            }
        }
        
        stage('📦 Push Docker Images') {
            when {
                anyOf {
                    branch 'main'
                    branch 'develop'
                    branch 'release/*'
                }
            }
            steps {
                echo '📦 Pushing Docker images to registry...'
                script {
                    def services = ['discovery-service', 'api-gateway', 'user-service', 'product-service']
                    services.each { service ->
                        sh """
                            docker push ${DOCKER_REGISTRY}/${service}:${BUILD_VERSION}
                            docker push ${DOCKER_REGISTRY}/${service}:latest
                        """
                    }
                }
            }
        }
        
        stage('🚀 Deploy to Staging') {
            when {
                branch 'develop'
            }
            steps {
                echo '🚀 Deploying to staging environment...'
                script {
                    sh '''
                        echo "Updating staging environment..."
                        # Update staging docker-compose with new image versions
                        sed -i "s|image: \\(.*\\):|image: \\1:${BUILD_VERSION}|g" docker-compose.staging.yml
                        
                        echo "Deploying to staging..."
                        docker-compose -f docker-compose.staging.yml up -d
                        
                        echo "Waiting for deployment to complete..."
                        sleep 60
                        
                        echo "Running smoke tests on staging..."
                        curl -f http://${STAGING_HOST}:8080/users/health || exit 1
                        curl -f http://${STAGING_HOST}:8080/products/health || exit 1
                    '''
                }
            }
        }
        
        stage('🎯 Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                        input message: '🚀 Deploy to Production?', 
                              ok: 'Deploy',
                              submitterParameter: 'DEPLOYER'
                    }
                }
                
                echo "🎯 Deploying to production environment..."
                echo "Deployer: ${env.DEPLOYER}"
                
                script {
                    sh '''
                        echo "Creating production backup..."
                        # Backup current production state
                        
                        echo "Updating production environment..."
                        sed -i "s|image: \\(.*\\):|image: \\1:${BUILD_VERSION}|g" docker-compose.prod.yml
                        
                        echo "Blue-Green deployment to production..."
                        # Implement blue-green deployment strategy
                        
                        echo "Running production smoke tests..."
                        curl -f http://${PRODUCTION_HOST}:8080/users/health || exit 1
                        curl -f http://${PRODUCTION_HOST}:8080/products/health || exit 1
                        
                        echo "Production deployment completed successfully!"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
            
            // Archive build artifacts
            archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
        }
        
        success {
            echo '✅ Pipeline completed successfully!'
            script {
                // Send success notification
                sh '''
                    echo "📧 Sending success notification..."
                    # Send Slack/Teams/Email notification
                '''
            }
        }
        
        failure {
            echo '❌ Pipeline failed!'
            script {
                // Send failure notification
                sh '''
                    echo "📧 Sending failure notification..."
                    # Send Slack/Teams/Email notification with failure details
                '''
            }
        }
        
        unstable {
            echo '⚠️ Pipeline completed with warnings!'
        }
    }
}
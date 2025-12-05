pipeline {
    agent any

    environment {
        // Carga la credencial 'docker-hub-credentials'
        DOCKER_CREDS = credentials('docker-hub-credentials')
        // Jenkins automáticamente crea la variable DOCKER_CREDS_USR con el username
        BACKEND_IMAGE_NAME = "${DOCKER_CREDS_USR}/proyecto-backend"
        FRONTEND_IMAGE_NAME = "${DOCKER_CREDS_USR}/proyecto-frontend"
    }

    stages {
        stage('1. Checkout') {
            steps {
                // Clona el repositorio
                checkout scm
                echo "Proyecto clonado."
            }
        }

        stage('2. Pruebas y Calidad') {
            steps {
                script {
                    echo "Ejecutando pruebas y análisis de calidad..."
                    def testImage = docker.build("backend-test:${env.BUILD_ID}", "-f backend_container/Dockerfile backend_container")
                    
                    testImage.inside {
                        // 1. Pruebas Unitarias
                        echo "--- Ejecutando RSpec ---"
                        sh 'bundle exec rspec'
                        
                        // 2. Análisis de Estilo (Linter)
                        // Usamos || true para que no rompa el build si solo son advertencias de estilo,
                        // pero en un entorno estricto lo quitaríamos.
                        echo "--- Ejecutando Rubocop ---"
                        sh 'bundle exec rubocop --format simple || true'

                        // 3. Análisis de Seguridad
                        echo "--- Ejecutando Brakeman ---"
                        // Brakeman escanea buscando vulnerabilidades comunes
                        sh 'bundle exec brakeman -q --no-exit-on-warn --no-exit-on-error || true'
                    }
                }
            }
        }

        stage('3. Build Backend Image') {
            steps {
                script {
                    echo "Construyendo imagen Docker para el backend..."
                    // Usamos el Dockerfile en la carpeta del backend
                    def backendImage = docker.build(
                        "${BACKEND_IMAGE_NAME}:${env.BUILD_ID}",
                        "-f backend_container/Dockerfile ./backend_container"
                    )
                    echo "Imagen ${BACKEND_IMAGE_NAME}:${env.BUILD_ID} construida."
                }
            }
        }

        stage('4. Build Frontend Image') {
            steps {
                script {
                    echo "Construyendo imagen Docker para el frontend..."
                    // Usamos el Dockerfile en la carpeta del frontend
                    def frontendImage = docker.build(
                        "${FRONTEND_IMAGE_NAME}:${env.BUILD_ID}",
                        "-f frontend_container/Dockerfile ./frontend_container"
                    )
                    echo "Imagen ${FRONTEND_IMAGE_NAME}:${env.BUILD_ID} construida."
                }
            }
        }

        stage('5. Publicar Imágenes (Push)') {
            steps {
                script {
                    // Jenkins necesita credenciales para el registro de Docker
                    // Se debe configurar un 'Credential' en Jenkins con el ID 'docker-hub-credentials'
                    docker.withRegistry("https://registry.hub.docker.com", 'docker-hub-credentials') {
                        echo "Publicando imagen del backend: ${BACKEND_IMAGE_NAME}:${env.BUILD_ID}"
                        docker.image("${BACKEND_IMAGE_NAME}:${env.BUILD_ID}").push()

                        echo "Publicando imagen del frontend: ${FRONTEND_IMAGE_NAME}:${env.BUILD_ID}"
                        docker.image("${FRONTEND_IMAGE_NAME}:${env.BUILD_ID}").push()
                    }
                }
            }
        }


    }

    post {
        always {
            echo "Pipeline finalizado."
            // Limpieza de imágenes locales si es necesario
            script {
                sh "docker rmi ${BACKEND_IMAGE_NAME}:${env.BUILD_ID} || true"
                sh "docker rmi ${FRONTEND_IMAGE_NAME}:${env.BUILD_ID} || true"
            }
        }
    }
}

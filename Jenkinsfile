pipeline {
    agent any

    environment {
        // Define el nombre de tu usuario de Docker Hub u otro registro
        DOCKER_REGISTRY_USER = 'your-docker-username'
        // El nombre para la imagen del backend
        BACKEND_IMAGE_NAME = "${DOCKER_REGISTRY_USER}/proyecto-backend"
        // El nombre para la imagen del frontend
        FRONTEND_IMAGE_NAME = "${DOCKER_REGISTRY_USER}/proyecto-frontend"
    }

    stages {
        stage('1. Checkout') {
            steps {
                // Clona el repositorio
                checkout scm
                echo "Proyecto clonado."
            }
        }

        stage('2. Pruebas (Backend)') {
            steps {
                // Este es un paso CRÍTICO. Debes implementar pruebas reales.
                // Por ahora, solo mostraremos un mensaje.
                echo "ADVERTENCIA: No se están ejecutando pruebas reales para el backend."
                echo "Debes agregar un framework de pruebas como RSpec y ejecutar 'bundle exec rspec'."
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

        stage('6. Deploy en Servidor') {
            steps {
                script {
                    echo "Desplegando la aplicación..."
                    // Jenkins necesita credenciales SSH para tu servidor de producción/staging
                    // Se debe configurar un 'Credential' de tipo 'SSH Username with private key' con el ID 'deploy-server-ssh'
                    // Reemplaza 'user@your-server-ip' con los datos de tu servidor
                    sshagent(credentials: ['deploy-server-ssh']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no user@your-server-ip '
                                echo "Conectado al servidor de deploy."

                                # Exportar variables para que docker-compose las use
                                export BACKEND_IMAGE="${BACKEND_IMAGE_NAME}:${env.BUILD_ID}"
                                export FRONTEND_IMAGE="${FRONTEND_IMAGE_NAME}:${env.BUILD_ID}"

                                # Navegar al directorio del proyecto en el servidor
                                # DEBES asegurarte de que un docker-compose.yml de producción exista en esta ruta
                                cd /ruta/a/tu/app

                                # Descargar las nuevas imágenes
                                docker-compose pull

                                # Levantar los servicios con las nuevas imágenes
                                docker-compose up -d

                                echo "Deploy finalizado."
                            '
                        '''
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

# Usar la imagen oficial de Jenkins LTS como base
FROM jenkins/jenkins:lts-jdk17

# Cambiar al usuario root para instalar paquetes
USER root

# Instalar el cliente de Docker
RUN apt-get update && \
    apt-get install -y lsb-release && \
    curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli

# Copiar el archivo de plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

# Instalar los plugins desde el archivo
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

# Volver al usuario jenkins
USER jenkins

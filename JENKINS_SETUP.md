# Documentación de Implementación de CI/CD con Jenkins

Este documento describe cómo configurar y utilizar el pipeline de Jenkins para la construcción, prueba y despliegue automatizado de este proyecto.

## 1. Prerrequisitos

Para levantar todo el entorno (tu aplicación y el servidor Jenkins), solo necesitas tener **Docker y Docker Compose instalados** en tu máquina.

## 2. El `Jenkinsfile`

El archivo `Jenkinsfile` en la raíz del proyecto define el pipeline de CI/CD. Está dividido en las siguientes etapas:

*   **Stage 1: Checkout:** Clona el código fuente del repositorio.
*   **Stage 2: Pruebas (Backend):** **(ACCIÓN REQUERIDA)**. Este es un marcador de posición. Debes implementar un framework de pruebas como `RSpec` para tu aplicación Ruby y añadir el comando de ejecución aquí (ej. `sh 'bundle exec rspec'`). **Un pipeline sin pruebas automatizadas es riesgoso.**
*   **Stage 3 & 4: Build de Imágenes:** Construye las imágenes de Docker para el `backend` y el `frontend` utilizando sus respectivos `Dockerfiles`. Las imágenes se etiquetan con el número de build de Jenkins (`env.BUILD_ID`) para tener un versionado único.
*   **Stage 5: Publicar Imágenes:** Sube las imágenes recién construidas al registro de contenedores que configuraste.
*   **Stage 6: Deploy en Servidor:** Se conecta de forma segura vía SSH al servidor de despliegue, descarga las nuevas versiones de las imágenes y reinicia los servicios usando `docker-compose`.

## 3. Configuración del Entorno Local (Aplicación + Jenkins)

Para levantar toda la infraestructura (tu aplicación frontend, backend y el servidor Jenkins) con un solo comando:

1.  **Asegúrate de estar en la raíz de tu proyecto.**
2.  **Ejecuta el siguiente comando:**
    ```bash
    docker-compose up --build -d
    ```
    *   La primera vez que ejecutes este comando, Docker Compose construirá la imagen personalizada de Jenkins (esto puede tardar varios minutos mientras descarga la imagen base e instala los plugins).
    *   Luego, iniciará los servicios `jenkins`, `frontend` y `backend` en segundo plano.

### Acceso a los Servicios:

Una vez que los servicios estén levantados:

*   **Jenkins:** `http://localhost:8080`
*   **Frontend App:** `http://localhost:8081`
*   **Backend App:** `http://localhost:4567`

### Obtener la Contraseña Inicial de Jenkins:

Para acceder a la interfaz web de Jenkins por primera vez, necesitarás una contraseña de administrador. Puedes obtenerla de los logs del contenedor de Jenkins:

```bash
docker-compose logs jenkins
```
Busca una línea similar a: `Please use the following password to proceed to installation: <TU_CONTRASEÑA_AQUI>`. Copia esa contraseña.

### Configuración Inicial de Jenkins:

1.  Abre `http://localhost:8080` en tu navegador.
2.  Pega la contraseña inicial.
3.  Sigue las instrucciones para instalar los plugins sugeridos (o selecciona los que necesites).
4.  Crea tu primer usuario administrador.

## 4. Configuración del Job en Jenkins

Una vez que Jenkins esté configurado y funcionando:

### a. Creación del Job

1.  En tu panel de Jenkins, haz clic en **"New Item"**.
2.  Dale un nombre a tu proyecto (ej. `proyecto-fullstack-pipeline`) y selecciona **"Pipeline"**. Haz clic en **"OK"**.
3.  En la página de configuración del job, ve a la sección **"Pipeline"**.
4.  Cambia la **"Definition"** a **"Pipeline script from SCM"**.
5.  En **"SCM"**, selecciona **"Git"**.
6.  En **"Repository URL"**, introduce la URL de tu repositorio Git (ej. `git@github.com:Darell12/proyecto-integracioncontinua-poli-sg3.git`).
7.  Si el repositorio es privado, añade las credenciales correspondientes.
8.  Asegúrate de que el **"Script Path"** sea `Jenkinsfile`. Por defecto lo es.
9.  Guarda la configuración.

### b. Configuración de Credenciales

El pipeline necesita dos juegos de credenciales para funcionar:

1.  **Credenciales del Registro Docker (`docker-hub-credentials`):**
    *   Ve a **Manage Jenkins > Credentials**.
    *   Haz clic en **(global)** y luego en **"Add Credentials"**.
    *   **Kind:** `Username with password`.
    *   **Username:** Tu nombre de usuario de Docker Hub.
    *   **Password:** Tu contraseña o token de acceso de Docker Hub.
    *   **ID:** `docker-hub-credentials`. **(Este ID debe ser exacto)**.
    *   Guarda las credenciales.

2.  **Credenciales SSH para el Deploy (`deploy-server-ssh`):**
    *   Ve a **Manage Jenkins > Credentials > (global) > Add Credentials**.
    *   **Kind:** `SSH Username with private key`.
    *   **Username:** El usuario con el que te conectarás a tu servidor de despliegue (ej. `ubuntu`, `ec2-user`).
    *   **Private Key:** Marca la opción **"Enter directly"** y pega la clave privada SSH que usas para acceder a tu servidor.
    *   **ID:** `deploy-server-ssh`. **(Este ID debe ser exacto)**.
    *   Guarda las credenciales.

## 5. Archivo `docker-compose` para Producción

El `docker-compose.yml` de tu repositorio es ideal para desarrollo, pero para producción, el pipeline de Jenkins espera un archivo `docker-compose.yml` en tu servidor de despliegue (`/ruta/a/tu/app`) que se vea así:

```yaml
version: "3.8"
services:
  frontend:
    # La imagen se obtiene del registro, no se construye localmente
    image: ${FRONTEND_IMAGE}
    ports:
      - "80:80"
    depends_on:
      - backend

  backend:
    # La imagen se obtiene del registro
    image: ${BACKEND_IMAGE}
    ports:
      - "4567:4567"
```
**Nota:** Las variables `${FRONTEND_IMAGE}` y `${BACKEND_IMAGE}` son inyectadas por el pipeline de Jenkins durante el despliegue.

## 6. Próximos Pasos

1.  **Implementar pruebas automatizadas** para el backend.
2.  Configurar tu servidor de despliegue con Docker, Docker Compose y el `docker-compose.yml` de producción.
3.  Ajustar los nombres de usuario, IPs y rutas en el `Jenkinsfile` y en la configuración de Jenkins.

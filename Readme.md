
######
Lancement du projet 
######





#####
Envie d'en savoir plus sur mon code...
#####

#####
requirements.txt
#####

Le fichier requirements.txt nous donne toutes les librairies à installer. 
Cela se fera dans le Dockerfile pour simplifier au maximum le lancement de mon application. 
Pour cela, voici les librairies installées : flask flask-sqlalchemy psycopg2-binary.
Elles serviront principalement pour l'interface.

#####
.dockerignore
#####

Le fichier .dockerignore sert à alléger l'image en ignorant les différents fichiers qu'il contient.

#####
Dockerfile
#####

Au début, j'ai opté pour un Dockerfile "simple" :

##
FROM python:3.9-slim

WORKDIR /app

# Installation des dépendances
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copie du code
COPY . .

CMD ["python", "app.py"]
##

Cependant, cela ne m'a pas aidé à respecter les "best practices". 
Je l'ai donc adapté pour qu'il utilise le multi-stage et le reste des bonnes pratiques, 
comme la sécurité, à l'aide de Gemini Pro.

#####
Docker-compose.yml
#####

Dans ce code, on retrouve mon image (image on registry) sur mon compte Docker Hub.

Ainsi que le scan + report avec ce code :
YAML

##
  security-audit:
    image: aquasec/trivy:latest
    container_name: security-audit
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - .:/output
    # On scanne bien la nouvelle image nommée
    command: image --format table --output /output/security-report.txt levequeaurelien/compteur-python:v1
    depends_on:
      - web
##

Cela est donc stocké dans le fichier security-report.txt dans ce projet.
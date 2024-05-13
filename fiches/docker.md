# Docker

### installation de docker via apt

https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

```bash
# Version de docker
docker -v

# Version de docker compose
docker compose version

# Hello world
sudo docker run hello-world # affiche : Hello from Docker!

# Ajouter l'utilisateur courant au groupe de permissions 'docker' (évite ainsi de taper 'sudo' à chaque commande docker)
sudo usermod -aG docker $USER
sudo systemctl restart docker
exit # redémarrer la session terminal si necessaire
```

### Quelques commandes de base

```bash
# Lancer un conteneur httpd (Apache)
docker run -d -p 8080:80 --name myserver httpd
# -d : lancer le conteneur en tâche de fond
# -p 8080:80 : bind le port 8080 de la machine vers le port 80 du conteneur
# --name myserver : donner un nom au conteneur
# httpd : image contenant un serveur Apache
# Test : http://<username>-server.eddi.cloud:8080 affiche 'It works!'

# Lister toutes les images téléchargées
docker images

# Lister tous les conteneurs actifs
docker ps

# Lister tous les conteneurs créés
docker ps -a

# Stopper un conteneur
docker stop myserver

# Relancer un conteneur
docker start myserver

# Supprimer un conteneur (préalablement stoppé)
docker rm myserver # ajouter '-f' s'il n'est pas préalablement stoppé

# Supprimer une image (non utilisée)
docker ps rm httpd

# Faire le ménage : supprimer des conteneurs, networks, caches inutilisés...
docker system prune
```

### Exec

Pour executer des commandes sur le container

```bash
# Re-créer le conteneur
docker run -d -p 8080:80 --name myserver httpd

# Accéder au bash (shell Linux) du conteneur
docker exec -it myserver bash
# -it : terminal interactif (interactive + tty)

# Remplacer le contenu HTML du 'DocumentRoot' du serveur Apache
sed -i 's/It works!/Bonjour/' /usr/local/apache2/htdocs/index.html
```

### Pour lier des dossiers de l'hôte au container

```bash
# Créer un nouveau projet statique
mkdir /home/student/ofig
echo '<html><head><link href="./style.css" rel="stylesheet" /></head><body>Ofig</body></html>' > /home/student/ofig/index.html
echo 'body { background-color: #F0F; }' > /home/student/ofig/style.css

# Recréer un conteneur en ajoutant un binding entre un dossier local et le conteneur
docker run -d -p 8080:80 --name ofig -v /home/student/ofig:/usr/local/apache2/htdocs/ httpd
# -v (--volume) : le dossier (local) /home/student/ofig est monté sur le dosier /usr/local/apache2/htdocs/ du conteneur

# Tester
curl http://<username>-server.eddi.cloud:8080/

# Inspecter le binding
docker inspect ofig # regarder les propriétés "HostConfig.Binds" et "Mounts"
```

### Créer une image

La première chose à faire est de créer un fichier `Dockerfile` (sans extension) à la racine du projet

```
# Utiliser une image de base officielle Node.js comme runtime
FROM node:20

# Définir un répertoire de travail à l'intérieur du conteneur (au choix, mais typique pour les projets Node)
WORKDIR /usr/src/app

# Copier le package.json et le package-lock.json dans le répertoire de travail
COPY package*.json ./

# Installer les dépendances
RUN npm install

# Copier le code de l'application dans le conteneur
COPY . .

# Définir les variables d'environnement
ENV PORT=3001

# Exposer le port spécifié dans la variable d'environnement
EXPOSE $PORT

# Définir la commande pour exécuter votre application
CMD ["node", "index.js"]
```

On peut maintenant créer l'image et deployer un container se basant sur elle :

```bash
# Aller dans le dossier
cd myproject

# Créer l'image (myproject) à partir des sources (.)
docker build -t myproject .

# Vérifier
docker images

# Déployer un conteneur
docker run -d -p 3001:3001 --name myproject myproject

# Voir les logs du serveur
docker logs myproject

# Tester
curl http://localhost:3001
```

### Push une image sur DockerHub

```bash
# Se connecter à DockerHub depuis son CLI (se créer un compte sur DockerHub via son compte Github si besoin)
docker login

# Tagger l'image
docker tag myproject:latest <username>/myproject:latest

# Push l'image
docker push <username>/myproject:latest

# Vérification
curl https://hub.docker.com/repository/docker/<username>/myproject/general

# ❗️ Passer l'image privé dans les settings :
# https://hub.docker.com/repository/docker/<username>/myproject/settings

# ❗️ Si le build est fait depuis MacOS, il faut aussi exporter une image pour Linux AMD64. Sinon il ne sera pas possible de lancer un container depuis la VM Kourou
docker buildx build --platform linux/amd64 -t <username>/myproject:latest-ubuntu --push .
```

### Pull depuis DockerHub

```bash
# Créer un conteneur à bind sur le port 3001
docker run -d -p 3001:3001 --name myproject <username>/myproject --restart=always
docker run -d -p 3001:3001 --name myproject <username>/myproject:latest-ubuntu --restart=always # ❗️ OU ❗️ si le build a été fait depuis MacOS


# Créer une config Nginx pour le sous domaine 'myproject'
sudo bash -c 'cat <<EOF >> /etc/nginx/sites-available/myproject.conf
server {
  listen 80;
  server_name myproject.<username>-server.eddi.cloud;
  location / {
    proxy_pass http://localhost:3001;
  }
}
EOF'

# Créer un lien symbolique pour activer la configuration
sudo ln -s /etc/nginx/sites-available/myproject.conf /etc/nginx/sites-enabled/myproject.conf

# Relancer nginx
sudo systemctl reload nginx

# Tester
curl http://myproject.<username>-server.eddi.cloud/
```

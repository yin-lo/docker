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

### Pour lier des dossiers de l'hôte sur le container

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

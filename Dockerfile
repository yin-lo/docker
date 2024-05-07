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
ENV PORT=4000

# Exposer le port spécifié dans la variable d'environnement
EXPOSE $PORT

# Définir la commande pour exécuter votre application
CMD ["node", "index.js"]
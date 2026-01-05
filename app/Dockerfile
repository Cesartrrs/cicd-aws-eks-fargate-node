FROM node:20-alpine

WORKDIR /usr/src/app

# Instala dependencias primero para aprovechar cache
COPY package*.json ./
RUN npm ci --omit=dev

# Copia el código
COPY . .

ENV PORT=3000
EXPOSE 3000

# Seguridad básica
USER node

CMD ["node", "server.js"]

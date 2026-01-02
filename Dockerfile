FROM node:20-alpine
WORKDIR /app
COPY fabrik/package*.json ./
RUN npm install --omit=dev
COPY fabrik .
EXPOSE 4000
CMD ["node", "src/server.js"]

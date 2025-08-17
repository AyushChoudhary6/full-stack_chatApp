FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

# Install curl for healthchecks
RUN apk add --no-cache curl

COPY . .

EXPOSE 5000

CMD ["node", "src/index.js"]
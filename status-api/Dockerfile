# ---- Etapa 1: instalar dependencias ---- 

FROM node:20-alpine AS deps 

WORKDIR /app 

COPY package*.json ./ 

RUN npm install --omit=dev 

  

# ---- Etapa 2: imagen final, solo con lo necesario para correr ---- 

FROM node:20-alpine 

WORKDIR /app 

COPY --from=deps /app/node_modules ./node_modules 

COPY package*.json ./ 

COPY server.js ./ 

  

RUN addgroup -S appgroup && adduser -S appuser -G appgroup 

USER appuser 

  

EXPOSE 3000 

CMD ["node", "server.js"] 
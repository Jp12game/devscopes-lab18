FROM node:20-alpine 

  

WORKDIR /app 

  

COPY package*.json ./ 

RUN npm install --omit=dev 

  

COPY kafka-producer.js kafka-consumer.js ./ 

  

RUN addgroup -S appgroup && adduser -S appuser -G appgroup 

USER appuser 

  

CMD ["node", "kafka-consumer.js"] 
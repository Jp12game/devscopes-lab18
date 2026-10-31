const { Kafka } = require('kafkajs'); 

  

const kafka = new Kafka({ 

  clientId: 'devsecops-lab-producer', 

  brokers: ['kafka:9092'], 

}); 

  

const producer = kafka.producer(); 

  

async function main() { 

  await producer.connect(); 

  

  const order = { 

    orderId: `KAFKA-${Date.now()}`, 

    productId: 'sku-100', 

    amount: 25, 

  }; 

  

  await producer.send({ 

    topic: 'order-events', 

    messages: [{ key: order.orderId, value: JSON.stringify(order) }], 

  }); 

  

  console.log('Evento publicado en Kafka:', order); 

  await producer.disconnect(); 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
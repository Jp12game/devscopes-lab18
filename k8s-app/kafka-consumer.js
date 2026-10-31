const { Kafka } = require('kafkajs'); 

  

const kafka = new Kafka({ 

  clientId: 'devsecops-lab-consumer', 

  brokers: ['kafka:9092'], 

}); 

  

const consumer = kafka.consumer({ groupId: 'billing-service-group' }); 

  

async function main() { 

  await consumer.connect(); 

  await consumer.subscribe({ topic: 'order-events', fromBeginning: true }); 

  

  console.log('Escuchando el tópico order-events...'); 

  

  await consumer.run({ 

    eachMessage: async ({ partition, message }) => { 

      const order = JSON.parse(message.value.toString()); 

      console.log(`[billing-service] Orden recibida desde la partición ${partition}: ${order.orderId}`); 

    }, 

  }); 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
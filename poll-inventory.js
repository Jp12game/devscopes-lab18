const { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } = require('@aws-sdk/client-sqs'); 

  

const REGION = 'us-east-1'; 

const QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/665206375253/devsecops-lab-inventory-queue'; 

  

const client = new SQSClient({ region: REGION }); 

  

async function main() { 

  console.log('Revisando la cola de inventario...'); 

  const { Messages } = await client.send(new ReceiveMessageCommand({ 

    QueueUrl: QUEUE_URL, 

    MaxNumberOfMessages: 10, 

    WaitTimeSeconds: 10, 

  })); 

  

  if (!Messages || Messages.length === 0) { 

    console.log('No llegaron mensajes nuevos. Intenten de nuevo en unos segundos.'); 

    return; 

  } 

  

  for (const msg of Messages) { 

    const event = JSON.parse(msg.Body); 

    const order = event.detail; 

    console.log(`[inventory-service] Reservando stock de ${order.productId} para la orden ${order.orderId}`); 

  

    await client.send(new DeleteMessageCommand({ 

      QueueUrl: QUEUE_URL, 

      ReceiptHandle: msg.ReceiptHandle, 

    })); 

  } 

  

  console.log(`Procesados ${Messages.length} mensaje(s).`); 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
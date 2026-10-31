const { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } = require('@aws-sdk/client-sqs'); 

const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns'); 

  

const REGION = 'us-east-1'; 

const QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/665206375253/devsecops-lab-orders-api-queue'; 

const TOPIC_ARN = 'arn:aws:sns:us-east-1:665206375253:devsecops-lab-order-events-topic'; 

  

const sqsClient = new SQSClient({ region: REGION }); 

const snsClient = new SNSClient({ region: REGION }); 

  

async function main() { 

  console.log('Revisando la cola de pedidos de la API...'); 

  const { Messages } = await sqsClient.send(new ReceiveMessageCommand({ 

    QueueUrl: QUEUE_URL, 

    MaxNumberOfMessages: 10, 

    WaitTimeSeconds: 10, 

  })); 

  

  if (!Messages || Messages.length === 0) { 

    console.log('No llegaron pedidos nuevos.'); 

    return; 

  } 

  

  for (const msg of Messages) { 

    const order = JSON.parse(msg.Body); 

  

    await snsClient.send(new PublishCommand({ 

      TopicArn: TOPIC_ARN, 

      Message: JSON.stringify(order), 

      Subject: 'NuevoPedido', 

    })); 

  

    console.log(`[fan-out] Pedido ${order.orderId} republicado en SNS para todos los interesados.`); 

  

    await sqsClient.send(new DeleteMessageCommand({ 

      QueueUrl: QUEUE_URL, 

      ReceiptHandle: msg.ReceiptHandle, 

    })); 

  } 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
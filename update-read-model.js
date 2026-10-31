const { SQSClient, ReceiveMessageCommand, DeleteMessageCommand } = require('@aws-sdk/client-sqs'); 

const { DynamoDBClient } = require('@aws-sdk/client-dynamodb'); 

const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb'); 

  

const REGION = 'us-east-1'; 

const QUEUE_URL = 'https://sqs.us-east-1.amazonaws.com/665206375253/devsecops-lab-inventory-queue';

const TABLE_NAME = 'devsecops-lab-orders-read-model'; 

  

const sqsClient = new SQSClient({ region: REGION }); 

const ddbClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: REGION })); 

  

async function main() { 

  console.log('Revisando eventos para actualizar el modelo de lectura...'); 

  const { Messages } = await sqsClient.send(new ReceiveMessageCommand({ 

    QueueUrl: QUEUE_URL, 

    MaxNumberOfMessages: 10, 

    WaitTimeSeconds: 10, 

  })); 

  

  if (!Messages || Messages.length === 0) { 

    console.log('No llegaron eventos nuevos.'); 

    return; 

  } 

  

  for (const msg of Messages) { 

    const event = JSON.parse(msg.Body); 

    const order = event.detail; 

  

    await ddbClient.send(new PutCommand({ 

      TableName: TABLE_NAME, 

      Item: { 

        orderId: order.orderId, 

        productId: order.productId, 

        amount: order.amount, 

        status: 'received', 

        updatedAt: new Date().toISOString(), 

      }, 

    })); 

  

    console.log(`[read-model] Orden ${order.orderId} escrita en el modelo de lectura.`); 

  

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
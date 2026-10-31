const { DynamoDBClient } = require('@aws-sdk/client-dynamodb'); 

const { DynamoDBDocumentClient, ScanCommand } = require('@aws-sdk/lib-dynamodb'); 

  

const REGION = 'us-east-1'; 

const TABLE_NAME = 'devsecops-lab-orders-read-model'; 

const ddbClient = DynamoDBDocumentClient.from(new DynamoDBClient({ region: REGION })); 

  

async function main() { 

  const { Items } = await ddbClient.send(new ScanCommand({ TableName: TABLE_NAME })); 

  console.log(`Órdenes en el modelo de lectura (${Items.length}):`); 

  Items.forEach((item) => { 

    console.log(`  - ${item.orderId}: ${item.status} ($${item.amount})`); 

  }); 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
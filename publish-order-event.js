const { EventBridgeClient, PutEventsCommand } = require('@aws-sdk/client-eventbridge'); 

  

const REGION = 'us-east-1'; 

const EVENT_BUS = 'devsecops-lab-orders-bus'; 

const client = new EventBridgeClient({ region: REGION }); 

  

async function publishOrderCreated(order) { 

  const result = await client.send(new PutEventsCommand({ 

    Entries: [{ 

      EventBusName: EVENT_BUS, 

      Source: 'devsecops.lab.checkout', 

      DetailType: 'OrderCreated', 

      Detail: JSON.stringify(order), 

    }], 

  })); 

  console.log('Evento publicado:', JSON.stringify(result.Entries)); 

} 

  

async function main() { 

  const order = { 

    orderId: `ORD-${Date.now()}`, 

    productId: 'sku-100', 

    amount: 25, 

  }; 

  console.log('Publicando evento OrderCreated:', order); 

  await publishOrderCreated(order); 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
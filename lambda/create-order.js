const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs'); 

  

const REGION = process.env.AWS_REGION || 'us-east-1'; 

const QUEUE_URL = process.env.QUEUE_URL; 

const sqsClient = new SQSClient({ region: REGION }); 

  

exports.handler = async (event) => { 

  let body; 

  try { 

    body = JSON.parse(event.body || '{}'); 

  } catch (err) { 

    return { 

      statusCode: 400, 

      body: JSON.stringify({ error: 'El cuerpo de la solicitud debe ser JSON válido' }), 

    }; 

  } 

  

  if (!body.productId || !body.amount) { 

    return { 

      statusCode: 400, 

      body: JSON.stringify({ error: 'Se requieren los campos productId y amount' }), 

    }; 

  } 

  

  const order = { 

    orderId: `API-${Date.now()}`, 

    productId: body.productId, 

    amount: body.amount, 

  }; 

  

  await sqsClient.send(new SendMessageCommand({ 

    QueueUrl: QUEUE_URL, 

    MessageBody: JSON.stringify(order), 

  })); 

  

  return { 

    statusCode: 201, 

    headers: { 'Content-Type': 'application/json' }, 

    body: JSON.stringify({ message: 'Orden recibida', order }), 

  }; 

}; 
const sdk = require('./tracing'); // Debe ser el PRIMER require de todo el archivo 

  

const { createOrder } = require('./src/orderService'); 

const { CloudWatchClient, PutMetricDataCommand } = require('@aws-sdk/client-cloudwatch'); 

const { 

  CloudWatchLogsClient, 

  PutLogEventsCommand, 

  CreateLogStreamCommand, 

} = require('@aws-sdk/client-cloudwatch-logs'); 

  

const REGION = 'us-east-1'; 

const LOG_GROUP = '/devsecops-lab/checkout-service'; 

const LOG_STREAM = `run-${Date.now()}`; 

  

const cwClient = new CloudWatchClient({ region: REGION }); 

const logsClient = new CloudWatchLogsClient({ region: REGION }); 

  

async function ensureLogStream() { 

  await logsClient.send(new CreateLogStreamCommand({ 

    logGroupName: LOG_GROUP, 

    logStreamName: LOG_STREAM, 

  })); 

} 

  

async function sendLog(message) { 

  await logsClient.send(new PutLogEventsCommand({ 

    logGroupName: LOG_GROUP, 

    logStreamName: LOG_STREAM, 

    logEvents: [{ timestamp: Date.now(), message }], 

  })); 

} 

  

async function sendMetric(name, value, unit = 'Count') { 

  await cwClient.send(new PutMetricDataCommand({ 

    Namespace: 'DevSecOpsLab/CheckoutService', 

    MetricData: [{ 

      MetricName: name, 

      Value: value, 

      Unit: unit, 

      Timestamp: new Date(), 

    }], 

  })); 

} 

  

async function main() { 

  await ensureLogStream(); 

  

  const orders = [ 

    { orderId: 'A1', productId: 'sku-100', amount: 25 }, 

    { orderId: 'A2', productId: 'sku-200', amount: 40 }, 

    { orderId: 'A3', productId: 'sku-300', amount: 15 }, 

    { orderId: 'A4', productId: 'sku-400', amount: 60 }, 

    { orderId: 'A5', productId: 'sku-500', amount: 30 }, 

  ]; 

  

  let errors = 0; 

  

  for (const order of orders) { 

    const start = Date.now(); 

    const result = createOrder(order.orderId, order.productId, order.amount); 

    const latencyMs = Date.now() - start; 

  

    await sendMetric('RequestCount', 1); 

    await sendMetric('LatencyMs', latencyMs, 'Milliseconds'); 

  

    if (!result.success) { 

      errors += 1; 

      await sendMetric('ErrorCount', 1); 

      await sendLog(`ERROR orden ${order.orderId}: ${result.reason}`); 

    } else { 

      await sendLog(`OK orden ${order.orderId} completada`); 

    } 

  } 

  

  console.log(`Ejecución completa: ${orders.length} órdenes, ${errors} errores.`); 

  await sdk.shutdown(); // Fuerza a imprimir los spans pendientes antes de salir 

} 

  

main().catch((err) => { 

  console.error('Error ejecutando el script:', err); 

  process.exit(1); 

}); 
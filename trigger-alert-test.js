const { CloudWatchClient, PutMetricDataCommand } = require('@aws-sdk/client-cloudwatch'); 

  

const REGION = 'us-east-1'; 

const cwClient = new CloudWatchClient({ region: REGION }); 

  

async function main() { 

  console.log('Enviando métricas de error simuladas para probar la alarma...'); 

  for (let i = 0; i < 3; i++) { 

    await cwClient.send(new PutMetricDataCommand({ 

      Namespace: 'DevSecOpsLab/CheckoutService', 

      MetricData: [{ 

        MetricName: 'ErrorCount', 

        Value: 1, 

        Unit: 'Count', 

        Timestamp: new Date(), 

      }], 

    })); 

  } 

  console.log('Métricas enviadas. La alarma puede tardar unos minutos en activarse.'); 

} 

  

main().catch((err) => { 

  console.error(err); 

  process.exit(1); 

}); 
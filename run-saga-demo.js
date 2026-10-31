const sdk = require('./tracing'); // del Laboratorio 7 — reutiliza el mismo inicializador de OpenTelemetry 

const { runSaga } = require('./saga-orchestrator'); 

  

async function main() { 

  for (let i = 0; i < 5; i++) { 

    console.log(`--- Intento ${i + 1} ---`); 

    await runSaga({ orderId: `SAGA-${Date.now()}-${i}`, productId: 'sku-1', amount: 20 }); 

  } 

  await sdk.shutdown(); 

} 

  

main(); 
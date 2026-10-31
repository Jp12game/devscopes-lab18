const { trace } = require('@opentelemetry/api'); 

const tracer = trace.getTracer('inventory-service'); 

  

function checkStock(productId) { 

  return tracer.startActiveSpan('checkStock', (span) => { 

    span.setAttribute('product.id', productId); 

    const inStock = Math.random() > 0.1; // 90% de las veces hay stock 

    span.setAttribute('product.inStock', inStock); 

    span.end(); 

    return inStock; 

  }); 

} 

  

module.exports = { checkStock }; 
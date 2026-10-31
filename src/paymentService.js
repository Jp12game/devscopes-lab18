const { trace } = require('@opentelemetry/api'); 

const tracer = trace.getTracer('payment-service'); 

  

function processPayment(orderId, amount) { 

  return tracer.startActiveSpan('processPayment', (span) => { 

    span.setAttribute('order.id', orderId); 

    span.setAttribute('payment.amount', amount); 

    const approved = Math.random() > 0.05; // 5% de rechazo simulado 

    span.setAttribute('payment.approved', approved); 

    span.end(); 

    return approved; 

  }); 

} 

  

module.exports = { processPayment }; 
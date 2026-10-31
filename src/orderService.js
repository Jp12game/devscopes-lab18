const { trace } = require('@opentelemetry/api'); 

const { checkStock } = require('./inventoryService'); 

const { processPayment } = require('./paymentService'); 

  

const tracer = trace.getTracer('order-service'); 

  

function createOrder(orderId, productId, amount) { 

  return tracer.startActiveSpan('createOrder', (span) => { 

    span.setAttribute('order.id', orderId); 

  

    const inStock = checkStock(productId); 

    if (!inStock) { 

      span.setAttribute('order.status', 'rejected_no_stock'); 

      span.end(); 

      return { success: false, reason: 'sin stock' }; 

    } 

  

    const paid = processPayment(orderId, amount); 

    if (!paid) { 

      span.setAttribute('order.status', 'rejected_payment'); 

      span.end(); 

      return { success: false, reason: 'pago rechazado' }; 

    } 

  

    span.setAttribute('order.status', 'completed'); 

    span.end(); 

    return { success: true }; 

  }); 

} 

  

module.exports = { createOrder }; 
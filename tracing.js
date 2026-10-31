const { NodeSDK } = require('@opentelemetry/sdk-node'); 

const { ConsoleSpanExporter } = require('@opentelemetry/sdk-trace-node'); 

const { resourceFromAttributes } = require('@opentelemetry/resources'); 

const { ATTR_SERVICE_NAME } = require('@opentelemetry/semantic-conventions'); 

  

const sdk = new NodeSDK({ 

  resource: resourceFromAttributes({ 

    [ATTR_SERVICE_NAME]: 'devsecops-checkout-service', 

  }), 

  traceExporter: new ConsoleSpanExporter(), 

}); 

  

sdk.start(); 

  

module.exports = sdk; 
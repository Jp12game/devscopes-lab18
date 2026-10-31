const express = require('express');

const os = require('os');

const app = express();

const PORT = process.env.PORT || 3000;

let requestCount = 0;

app.get('/health', (req, res) => {

    res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });

});

app.get('/', (req, res) => {

    requestCount += 1;

    res.status(200).json({

        message: 'DevSecOps Lab - Status API v2',

        hostname: os.hostname(),

        requestCount,

    });

});

app.listen(PORT, () => {

    console.log(`Status API escuchando en el puerto ${PORT}`);

}); 
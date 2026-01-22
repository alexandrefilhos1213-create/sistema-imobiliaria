// TESTAR SE O BACKEND ESTÁ RESPONDENDO
const https = require('https');

const options = {
  hostname: 'sistema-imobiliaria.onrender.com',
  port: 443,
  path: '/',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
};

const req = https.request(options, (res) => {
  console.log('📊 STATUS:', res.statusCode);
  console.log('📋 HEADERS:', res.headers);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📄 RESPOSTA:', data);
  });
});

req.on('error', (e) => {
  console.error('❌ ERRO:', e.message);
});

req.end();

// TESTAR ROTA DE REGISTRO
const https = require('https');

const postData = JSON.stringify({
  nome: 'Teste Usuario',
  email: 'teste@novo.com',
  senha: '123456'
});

const options = {
  hostname: 'sistema-imobiliaria.onrender.com',
  port: 443,
  path: '/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
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
    try {
      const json = JSON.parse(data);
      console.log('📋 JSON:', json);
    } catch (e) {
      console.log('❌ ERRO AO PARSEAR JSON:', e.message);
    }
  });
});

req.on('error', (e) => {
  console.error('❌ ERRO:', e.message);
});

req.write(postData);
req.end();

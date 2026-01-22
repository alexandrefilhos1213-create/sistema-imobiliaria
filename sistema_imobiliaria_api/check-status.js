// VERIFICAR SE O BACKEND JÁ ATUALIZOU
const https = require('https');

const options = {
  hostname: 'sistema-imobiliaria.onrender.com',
  port: 443,
  path: '/',
  method: 'GET'
};

const req = https.request(options, (res) => {
  console.log('📊 STATUS:', res.statusCode);
  console.log('📅 DATE:', res.headers.date);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📄 RESPOSTA:', data);
    console.log('✅ Backend está respondendo');
  });
});

req.on('error', (e) => {
  console.error('❌ ERRO:', e.message);
});

req.end();

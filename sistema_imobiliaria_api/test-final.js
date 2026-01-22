// TESTE COM LOG DETALHADO
const https = require('https');

const postData = JSON.stringify({
  nome: 'Teste Final',
  email: 'teste@final.com',
  senha: '123456'
});

const options = {
  hostname: 'sistema-imobiliaria.onrender.com',
  port: 443,
  path: '/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData),
    'User-Agent': 'Debug-Script/1.0'
  }
};

console.log('🚀 ENVIANDO REQUISIÇÃO...');
console.log('📦 BODY:', postData);
console.log('🔗 URL:', `https://${options.hostname}${options.path}`);

const req = https.request(options, (res) => {
  console.log('\n📊 STATUS CODE:', res.statusCode);
  console.log('📋 STATUS MESSAGE:', res.statusMessage);
  console.log('📋 HEADERS:', JSON.stringify(res.headers, null, 2));
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
    console.log('📦 CHUNK RECEBIDO:', chunk.length, 'bytes');
  });
  
  res.on('end', () => {
    console.log('\n📄 RESPOSTA COMPLETA:');
    console.log('RAW:', data);
    console.log('LENGTH:', data.length);
    
    try {
      const json = JSON.parse(data);
      console.log('PARSED JSON:', JSON.stringify(json, null, 2));
    } catch (e) {
      console.log('❌ ERRO AO FAZER PARSE:', e.message);
    }
  });
});

req.on('error', (e) => {
  console.error('\n❌ ERRO DE REQUISIÇÃO:', e.message);
  console.error('STACK:', e.stack);
});

req.on('timeout', () => {
  console.error('\n⏰ TIMEOUT DA REQUISIÇÃO');
  req.destroy();
});

req.setTimeout(10000); // 10 segundos timeout
req.write(postData);
req.end();

console.log('⏳ Aguardando resposta...');

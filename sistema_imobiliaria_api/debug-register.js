// VERIFICAR LOGS DE ERRO NO REGISTER
const https = require('https');

const postData = JSON.stringify({
  nome: 'Debug Test',
  email: 'debug@teste.com',
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

console.log('🔍 Enviando requisição de teste...');
console.log('📦 Dados:', postData);

const req = https.request(options, (res) => {
  console.log('📊 STATUS:', res.statusCode);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📄 RESPOSTA BRUTA:', data);
    
    try {
      const json = JSON.parse(data);
      if (res.statusCode !== 201) {
        console.log('❌ ERRO NA API:', json);
        console.log('🔍 Possíveis causas:');
        console.log('   1. Erro de validação no backend');
        console.log('   2. Erro de conexão com banco');
        console.log('   3. Erro de sintaxe no código');
        console.log('   4. Campo faltando no INSERT');
      }
    } catch (e) {
      console.log('❌ ERRO AO PARSEAR:', e.message);
    }
  });
});

req.on('error', (e) => {
  console.error('❌ ERRO DE CONEXÃO:', e.message);
});

req.write(postData);
req.end();

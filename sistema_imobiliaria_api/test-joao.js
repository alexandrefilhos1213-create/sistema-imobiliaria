// TESTE COM EMAIL DIFERENTE
const https = require('https');

const postData = JSON.stringify({
  nome: 'João Silva',
  email: 'joao.silva@teste.com',
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
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('📄 RESPOSTA:', data);
    try {
      const json = JSON.parse(data);
      if (res.statusCode === 201) {
        console.log('✅ SUCESSO! Usuário criado:', json.usuario);
      } else {
        console.log('❌ ERRO:', json.message);
      }
    } catch (e) {
      console.log('❌ ERRO AO PARSEAR:', e.message);
    }
  });
});

req.on('error', (e) => {
  console.error('❌ ERRO:', e.message);
});

req.write(postData);
req.end();

// Testar CORS com origin do Firebase
const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Origin': 'https://sistema-imobiliaria-2026.web.app',
    'access-control-allow-origin': 'https://sistema-imobiliaria-2026.web.app',
  }
};

const req = http.request(options, (res) => {
  console.log('STATUS:', res.statusCode);
  console.log('HEADERS:', res.headers);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('BODY:', data);
  });
});

req.on('error', (e) => {
  console.error('ERRO:', e.message);
});

const testData = {
  nome: 'Teste Firebase',
  email: 'testefirebase@teste.com',
  senha: '123456'
};

req.write(JSON.stringify(testData));
req.end();

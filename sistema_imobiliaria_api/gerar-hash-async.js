// GERAR HASH PARA SENHA 123456
// Execute dentro do contexto do backend onde bcrypt está disponível

const bcrypt = require('bcrypt');

async function gerarHash() {
  const senha = '123456';
  const hash = await bcrypt.hash(senha, 10);
  
  console.log('🔑 SENHA:', senha);
  console.log('🔐 HASH GERADO:');
  console.log(hash);
  console.log('\n📋 COLE ESTE HASH NO BANCO DO RENDER!');
  console.log('\n🔧 SQL PARA EXECUTAR NO RENDER:');
  console.log(`DELETE FROM usuarios WHERE email = 'admin@sistema.com';`);
  console.log(`INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES ('Admin', 'admin@sistema.com', '${hash}', 'admin');`);
}

gerarHash();

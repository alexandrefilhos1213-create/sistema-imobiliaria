// GERAR HASH PARA SENHA 123456
const bcrypt = require('bcrypt');

const senha = '123456';
const hash = bcrypt.hashSync(senha, 10);

console.log('🔑 SENHA:', senha);
console.log('🔐 HASH GERADO:');
console.log(hash);
console.log('\n📋 COLE ESTE HASH NO BANCO DO RENDER!');

// VERIFICAR SENHA DO USUÁRIO EXISTENTE
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function verificarSenha() {
  const client = await pool.connect();
  try {
    const result = await client.query(
      'SELECT email, senha, senha_hash FROM usuarios WHERE email = $1', 
      ['teste@example.com']
    );
    
    if (result.rowCount > 0) {
      const user = result.rows[0];
      console.log('📋 Dados do usuário:');
      console.log(`Email: ${user.email}`);
      console.log(`Senha (plain): ${user.senha || 'NULL'}`);
      console.log(`Senha (hash): ${user.senha_hash ? 'EXISTS' : 'NULL'}`);
      
      if (user.senha) {
        console.log(`\n🔑 TENTE ESTA SENHA: ${user.senha}`);
      } else if (user.senha_hash) {
        console.log('\n⚠️ Usuário usa hash - não posso mostrar a senha');
        console.log('💡 Você precisa saber a senha original ou criar novo usuário');
      }
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

verificarSenha();

// CRIAR USUÁRIO DE TESTE
require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function criarUsuarioTeste() {
  const email = 'admin@sistema.com';
  const senhaHash = '$2b$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQ'; // "123456" hash
  const nome = 'Administrador Sistema';
  
  const client = await pool.connect();
  try {
    // Verificar se já existe
    const existe = await client.query('SELECT id FROM usuarios WHERE email = $1', [email]);
    
    if (existe.rowCount > 0) {
      console.log('✅ Usuário já existe!');
      console.log(`📋 Dados de acesso:`);
      console.log(`Email: ${email}`);
      console.log(`Senha: 123456`);
    } else {
      // Criar novo
      await client.query(
        'INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES ($1, $2, $3, $4)',
        [nome, email, senhaHash, 'admin']
      );
      console.log('✅ Usuário criado com sucesso!');
      console.log(`📋 Dados de acesso:`);
      console.log(`Email: ${email}`);
      console.log(`Senha: 123456`);
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

criarUsuarioTeste();

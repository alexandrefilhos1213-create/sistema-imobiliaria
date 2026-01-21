// CRIAR USUÁRIO NOVO
require('dotenv').config();
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function criarUsuario() {
  const email = 'admin@sistema.com';
  const senha = '123456';
  const nome = 'Administrador';
  
  // Hash da senha
  const senhaHash = await bcrypt.hash(senha, 10);
  
  const client = await pool.connect();
  try {
    // Verificar se já existe
    const existe = await client.query('SELECT id FROM usuarios WHERE email = $1', [email]);
    
    if (existe.rowCount > 0) {
      console.log('❌ Usuário já existe!');
      
      // Atualizar senha
      await client.query('UPDATE usuarios SET senha_hash = $1 WHERE email = $2', [senhaHash, email]);
      console.log('✅ Senha atualizada com sucesso!');
    } else {
      // Criar novo
      await client.query(
        'INSERT INTO usuarios (nome, email, senha_hash) VALUES ($1, $2, $3)',
        [nome, email, senhaHash]
      );
      console.log('✅ Usuário criado com sucesso!');
    }
    
    console.log(`📋 Dados de acesso:`);
    console.log(`Email: ${email}`);
    console.log(`Senha: ${senha}`);
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

criarUsuario();

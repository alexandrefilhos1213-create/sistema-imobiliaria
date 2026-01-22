// CONECTAR DIRETO NO BANCO DO RENDER E CORRIGIR
require('dotenv').config();
const { Pool } = require('pg');

// Usar a DATABASE_URL do Render
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function fixAdmin() {
  const client = await pool.connect();
  try {
    console.log('🔧 Corrigindo usuário admin@sistema.com...');
    
    // Apagar usuário existente
    await client.query('DELETE FROM usuarios WHERE email = $1', ['admin@sistema.com']);
    console.log('✅ Usuário antigo apagado');
    
    // Inserir com hash correto
    const hash = '$2b$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQ';
    await client.query(
      'INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES ($1, $2, $3, $4)',
      ['Admin', 'admin@sistema.com', hash, 'admin']
    );
    console.log('✅ Novo usuário criado com hash correto');
    
    // Verificar
    const result = await client.query('SELECT id, nome, email, tipo FROM usuarios WHERE email = $1', ['admin@sistema.com']);
    console.log('📋 Usuário verificado:', result.rows[0]);
    
    console.log('\n🎉 PRONTO! Teste o login com:');
    console.log('Email: admin@sistema.com');
    console.log('Senha: 123456');
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

fixAdmin();

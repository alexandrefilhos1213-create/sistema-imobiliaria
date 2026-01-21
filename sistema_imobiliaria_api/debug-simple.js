// DEBUG SIMPLES - VERIFICAR USUÁRIOS
require('dotenv').config();

const { Pool } = require('pg');

// Configuração sem SSL para debug
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function verificarUsuarios() {
  console.log('🔍 Verificando usuários no banco...');
  
  const client = await pool.connect();
  try {
    const result = await client.query('SELECT id, nome, email FROM usuarios LIMIT 5');
    
    console.log('📋 Usuários encontrados:');
    if (result.rowCount === 0) {
      console.log('❌ NENHUM usuário encontrado!');
    } else {
      result.rows.forEach((user, index) => {
        console.log(`${index + 1}. ID: ${user.id} | Nome: ${user.nome} | Email: ${user.email}`);
      });
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

verificarUsuarios();

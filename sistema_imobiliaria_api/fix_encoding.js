const { Pool } = require('pg');
require('dotenv').config();

// Configuração do pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false,
  },
  charset: 'utf8mb4',
  clientEncoding: 'UTF8'
});

async function fixEncoding() {
  console.log('🔧 Iniciando correção de encoding...');
  
  const client = await pool.connect();
  try {
    // Correção manual direta
    console.log('📝 Corrigindo manualmente...');
    
    // Corrigir "João Teste" diretamente
    await client.query("UPDATE locadores SET nome = 'João Teste' WHERE id = 1");
    console.log('🔧 Locador 1 corrigido manualmente para "João Teste"');
    
    // Verificar resultado
    const result = await client.query('SELECT id, nome FROM locadores WHERE id = 1');
    console.log('✅ Resultado final:', result.rows[0]);
    
    console.log('✅ Correção de encoding concluída com sucesso!');
    
  } catch (error) {
    console.error('❌ Erro ao corrigir encoding:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

fixEncoding();

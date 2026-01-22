// VERIFICAR QUAIS VALORES SÃO PERMITIDOS NO CAMPO TIPO
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function verificarConstraint() {
  const client = await pool.connect();
  try {
    console.log('🔍 Verificando constraint usuarios_tipo_check...');
    
    // Verificar constraints da tabela
    const constraints = await client.query(`
      SELECT 
        conname,
        pg_get_constraintdef(oid) as definition
      FROM pg_constraint 
      WHERE conrelid = 'usuarios'::regclass 
      AND contype = 'c'
    `);
    
    console.log('📋 Constraints encontradas:');
    constraints.rows.forEach(row => {
      console.log(`  ${row.conname}: ${row.definition}`);
    });
    
    // Verificar valores existentes na tabela
    const tipos = await client.query(`
      SELECT DISTINCT tipo, COUNT(*) as count 
      FROM usuarios 
      GROUP BY tipo
    `);
    
    console.log('\n📊 Tipos existentes:');
    tipos.rows.forEach(row => {
      console.log(`  ${row.tipo}: ${row.count} usuários`);
    });
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

verificarConstraint();

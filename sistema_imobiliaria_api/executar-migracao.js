const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

async function migrar() {
  const client = await pool.connect();
  try {
    console.log('🔧 Executando migração...');
    
    // Adicionar usuario_id nas tabelas
    await client.query('ALTER TABLE imoveis ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id)');
    await client.query('ALTER TABLE locadores ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id)');
    await client.query('ALTER TABLE locatarios ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id)');
    
    console.log('✅ Colunas usuario_id adicionadas');
    
    // Atualizar registros existentes
    await client.query('UPDATE imoveis SET usuario_id = 6 WHERE usuario_id IS NULL');
    await client.query('UPDATE locadores SET usuario_id = 6 WHERE usuario_id IS NULL');
    await client.query('UPDATE locatarios SET usuario_id = 6 WHERE usuario_id IS NULL');
    
    console.log('✅ Registros existentes associados ao admin');
    
    // Verificar resultado
    const result = await client.query(`
      SELECT 'imoveis' as tabela, COUNT(*) as total, COUNT(usuario_id) as com_usuario_id FROM imoveis
      UNION ALL
      SELECT 'locadores' as tabela, COUNT(*) as total, COUNT(usuario_id) as com_usuario_id FROM locadores  
      UNION ALL
      SELECT 'locatarios' as tabela, COUNT(*) as total, COUNT(usuario_id) as com_usuario_id FROM locatarios
    `);
    
    console.log('📊 Resultado da migração:');
    result.rows.forEach(row => {
      console.log(`${row.tabela}: ${row.total} registros, ${row.com_usuario_id} com usuario_id`);
    });
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

migrar();

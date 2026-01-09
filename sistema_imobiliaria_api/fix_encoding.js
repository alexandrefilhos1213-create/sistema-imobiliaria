const { Pool } = require('pg');

const pool = new Pool({
  connectionString: 'postgresql://neondb_owner:npg_zmDaHUEi16Og@ep-broad-wave-acyebsqf-pooler.sa-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require',
  charset: 'utf8',
  clientEncoding: 'utf8'
});

async function fixEncoding() {
  const client = await pool.connect();
  try {
    await client.query("UPDATE locadores SET nome = 'João Teste' WHERE id = 1");
    console.log('Encoding corrigido!');
    
    const result = await client.query('SELECT id, nome FROM locadores WHERE id = 1');
    console.log('Resultado:', result.rows[0]);
  } finally {
    client.release();
  }
  await pool.end();
}

fixEncoding();

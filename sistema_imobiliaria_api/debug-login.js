// SCRIPT PARA DEBUGAR LOGIN
// Execute no terminal do backend: node debug-login.js

const { Pool } = require('pg');

// Configuração do banco (mesma do server.js)
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function debugLogin() {
  console.log('🔍 DEBUG: Verificando usuários no banco...');
  
  const client = await pool.connect();
  try {
    // Listar todos os usuários
    const result = await client.query('SELECT id, nome, email, senha, senha_hash FROM usuarios LIMIT 10');
    
    console.log('📋 Usuários encontrados:');
    result.rows.forEach((user, index) => {
      console.log(`${index + 1}. ID: ${user.id}`);
      console.log(`   Nome: ${user.nome}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Tem senha_hash: ${user.senha_hash ? 'SIM' : 'NÃO'}`);
      console.log(`   Senha (plain): ${user.senha ? 'EXISTS' : 'NULL'}`);
      console.log('---');
    });
    
    // Testar busca específica
    console.log('\n🔍 Testando busca por email específico:');
    const testEmail = 'seuemail@aqui.com'; // << TROQUE PELO EMAIL QUE ESTÁ USANDO
    const searchResult = await client.query('SELECT * FROM usuarios WHERE email = $1', [testEmail]);
    
    console.log(`Buscando por: "${testEmail}"`);
    console.log(`Resultados: ${searchResult.rowCount}`);
    
    if (searchResult.rowCount > 0) {
      const user = searchResult.rows[0];
      console.log('Usuário encontrado:', {
        id: user.id,
        nome: user.nome,
        email: user.email,
        temHash: !!user.senha_hash,
        temSenhaPlain: !!user.senha
      });
    }
    
  } catch (error) {
    console.error('❌ Erro:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

debugLogin();

# 🔐 Guia de Migração de Senhas para Hash

## 📋 Situação Atual

O sistema agora suporta **ambos os formatos** de senha:
- ✅ **Senhas antigas**: Texto plano (compatibilidade retroativa)
- ✅ **Senhas novas**: Hash bcrypt (seguro)

## 🎯 Objetivo

Migrar todas as senhas do banco de dados de texto plano para hash bcrypt.

## 📝 Passo a Passo

### 1. Verificar Estrutura do Banco

Primeiro, verifique se a tabela de usuários tem a coluna `senha_hash`:

```sql
-- Verificar estrutura da tabela
\d usuarios

-- Se não existir, adicionar coluna
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS senha_hash VARCHAR(255);
```

### 2. Script de Migração

Execute este script Node.js para migrar todas as senhas:

```javascript
require('dotenv').config();
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_URL ? { rejectUnauthorized: false } : false
});

async function migrarSenhas() {
  const client = await pool.connect();
  
  try {
    // Buscar todos os usuários com senha em texto plano
    const result = await client.query(`
      SELECT id, senha 
      FROM usuarios 
      WHERE senha_hash IS NULL 
      AND senha IS NOT NULL
    `);
    
    console.log(`Encontrados ${result.rows.length} usuários para migrar`);
    
    for (const usuario of result.rows) {
      try {
        // Gerar hash da senha
        const senhaHash = await bcrypt.hash(usuario.senha, 10);
        
        // Atualizar no banco
        await client.query(
          'UPDATE usuarios SET senha_hash = $1 WHERE id = $2',
          [senhaHash, usuario.id]
        );
        
        console.log(`✓ Usuário ${usuario.id} migrado com sucesso`);
      } catch (error) {
        console.error(`✗ Erro ao migrar usuário ${usuario.id}:`, error.message);
      }
    }
    
    console.log('\n✅ Migração concluída!');
  } finally {
    client.release();
    await pool.end();
  }
}

migrarSenhas().catch(console.error);
```

### 3. Executar Migração

```bash
# Salvar o script acima como migrate-passwords.js
node migrate-passwords.js
```

### 4. Verificar Migração

```sql
-- Verificar quantos usuários ainda têm senha em texto plano
SELECT COUNT(*) 
FROM usuarios 
WHERE senha_hash IS NULL 
AND senha IS NOT NULL;

-- Deve retornar 0 após migração completa
```

### 5. (Opcional) Remover Coluna de Senha Antiga

**⚠️ ATENÇÃO**: Só faça isso após confirmar que TODOS os usuários migraram e estão conseguindo fazer login!

```sql
-- Primeiro, fazer backup
CREATE TABLE usuarios_backup AS SELECT * FROM usuarios;

-- Depois, remover coluna antiga (se desejar)
-- ALTER TABLE usuarios DROP COLUMN senha;
```

## 🔄 Compatibilidade

O sistema continuará funcionando durante a migração:
- Usuários com `senha_hash` → Login com bcrypt
- Usuários sem `senha_hash` → Login com texto plano (compatibilidade)

## ⚠️ Importante

1. **Faça backup** do banco antes de migrar
2. **Teste** a migração em ambiente de desenvolvimento primeiro
3. **Comunique** os usuários sobre possível necessidade de redefinir senha
4. **Monitore** logs após migração para garantir que logins funcionam

## 🎯 Após Migração

Após migrar todas as senhas:
1. O sistema automaticamente usará apenas bcrypt
2. Novos usuários terão senha hash desde o início
3. Você pode remover a lógica de compatibilidade retroativa (opcional)

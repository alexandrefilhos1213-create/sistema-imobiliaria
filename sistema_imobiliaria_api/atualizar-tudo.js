const fs = require('fs');

// Ler o arquivo atual
let content = fs.readFileSync('./src/server.js', 'utf8');

// 1. Adicionar usuario_id nos INSERTs de locatarios
content = content.replace(
  `INSERT INTO locatarios (
          nome, cpf, rg, estado_civil, profissao, endereco,
          email, telefone, data_nascimento, renda, referencia,
          referencia_comercial, fiador, fiador_cpf
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING *`,
  `INSERT INTO locatarios (
          nome, cpf, rg, estado_civil, profissao, endereco,
          email, telefone, data_nascimento, renda, referencia,
          referencia_comercial, fiador, fiador_cpf, usuario_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15) RETURNING *`
);

// 2. Adicionar usuario_id nos dados sanitizados de locatarios
content = content.replace(
  `referencia: referencia ? sanitizeString(referencia) : null,
      referenciaComercial: referenciaComercial ? sanitizeString(referenciaComercial) : null,
      fiador: fiador ? sanitizeString(fiador) : null,
      fiadorCpf: fiadorCpf ? sanitizeString(fiadorCpf) : null
    };`,
  `referencia: referencia ? sanitizeString(referencia) : null,
      referenciaComercial: referenciaComercial ? sanitizeString(referenciaComercial) : null,
      fiador: fiador ? sanitizeString(fiador) : null,
      fiadorCpf: fiadorCpf ? sanitizeString(fiadorCpf) : null,
      usuario_id: usuarioId
    };`
);

// 3. Adicionar usuario_id no array de valores de locatarios
content = content.replace(
  `sanitizedData.referencia,
          sanitizedData.referenciaComercial,
          sanitizedData.fiador,
          sanitizedData.fiadorCpf
        ]`,
  `sanitizedData.referencia,
          sanitizedData.referenciaComercial,
          sanitizedData.fiador,
          sanitizedData.fiadorCpf,
          sanitizedData.usuario_id
        ]`
);

// Salvar o arquivo atualizado
fs.writeFileSync('./src/server.js', content);

console.log('✅ Locatários atualizados com usuario_id!');

// Agora vamos atualizar os imóveis
content = fs.readFileSync('./src/server.js', 'utf8');

// Encontrar e atualizar POST /imoveis
const postImoveisPattern = /app\.post\('\/imoveis', authenticateToken, strictLimiter, async \(req, res\) => \{[\s\S]*?\}\);/;
const postImoveisMatch = content.match(postImoveisPattern);

if (postImoveisMatch) {
  let postImoveisContent = postImoveisMatch[0];
  
  // Adicionar usuario_id
  postImoveisContent = postImoveisContent.replace(
    `} = req.body || {};`,
    `} = req.body || {};

    // Obter usuario_id do token
    const usuarioId = req.user?.userId;`
  );
  
  postImoveisContent = postImoveisContent.replace(
    `validateRequired(tipo, 'tipo');`,
    `validateRequired(tipo, 'tipo');
      validateRequired(usuarioId, 'usuario_id');`
  );
  
  content = content.replace(postImoveisPattern, postImoveisContent);
}

// Atualizar GET /locatarios para filtrar por usuario_id
content = content.replace(
  `// GET - Listar todos os locatários (com paginação)
// Rota pública - não requer autenticação para listar
app.get('/locatarios', async (req, res) => {`,
  `// GET - Listar locatários do usuário (com paginação)
app.get('/locatarios', authenticateToken, async (req, res) => {`
);

content = content.replace(
  `// Contar total de registros
      const countResult = await client.query('SELECT COUNT(*) FROM locatarios');
      const total = parseInt(countResult.rows[0].count);

      // Buscar registros paginados
      const result = await client.query(
        'SELECT * FROM locatarios ORDER BY nome LIMIT $1 OFFSET $2',
        [validLimit, offset]
      );`,
  `// Obter usuario_id do token
      const usuarioId = req.user?.userId;

      // Contar total de registros do usuário
      const countResult = await client.query(
        'SELECT COUNT(*) FROM locatarios WHERE usuario_id = $1',
        [usuarioId]
      );
      const total = parseInt(countResult.rows[0].count);

      // Buscar registros paginados do usuário
      const result = await client.query(
        'SELECT * FROM locatarios WHERE usuario_id = $1 ORDER BY nome LIMIT $2 OFFSET $3',
        [usuarioId, validLimit, offset]
      );`
);

// Salvar novamente
fs.writeFileSync('./src/server.js', content);

console.log('✅ Imóveis e Locatários atualizados!');
console.log('🚀 Execute "git add . && git commit -m feat: isolamento de dados por usuario_id && git push"');

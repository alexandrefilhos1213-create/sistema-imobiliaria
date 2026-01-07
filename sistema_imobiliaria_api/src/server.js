require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();

app.use(cors());
app.use(express.json());

const {
  PORT = 3000,
  DATABASE_URL,
  DB_HOST,
  DB_PORT,
  DB_USER,
  DB_PASSWORD,
  DB_DATABASE,
  USERS_TABLE = 'usuarios',
  USER_LOGIN_FIELD = 'email',
  USER_PASSWORD_FIELD = 'senha',
} = process.env;

if (!DB_HOST || !DB_USER || !DB_DATABASE) {
  console.warn('ATENÇÃO: Variáveis de banco (DB_HOST, DB_USER, DB_DATABASE) não estão totalmente configuradas no .env.');
}

let poolConfig;

if (DATABASE_URL) {
  // Usa URL completa (como Neon) se estiver disponível
  poolConfig = {
    connectionString: DATABASE_URL,
    ssl: {
      rejectUnauthorized: false,
    },
  };
} else {
  // Fallback para configuração manual por host/porta
  poolConfig = {
    host: DB_HOST || 'localhost',
    port: DB_PORT ? Number(DB_PORT) : 5432,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_DATABASE,
  };
}

const pool = new Pool(poolConfig);

// Middleware de logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'API sistema_imobiliaria_api rodando' });
});

app.post('/login', async (req, res) => {
  try {
    const { email, usuario, senha } = req.body || {};

    if (!senha || (!email && !usuario)) {
      return res.status(400).json({
        success: false,
        message: 'Informe usuário/email e senha.',
      });
    }

    const loginValue = email || usuario;

    const client = await pool.connect();
    try {
      const queryText = `SELECT id, nome, ${USER_LOGIN_FIELD} AS login, ${USER_PASSWORD_FIELD} AS senha
                         FROM ${USERS_TABLE}
                         WHERE ${USER_LOGIN_FIELD} = $1
                         LIMIT 1`;

      const result = await client.query(queryText, [loginValue]);

      if (result.rowCount === 0) {
        return res.status(401).json({
          success: false,
          message: 'Credenciais inválidas.',
        });
      }

      const usuarioDB = result.rows[0];

      // TODO: Implementar hash de senha (bcrypt) em produção
      // Por enquanto, mantemos comparação direta para compatibilidade
      if (usuarioDB.senha !== senha) {
        return res.status(401).json({
          success: false,
          message: 'Credenciais inválidas.',
        });
      }

      // TODO: Implementar JWT em produção
      return res.json({
        success: true,
        token: 'temp-token-${Date.now()}-${usuarioDB.id}',
        usuario: {
          id: usuarioDB.id,
          nome: usuarioDB.nome,
          login: usuarioDB.login,
        },
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro na rota /login:', error);
    return res.status(500).json({
      success: false,
      message: 'Erro interno no servidor.',
    });
  }
});

// GET - Listar todos os locadores
app.get('/locadores', async (req, res) => {
  try {
    const client = await pool.connect();
    try {
      const result = await client.query('SELECT * FROM locadores ORDER BY nome');
      res.json({
        success: true,
        data: result.rows,
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao listar locadores:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao listar locadores',
    });
  }
});

// POST - Criar locador
app.post('/locadores', async (req, res) => {
  try {
    console.log('=== DEBUG BACKEND: Recebendo requisição POST /locadores ===');
    console.log('Body recebido:', JSON.stringify(req.body, null, 2));
    
    const { 
      nome, 
      cpf, 
      rg, 
      estado_civil, 
      profissao, 
      endereco,
      dataNascimento,
      renda,
      cnh,
      email,
      telefone,
      referencia
    } = req.body || {};

    console.log('Dados extraídos:', { nome, cpf, rg, estado_civil, profissao, endereco, dataNascimento, renda, cnh, email, telefone, referencia });

    if (!nome || !cpf) {
      console.log('ERRO: Nome ou CPF ausentes');
      return res.status(400).json({
        success: false,
        message: 'Nome e CPF são obrigatórios',
      });
    }

    const client = await pool.connect();
    try {
      const result = await client.query(
        `INSERT INTO locadores (
          nome, cpf, rg, estado_civil, profissao, endereco,
          data_nascimento, renda, cnh, email, telefone, referencia
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12) RETURNING *`,
        [
          nome, cpf, rg, estado_civil, profissao, endereco,
          dataNascimento, renda, cnh, email, telefone, referencia
        ]
      );

      console.log('Locador criado com sucesso:', result.rows[0]);
      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.log('=== ERRO DETALHADO AO CRIAR LOCADOR ===');
    console.log('Erro completo:', error);
    console.log('Mensagem:', error.message);
    console.log('Stack:', error.stack);
    console.log('=== FIM ERRO ===');
    
    console.error('Erro ao criar locador:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar locador',
    });
  }
});

// PUT - Atualizar locador
app.put('/locadores/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, cpf, rg, estado_civil, profissao, endereco } = req.body || {};

    const client = await pool.connect();
    try {
      const result = await client.query(
        'UPDATE locadores SET nome = $1, cpf = $2, rg = $3, estado_civil = $4, profissao = $5, endereco = $6 WHERE id = $7 RETURNING *',
        [nome, cpf, rg, estado_civil, profissao, endereco, id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locador não encontrado',
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao atualizar locador:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar locador',
    });
  }
});

// DELETE - Excluir locador
app.delete('/locadores/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query('DELETE FROM locadores WHERE id = $1', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locador não encontrado',
        });
      }

      res.json({
        success: true,
        message: 'Locador excluído com sucesso',
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao excluir locador:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao excluir locador',
    });
  }
});

// GET - Obter locador por ID
app.get('/locadores/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query('SELECT * FROM locadores WHERE id = $1', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locador não encontrado',
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao obter locador:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter locador',
    });
  }
});

// GET - Listar todos os locatários
app.get('/locatarios', async (req, res) => {
  try {
    const client = await pool.connect();
    try {
      const result = await client.query('SELECT * FROM locatarios ORDER BY nome');
      res.json({
        success: true,
        data: result.rows,
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao listar locatários:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao listar locatários',
    });
  }
});

// POST - Criar locatário
app.post('/locatarios', async (req, res) => {
  try {
    const { 
      nome, 
      cpf, 
      rg, 
      estado_civil, 
      profissao, 
      endereco, 
      email, 
      telefone,
      dataNascimento,
      renda,
      referencia,
      referenciaComercial,
      fiador,
      fiadorCpf
    } = req.body || {};

    if (!nome || !cpf) {
      return res.status(400).json({
        success: false,
        message: 'Nome e CPF são obrigatórios',
      });
    }

    const client = await pool.connect();
    try {
      const result = await client.query(
        `INSERT INTO locatarios (
          nome, cpf, rg, estado_civil, profissao, endereco, 
          email, telefone, data_nascimento, renda, referencia, 
          referencia_comercial, fiador, fiador_cpf
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING *`,
        [
          nome, cpf, rg, estado_civil, profissao, endereco, 
          email, telefone, dataNascimento, renda, referencia, 
          referenciaComercial, fiador, fiadorCpf
        ]
      );

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao criar locatário:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar locatário',
    });
  }
});

// PUT - Atualizar locatário
app.put('/locatarios/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, cpf, rg, estado_civil, profissao, endereco, email, telefone } = req.body || {};

    const client = await pool.connect();
    try {
      const result = await client.query(
        'UPDATE locatarios SET nome = $1, cpf = $2, rg = $3, estado_civil = $4, profissao = $5, endereco = $6, email = $7, telefone = $8 WHERE id = $9 RETURNING *',
        [nome, cpf, rg, estado_civil, profissao, endereco, email, telefone, id]
      );

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locatário não encontrado',
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao atualizar locatário:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar locatário',
    });
  }
});

// DELETE - Excluir locatário
app.delete('/locatarios/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query('DELETE FROM locatarios WHERE id = $1', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locatário não encontrado',
        });
      }

      res.json({
        success: true,
        message: 'Locatário excluído com sucesso',
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao excluir locatário:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao excluir locatário',
    });
  }
});

// GET - Obter locatário por ID
app.get('/locatarios/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query('SELECT * FROM locatarios WHERE id = $1', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locatário não encontrado',
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao obter locatário:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter locatário',
    });
  }
});

// GET - Listar todos os imóveis
app.get('/imoveis', async (req, res) => {
  try {
    const client = await pool.connect();
    try {
      const result = await client.query(`
        SELECT i.*, l.nome as locador_nome, lt.nome as locatario_nome
        FROM imoveis i
        LEFT JOIN locadores l ON i.id_locador = l.id
        LEFT JOIN locatarios lt ON i.id_locatario = lt.id
        ORDER BY i.endereco
      `);
      res.json({
        success: true,
        data: result.rows,
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao listar imóveis:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao listar imóveis',
    });
  }
});

// POST - Criar imóvel
app.post('/imoveis', async (req, res) => {
  try {
    const { 
      endereco, tipo, descricao, cadastro_iptu,
      unidade_consumidora_numero, unidade_consumidora_titular, unidade_consumidora_cpf,
      saneago_numero_conta, saneago_titular, saneago_cpf,
      gas_numero_conta, gas_titular, gas_cpf,
      condominio_titular, condominio_valor_estimado, id_locador, id_locatario
    } = req.body || {};

    if (!endereco || !tipo || !id_locador) {
      return res.status(400).json({
        success: false,
        message: 'Endereço, tipo e ID do locador são obrigatórios',
      });
    }

    const client = await pool.connect();
    try {
      const result = await client.query(`
        INSERT INTO imoveis (
          endereco, tipo, descricao, cadastro_iptu, 
          unidade_consumidora_numero, unidade_consumidora_titular, unidade_consumidora_cpf,
          saneago_numero_conta, saneago_titular, saneago_cpf,
          gas_numero_conta, gas_titular, gas_cpf,
          condominio_titular, condominio_valor_estimado, id_locador, id_locatario
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17)
        RETURNING *
      `, [
        endereco, tipo, descricao, cadastro_iptu,
        unidade_consumidora_numero, unidade_consumidora_titular, unidade_consumidora_cpf,
        saneago_numero_conta, saneago_titular, saneago_cpf,
        gas_numero_conta, gas_titular, gas_cpf,
        condominio_titular, condominio_valor_estimado, id_locador, id_locatario
      ]);

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao criar imóvel:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar imóvel',
    });
  }
});

// PUT - Atualizar imóvel
app.put('/imoveis/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { 
      endereco, tipo, descricao, cadastro_iptu,
      unidade_consumidora_numero, unidade_consumidora_titular, unidade_consumidora_cpf,
      saneago_numero_conta, saneago_titular, saneago_cpf,
      gas_numero_conta, gas_titular, gas_cpf,
      condominio_titular, condominio_valor_estimado, id_locador, id_locatario
    } = req.body || {};

    const client = await pool.connect();
    try {
      const result = await client.query(`
        UPDATE imoveis SET 
          endereco = $1, tipo = $2, descricao = $3, cadastro_iptu = $4,
          unidade_consumidora_numero = $5, unidade_consumidora_titular = $6, unidade_consumidora_cpf = $7,
          saneago_numero_conta = $8, saneago_titular = $9, saneago_cpf = $10,
          gas_numero_conta = $11, gas_titular = $12, gas_cpf = $13,
          condominio_titular = $14, condominio_valor_estimado = $15, id_locador = $16, id_locatario = $17
        WHERE id = $18
        RETURNING *
      `, [
        endereco, tipo, descricao, cadastro_iptu,
        unidade_consumidora_numero, unidade_consumidora_titular, unidade_consumidora_cpf,
        saneago_numero_conta, saneago_titular, saneago_cpf,
        gas_numero_conta, gas_titular, gas_cpf,
        condominio_titular, condominio_valor_estimado, id_locador, id_locatario, id
      ]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Imóvel não encontrado',
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao atualizar imóvel:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao atualizar imóvel',
    });
  }
});

// DELETE - Excluir imóvel
app.delete('/imoveis/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query('DELETE FROM imoveis WHERE id = $1', [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Imóvel não encontrado',
        });
      }

      res.json({
        success: true,
        message: 'Imóvel excluído com sucesso',
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao excluir imóvel:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao excluir imóvel',
    });
  }
});

// GET - Obter imóvel por ID
app.get('/imoveis/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query(`
        SELECT i.*, l.nome as locador_nome, lt.nome as locatario_nome
        FROM imoveis i
        LEFT JOIN locadores l ON i.id_locador = l.id
        LEFT JOIN locatarios lt ON i.id_locatario = lt.id
        WHERE i.id = $1
      `, [id]);

      if (result.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Imóvel não encontrado',
        });
      }

      res.json({
        success: true,
        data: result.rows[0],
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao obter imóvel:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter imóvel',
    });
  }
});

// GET - Estatísticas
app.get('/estatisticas', async (req, res) => {
  try {
    const client = await pool.connect();
    try {
      const locadoresResult = await client.query('SELECT COUNT(*) FROM locadores');
      const locatariosResult = await client.query('SELECT COUNT(*) FROM locatarios');
      const imoveisResult = await client.query('SELECT COUNT(*) FROM imoveis');

      res.json({
        success: true,
        data: {
          locadores: parseInt(locadoresResult.rows[0].count),
          locatarios: parseInt(locatariosResult.rows[0].count),
          imoveis: parseInt(imoveisResult.rows[0].count),
        },
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao obter estatísticas:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao obter estatísticas',
    });
  }
});

// Middleware de tratamento de erros global
app.use((error, req, res, next) => {
  console.error('Erro não tratado:', error);
  res.status(500).json({
    success: false,
    message: 'Erro interno no servidor',
  });
});

// Middleware para rotas não encontradas
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Rota não encontrada',
  });
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
  console.log(`Database: ${DATABASE_URL ? 'Neon (URL)' : `${DB_HOST}:${DB_PORT}/${DB_DATABASE}`}`);
});


require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();

// CORS configurado com origens explícitas (obrigatório para credentials: true)
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:8080',
  'http://localhost:5000',
  'https://sistema-imobiliaria-2026.web.app',
  'https://sistema-imobiliaria-2026.firebaseapp.com',
  'https://sistema-imobiliaria.onrender.com'
];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }

    return callback(new Error('Não permitido pelo CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));

// Compressão de respostas
const compression = require('compression');
app.use(compression());

// Rate limiting
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requisições por IP
  message: {
    success: false,
    message: 'Muitas requisições deste IP, tente novamente mais tarde.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10, // máximo 10 requisições para rotas críticas
  message: {
    success: false,
    message: 'Muitas tentativas. Tente novamente mais tarde.'
  }
});

app.use('/api/', limiter);
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Validator para validação de dados
const validator = require('validator');

// Configurar pasta de uploads
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configurar multer para upload de imagens
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB por imagem
    files: 20 // máximo 20 arquivos por requisição
  },
  fileFilter: (req, file, cb) => {
    // Validar extensão
    const allowedExtensions = ['.jpeg', '.jpg', '.png', '.gif', '.webp'];
    const ext = path.extname(file.originalname).toLowerCase();
    
    // Validar mimetype
    const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    
    if (allowedExtensions.includes(ext) && allowedMimeTypes.includes(file.mimetype)) {
      // Validar que o arquivo não seja vazio
      if (file.size === 0) {
        return cb(new Error('Arquivo vazio não é permitido'));
      }
      return cb(null, true);
    } else {
      cb(new Error(`Tipo de arquivo não permitido. Apenas imagens são aceitas (JPEG, JPG, PNG, GIF, WebP). Recebido: ${file.mimetype}`));
    }
  }
});

// Servir arquivos estáticos da pasta uploads
app.use('/uploads', express.static(uploadsDir));

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
    ssl: process.env.NODE_ENV === 'production' ? {
      rejectUnauthorized: false,
    } : false, // Desabilitar SSL em desenvolvimento
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

const pool = new Pool({
  ...poolConfig,
  charset: 'utf8mb4',
  clientEncoding: 'UTF8',
  encoding: 'utf8',
  application_name: 'sistema_imobiliaria_api'
});

// Funções de validação
function validateCPF(cpf) {
  if (!cpf) return false;
  // Remove caracteres não numéricos
  const cleanCPF = cpf.replace(/\D/g, '');
  // Valida tamanho (11 dígitos) ou formato com máscara (14 caracteres)
  return cleanCPF.length === 11 || cpf.length <= 14;
}

function validateEmail(email) {
  return email ? validator.isEmail(email) : true; // Email opcional
}

function validateRequired(value, fieldName) {
  if (!value || (typeof value === 'string' && value.trim() === '')) {
    throw new Error(`Campo obrigatório: ${fieldName}`);
  }
}

function sanitizeString(str) {
  if (!str) return str;
  return validator.escape(str.trim());
}

// Middleware de logging (sem dados sensíveis)
app.use((req, res, next) => {
  const logData = {
    timestamp: new Date().toISOString(),
    method: req.method,
    path: req.path,
    ip: req.ip
  };
  console.log(JSON.stringify(logData));
  next();
});

// Middleware para forçar UTF-8
app.use((req, res, next) => {
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  next();
});

// Função para corrigir encoding UTF-8 de forma mais robusta
function fixUTF8Encoding(text) {
  if (!text || typeof text !== 'string') return text;
  
  try {
    // Tentar detectar se já está em UTF-8 válido
    const utf8Bytes = Buffer.from(text, 'utf8');
    const originalBytes = Buffer.from(text, 'latin1');
    
    // Se os bytes são idênticos, provavelmente já está correto
    if (utf8Bytes.equals(originalBytes)) {
      return text;
    }
    
    // Tentar converter de latin1 para utf8
    return Buffer.from(text, 'latin1').toString('utf8');
  } catch (error) {
    // Se falhar, retornar original
    console.warn('Erro ao corrigir encoding:', error.message);
    return text;
  }
}

// Função para corrigir encoding em objetos recursivamente
function fixObjectEncoding(obj) {
  if (!obj) return obj;
  
  // Strings
  if (typeof obj === 'string') {
    return fixUTF8Encoding(obj);
  }
  
  // Arrays
  if (Array.isArray(obj)) {
    return obj.map(item => fixObjectEncoding(item));
  }
  
  // Objetos
  if (typeof obj === 'object' && obj.constructor === Object) {
    const fixed = {};
    for (const [key, value] of Object.entries(obj)) {
      fixed[key] = fixObjectEncoding(value);
    }
    return fixed;
  }
  
  // Tipos primitivos ou objetos complexos (Date, etc)
  return obj;
}

// Configuração JWT
const JWT_SECRET = process.env.JWT_SECRET || 'sua-chave-secreta-super-segura-mude-em-producao-minimo-32-caracteres';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '24h';

// Middleware de autenticação JWT
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // "Bearer TOKEN"

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Token de autenticação não fornecido. Faça login primeiro.',
    });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Token expirado. Faça login novamente.',
        });
      }
      return res.status(403).json({
        success: false,
        message: 'Token inválido ou corrompido.',
      });
    }

    // Adiciona dados do usuário na requisição
    req.user = decoded;
    next(); // Continua para a próxima função
  });
}

// Middleware opcional - tenta autenticar mas não bloqueia se não tiver token
// Útil para rotas que funcionam com ou sem autenticação
function optionalAuthenticate(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token) {
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
      if (!err) {
        req.user = decoded;
      }
      next();
    });
  } else {
    next();
  }
}

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'API sistema_imobiliaria_api rodando' });
});

app.post('/login', async (req, res) => {
  try {
    console.log('=== DEBUG LOGIN ===');
    console.log('REQ BODY:', req.body);
    console.log('REQ HEADERS:', req.headers);
    
    const { email, usuario, senha } = req.body || {};
    
    // Normalizar email
    const emailNormalizado = (email || usuario)?.trim().toLowerCase();
    console.log('EMAIL NORMALIZADO:', emailNormalizado);
    console.log('SENHA RECEBIDA:', senha ? '***' : 'NULL/VAZIA');

    if (!senha || !emailNormalizado) {
      return res.status(400).json({
        success: false,
        message: 'Informe usuário/email e senha.',
      });
    }

    const loginValue = emailNormalizado;

    const client = await pool.connect();
    try {
      // Buscar usuário - apenas senha_hash (sistema novo)
      const queryText = `SELECT 
                          id, 
                          nome, 
                          ${USER_LOGIN_FIELD} AS login, 
                          senha_hash
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
      let senhaValida = false;

      console.log('USUÁRIO ENCONTRADO:', {
        id: usuarioDB.id,
        nome: usuarioDB.nome,
        email: usuarioDB.email,
        temHash: !!usuarioDB.senha_hash
      });

      // Sistema novo: sempre usar bcrypt
      if (usuarioDB.senha_hash) {
        try {
          console.log('COMPARANDO SENHA COM BCRYPT...');
          senhaValida = await bcrypt.compare(senha, usuarioDB.senha_hash);
          console.log('RESULTADO BCRYPT:', senhaValida);
        } catch (bcryptError) {
          console.error('Erro ao comparar senha com bcrypt:', bcryptError.message);
          return res.status(500).json({
            success: false,
            message: 'Erro ao validar credenciais.',
          });
        }
      } else {
        console.log('❌ USUÁRIO SEM SENHA_HASH!');
        return res.status(401).json({
          success: false,
          message: 'Usuário sem senha cadastrada.',
        });
      }

      if (!senhaValida) {
        return res.status(401).json({
          success: false,
          message: 'Credenciais inválidas.',
        });
      }

      // Gerar token JWT
      const tokenPayload = {
        userId: usuarioDB.id,
        email: usuarioDB.login,
        nome: usuarioDB.nome,
      };

      const token = jwt.sign(tokenPayload, JWT_SECRET, {
        expiresIn: JWT_EXPIRES_IN,
      });

      return res.json({
        success: true,
        token: token,
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
    console.error('Erro na rota /login:', error.message);
    return res.status(500).json({
      success: false,
      message: 'Erro interno no servidor.',
    });
  }
});

// POST - Registrar novo usuário (HOTFIX SIMPLIFICADO)
app.post('/register', async (req, res) => {
  try {
    console.log('=== REGISTER HOTFIX ===');
    console.log('BODY:', req.body);
    
    const { nome, email, senha } = req.body;
    
    if (!nome || !email || !senha) {
      return res.status(400).json({
        success: false,
        message: 'Campos obrigatórios faltando'
      });
    }
    
    const client = await pool.connect();
    try {
      // Verificar duplicado
      const check = await client.query(
        'SELECT id FROM usuarios WHERE email = $1',
        [email.toLowerCase()]
      );
      
      if (check.rowCount > 0) {
        return res.status(400).json({
          success: false,
          message: 'Email já existe'
        });
      }
      
      // Hash senha
      const hash = await bcrypt.hash(senha, 10);
      
      // Inserir
      const result = await client.query(
        'INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES ($1, $2, $3, $4) RETURNING id, nome, email',
        [nome, email.toLowerCase(), hash, 'usuario']
      );
      
      res.status(201).json({
        success: true,
        message: 'Usuário criado!',
        usuario: result.rows[0]
      });
      
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('ERRO REGISTER:', error.message);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// GET - Listar locadores do usuário (com paginação)
app.get('/locadores', authenticateToken, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;

    // Obter usuario_id do token
    const usuarioId = req.user?.userId;

    // Validar limites
    const validLimit = Math.min(Math.max(limit, 1), 100); // Entre 1 e 100
    const validPage = Math.max(page, 1);

    const client = await pool.connect();
    try {
      // Contar total de registros do usuário
      const countResult = await client.query(
        'SELECT COUNT(*) FROM locadores WHERE usuario_id = $1',
        [usuarioId]
      );
      const total = parseInt(countResult.rows[0].count);

      // Buscar registros paginados do usuário
      const result = await client.query(
        'SELECT * FROM locadores WHERE usuario_id = $1 ORDER BY nome LIMIT $2 OFFSET $3',
        [usuarioId, validLimit, offset]
      );

      res.json({
        success: true,
        data: fixObjectEncoding(result.rows),
        pagination: {
          page: validPage,
          limit: validLimit,
          total,
          totalPages: Math.ceil(total / validLimit)
        }
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao listar locadores:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao listar locadores',
    });
  }
});

// POST - Criar locador (requer autenticação)
app.post('/locadores', authenticateToken, strictLimiter, async (req, res) => {
  try {
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

    // Obter usuario_id do token
    const usuarioId = req.user?.userId;

    // Validação de CPF (simples)
    if (!cpf || cpf.length < 11) {
      return res.status(400).json({
        success: false,
        message: 'CPF inválido',
      });
    }

    if (cpf.length > 14) {
      return res.status(400).json({
        success: false,
        message: 'CPF deve ter no máximo 14 caracteres',
      });
    }

    // Validação de email (simples)
    if (email && !email.includes('@')) {
      return res.status(400).json({
        success: false,
        message: 'Email inválido',
      });
    }

    // Sanitização simples
    const sanitizedData = {
      nome: nome?.trim() || '',
      cpf: cpf?.trim() || '',
      rg: rg?.trim() || null,
      estado_civil: estado_civil?.trim() || null,
      profissao: profissao?.trim() || null,
      endereco: endereco?.trim() || null,
      dataNascimento: dataNascimento || null,
      renda: renda || null,
      cnh: cnh?.trim() || null,
      email: email?.trim().toLowerCase() || null,
      telefone: telefone?.trim() || null,
      referencia: referencia?.trim() || null,
      usuario_id: usuarioId
    };

    const client = await pool.connect();
    try {
      const result = await client.query(
        `INSERT INTO locadores (
          nome, cpf, rg, estado_civil, profissao, endereco,
          data_nascimento, renda, cnh, email, telefone, referencia, usuario_id
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING *`,
        [
          sanitizedData.nome, 
          sanitizedData.cpf, 
          sanitizedData.rg, 
          sanitizedData.estado_civil, 
          sanitizedData.profissao, 
          sanitizedData.endereco,
          sanitizedData.dataNascimento, 
          sanitizedData.renda, 
          sanitizedData.cnh, 
          sanitizedData.email, 
          sanitizedData.telefone, 
          sanitizedData.referencia,
          sanitizedData.usuario_id
        ]
      );

      res.json({
        success: true,
        data: fixObjectEncoding(result.rows[0]),
      });
    } finally {
      client.release();
    }
    } catch (error) {
    // Tratar CPF duplicado
    if (error.code === '23505' && error.constraint === 'locadores_cpf_key') {
      return res.status(400).json({
        success: false,
        message: 'CPF já cadastrado no sistema',
        error: 'duplicate_cpf'
      });
    }
    
    console.error('Erro ao criar locador:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar locador',
    });
  }
});

// PUT - Atualizar locador (requer autenticação)
app.put('/locadores/:id', authenticateToken, async (req, res) => {
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

// DELETE - Excluir locador (requer autenticação)
app.delete('/locadores/:id', authenticateToken, strictLimiter, async (req, res) => {
  try {
    const { id } = req.params;

    // Validar ID
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({
        success: false,
        message: 'ID inválido',
      });
    }

    const client = await pool.connect();
    try {
      // Verificar se o locador existe
      const checkResult = await client.query('SELECT id, nome FROM locadores WHERE id = $1', [id]);
      
      if (checkResult.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Locador não encontrado',
        });
      }
      
      // Excluir locador
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
        data: {
          id: id,
          nome: checkResult.rows[0].nome
        }
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao excluir locador:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao excluir locador',
    });
  }
});

// GET - Obter locador por ID
// Rota pública - não requer autenticação para visualizar
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

// GET - Listar todos os locatários (com paginação)
// Rota pública - não requer autenticação para listar
app.get('/locatarios', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;

    // Validar limites
    const validLimit = Math.min(Math.max(limit, 1), 100); // Entre 1 e 100
    const validPage = Math.max(page, 1);

    const client = await pool.connect();
    try {
      // Contar total de registros
      const countResult = await client.query('SELECT COUNT(*) FROM locatarios');
      const total = parseInt(countResult.rows[0].count);

      // Buscar registros paginados
      const result = await client.query(
        'SELECT * FROM locatarios ORDER BY nome LIMIT $1 OFFSET $2',
        [validLimit, offset]
      );

      res.json({
        success: true,
        data: fixObjectEncoding(result.rows),
        pagination: {
          page: validPage,
          limit: validLimit,
          total,
          totalPages: Math.ceil(total / validLimit)
        }
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao listar locatários:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao listar locatários',
    });
  }
});

// POST - Criar locatário (requer autenticação)
app.post('/locatarios', authenticateToken, strictLimiter, async (req, res) => {
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

    // Obter usuario_id do token
    const usuarioId = req.user?.userId;

    // Validação de campos obrigatórios
    try {
      validateRequired(nome, 'nome');
      validateRequired(cpf, 'cpf');
      validateRequired(usuarioId, 'usuario_id');
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    // Validação de CPF
    if (!validateCPF(cpf)) {
      return res.status(400).json({
        success: false,
        message: 'CPF inválido',
      });
    }

    if (cpf.length > 14) {
      return res.status(400).json({
        success: false,
        message: 'CPF deve ter no máximo 14 caracteres',
      });
    }

    // Validação de email (se fornecido)
    if (email && !validateEmail(email)) {
      return res.status(400).json({
        success: false,
        message: 'Email inválido',
      });
    }

    // Validação de CPF do fiador (se fornecido)
    if (fiadorCpf && !validateCPF(fiadorCpf)) {
      return res.status(400).json({
        success: false,
        message: 'CPF do fiador inválido',
      });
    }

    // Sanitização de dados
    const sanitizedData = {
      nome: sanitizeString(nome),
      cpf: sanitizeString(cpf),
      rg: rg ? sanitizeString(rg) : null,
      estado_civil: estado_civil ? sanitizeString(estado_civil) : null,
      profissao: profissao ? sanitizeString(profissao) : null,
      endereco: endereco ? sanitizeString(endereco) : null,
      email: email ? validator.normalizeEmail(email) : null,
      telefone: telefone ? sanitizeString(telefone) : null,
      dataNascimento: dataNascimento || null,
      renda: renda || null,
      referencia: referencia ? sanitizeString(referencia) : null,
      referenciaComercial: referenciaComercial ? sanitizeString(referenciaComercial) : null,
      fiador: fiador ? sanitizeString(fiador) : null,
      fiadorCpf: fiadorCpf ? sanitizeString(fiadorCpf) : null
    };

    const client = await pool.connect();
    try {
      const result = await client.query(
        `INSERT INTO locatarios (
          nome, cpf, rg, estado_civil, profissao, endereco, 
          email, telefone, data_nascimento, renda, referencia, 
          referencia_comercial, fiador, fiador_cpf
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING *`,
        [
          sanitizedData.nome, 
          sanitizedData.cpf, 
          sanitizedData.rg, 
          sanitizedData.estado_civil, 
          sanitizedData.profissao, 
          sanitizedData.endereco, 
          sanitizedData.email, 
          sanitizedData.telefone, 
          sanitizedData.dataNascimento, 
          sanitizedData.renda, 
          sanitizedData.referencia, 
          sanitizedData.referenciaComercial, 
          sanitizedData.fiador, 
          sanitizedData.fiadorCpf
        ]
      );

      res.json({
        success: true,
        data: fixObjectEncoding(result.rows[0]),
      });
    } finally {
      client.release();
    }
    } catch (error) {
    // Tratar CPF duplicado
    if (error.code === '23505' && error.constraint === 'locatarios_cpf_key') {
      return res.status(400).json({
        success: false,
        message: 'CPF já cadastrado no sistema',
        error: 'duplicate_cpf'
      });
    }
    
    console.error('Erro ao criar locatário:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar locatário',
    });
  }
});

// PUT - Atualizar locatário (requer autenticação)
app.put('/locatarios/:id', authenticateToken, async (req, res) => {
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

// DELETE - Excluir locatário (requer autenticação)
app.delete('/locatarios/:id', authenticateToken, async (req, res) => {
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
// Rota pública - não requer autenticação para visualizar
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

// GET - Listar todos os imóveis (com paginação)
// Rota pública - não requer autenticação para listar
app.get('/imoveis', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const offset = (page - 1) * limit;

    // Validar limites
    const validLimit = Math.min(Math.max(limit, 1), 100); // Entre 1 e 100
    const validPage = Math.max(page, 1);

    const client = await pool.connect();
    try {
      // Contar total de registros
      const countResult = await client.query('SELECT COUNT(*) FROM imoveis');
      const total = parseInt(countResult.rows[0].count);

      // Buscar registros paginados
      const result = await client.query(`
        SELECT 
          i.*,
          l.nome as locador_nome,
          l.cpf as locador_cpf,
          l.telefone as locador_telefone,
          l.email as locador_email,
          lt.nome as locatario_nome,
          lt.cpf as locatario_cpf,
          lt.telefone as locatario_telefone,
          lt.email as locatario_email
        FROM imoveis i
        LEFT JOIN locadores l ON i.id_locador = l.id
        LEFT JOIN locatarios lt ON i.id_locatario = lt.id
        ORDER BY i.endereco
        LIMIT $1 OFFSET $2
      `, [validLimit, offset]);

      res.json({
        success: true,
        data: fixObjectEncoding(result.rows),
        pagination: {
          page: validPage,
          limit: validLimit,
          total,
          totalPages: Math.ceil(total / validLimit)
        }
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao listar imóveis:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao listar imóveis',
    });
  }
});

// POST - Criar imóvel (requer autenticação)
app.post('/imoveis', authenticateToken, strictLimiter, async (req, res) => {
  try {
    const { 
      endereco, tipo, descricao, cadastro_iptu,
      unidade_consumidora_numero, unidade_consumidora_titular, unidade_consumidora_cpf,
      saneago_numero_conta, saneago_titular, saneago_cpf,
      gas_numero_conta, gas_titular, gas_cpf,
      condominio_titular, condominio_valor_estimado, id_locador, id_locatario
    } = req.body || {};

    // Obter usuario_id do token
    const usuarioId = req.user?.userId;

    // Validação de campos obrigatórios
    try {
      validateRequired(endereco, 'endereco');
      validateRequired(tipo, 'tipo');
      validateRequired(usuarioId, 'usuario_id');
      validateRequired(id_locador, 'id_locador');
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    // Validar ID do locador
    if (isNaN(parseInt(id_locador))) {
      return res.status(400).json({
        success: false,
        message: 'ID do locador inválido',
      });
    }

    // Validar ID do locatário (se fornecido)
    if (id_locatario && isNaN(parseInt(id_locatario))) {
      return res.status(400).json({
        success: false,
        message: 'ID do locatário inválido',
      });
    }

    // Sanitização de dados
    const sanitizedData = {
      endereco: sanitizeString(endereco),
      tipo: sanitizeString(tipo),
      descricao: descricao ? sanitizeString(descricao) : null,
      cadastro_iptu: cadastro_iptu ? sanitizeString(cadastro_iptu) : null,
      unidade_consumidora_numero: unidade_consumidora_numero ? sanitizeString(unidade_consumidora_numero) : null,
      unidade_consumidora_titular: unidade_consumidora_titular ? sanitizeString(unidade_consumidora_titular) : null,
      unidade_consumidora_cpf: unidade_consumidora_cpf ? sanitizeString(unidade_consumidora_cpf) : null,
      saneago_numero_conta: saneago_numero_conta ? sanitizeString(saneago_numero_conta) : null,
      saneago_titular: saneago_titular ? sanitizeString(saneago_titular) : null,
      saneago_cpf: saneago_cpf ? sanitizeString(saneago_cpf) : null,
      gas_numero_conta: gas_numero_conta ? sanitizeString(gas_numero_conta) : null,
      gas_titular: gas_titular ? sanitizeString(gas_titular) : null,
      gas_cpf: gas_cpf ? sanitizeString(gas_cpf) : null,
      condominio_titular: condominio_titular ? sanitizeString(condominio_titular) : null,
      condominio_valor_estimado: condominio_valor_estimado || null,
      id_locador: parseInt(id_locador),
      id_locatario: id_locatario ? parseInt(id_locatario) : null
    };

    const client = await pool.connect();
    try {
      // Verificar se locador existe
      const locadorCheck = await client.query('SELECT id FROM locadores WHERE id = $1', [sanitizedData.id_locador]);
      if (locadorCheck.rowCount === 0) {
        return res.status(400).json({
          success: false,
          message: 'Locador não encontrado',
        });
      }

      // Verificar se locatário existe (se fornecido)
      if (sanitizedData.id_locatario) {
        const locatarioCheck = await client.query('SELECT id FROM locatarios WHERE id = $1', [sanitizedData.id_locatario]);
        if (locatarioCheck.rowCount === 0) {
          return res.status(400).json({
            success: false,
            message: 'Locatário não encontrado',
          });
        }
      }

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
        sanitizedData.endereco, 
        sanitizedData.tipo, 
        sanitizedData.descricao, 
        sanitizedData.cadastro_iptu,
        sanitizedData.unidade_consumidora_numero, 
        sanitizedData.unidade_consumidora_titular, 
        sanitizedData.unidade_consumidora_cpf,
        sanitizedData.saneago_numero_conta, 
        sanitizedData.saneago_titular, 
        sanitizedData.saneago_cpf,
        sanitizedData.gas_numero_conta, 
        sanitizedData.gas_titular, 
        sanitizedData.gas_cpf,
        sanitizedData.condominio_titular, 
        sanitizedData.condominio_valor_estimado, 
        sanitizedData.id_locador, 
        sanitizedData.id_locatario
      ]);

      res.json({
        success: true,
        data: fixObjectEncoding(result.rows[0]),
      });
    } finally {
      client.release();
    }
    } catch (error) {
    console.error('Erro ao criar imóvel:', error.message);
    res.status(500).json({
      success: false,
      message: 'Erro ao criar imóvel',
    });
  }
});

// PUT - Atualizar imóvel (requer autenticação)
app.put('/imoveis/:id', authenticateToken, async (req, res) => {
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

// GET - Obter imóvel por ID
// Rota pública - não requer autenticação para visualizar
app.get('/imoveis/:id', async (req, res) => {
  try {
    const { id } = req.params;

    // Validar ID
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({
        success: false,
        message: 'ID inválido',
      });
    }

    const client = await pool.connect();
    try {
      const result = await client.query(`
        SELECT 
          i.*,
          l.nome as locador_nome,
          l.cpf as locador_cpf,
          l.telefone as locador_telefone,
          l.email as locador_email,
          lt.nome as locatario_nome,
          lt.cpf as locatario_cpf,
          lt.telefone as locatario_telefone,
          lt.email as locatario_email
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
        data: fixObjectEncoding(result.rows[0]),
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

// DELETE - Excluir imóvel (requer autenticação)
app.delete('/imoveis/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Validar ID
    if (!id || isNaN(parseInt(id))) {
      return res.status(400).json({
        success: false,
        message: 'ID inválido',
      });
    }

    const client = await pool.connect();
    try {
      // Verificar se imóvel existe
      const checkResult = await client.query('SELECT id FROM imoveis WHERE id = $1', [id]);
      
      if (checkResult.rowCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Imóvel não encontrado',
        });
      }

      // Excluir imagens do imóvel primeiro (se existir)
      await client.query('DELETE FROM imoveis_imagens WHERE id_imovel = $1', [id]);
      
      // Excluir arquivos físicos das imagens
      const imagensResult = await client.query(
        'SELECT caminho_imagem FROM imoveis_imagens WHERE id_imovel = $1',
        [id]
      );
      
      for (const imagem of imagensResult.rows) {
        const filePath = path.join(uploadsDir, path.basename(imagem.caminho_imagem));
        if (fs.existsSync(filePath)) {
          try {
            fs.unlinkSync(filePath);
          } catch (err) {
            console.error('Erro ao excluir arquivo de imagem:', err);
          }
        }
      }
      
      // Excluir imóvel
      const result = await client.query('DELETE FROM imoveis WHERE id = $1 RETURNING id, endereco', [id]);
      
      res.json({
        success: true,
        message: 'Imóvel excluído com sucesso',
        data: {
          id: result.rows[0].id,
          endereco: result.rows[0].endereco
        },
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

// POST - Upload de imagens para um imóvel (requer autenticação)
app.post('/imoveis/:id/imagens', authenticateToken, upload.array('imagens', 20), async (req, res) => {
  try {
    const { id } = req.params;
    const files = req.files;

    if (!files || files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Nenhuma imagem foi enviada',
      });
    }

    const client = await pool.connect();
    try {
      const imagensSalvas = [];

      for (let i = 0; i < files.length; i++) {
        const file = files[i];
        const caminhoImagem = `/uploads/${file.filename}`;
        
        // A primeira imagem enviada será a principal
        const principal = i === 0;
        
        const result = await client.query(`
          INSERT INTO imoveis_imagens (id_imovel, caminho_imagem, principal, ordem)
          VALUES ($1, $2, $3, $4)
          RETURNING *
        `, [id, caminhoImagem, principal, i]);

        imagensSalvas.push(result.rows[0]);
      }

      res.json({
        success: true,
        message: `${files.length} imagens salvas com sucesso`,
        data: imagensSalvas,
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao fazer upload de imagens:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao salvar imagens',
    });
  }
});

// GET - Buscar imagens de um imóvel
// Rota pública - não requer autenticação para visualizar
app.get('/imoveis/:id/imagens', async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      const result = await client.query(`
        SELECT * FROM imoveis_imagens 
        WHERE id_imovel = $1 
        ORDER BY ordem ASC, principal DESC, id ASC
      `, [id]);

      res.json({
        success: true,
        data: result.rows,
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao buscar imagens:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao buscar imagens',
    });
  }
});

// DELETE - Remover uma imagem (requer autenticação)
app.delete('/imoveis-imagens/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const client = await pool.connect();
    try {
      // Primeiro buscar o caminho da imagem para deletar o arquivo
      const imagemResult = await client.query(
        'SELECT caminho_imagem FROM imoveis_imagens WHERE id = $1',
        [id]
      );

      if (imagemResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          message: 'Imagem não encontrada',
        });
      }

      const caminhoImagem = imagemResult.rows[0].caminho_imagem;
      
      // Deletar do banco
      await client.query('DELETE FROM imoveis_imagens WHERE id = $1', [id]);

      // Deletar arquivo do servidor (se existir)
      const filePath = path.join(uploadsDir, path.basename(caminhoImagem));
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }

      res.json({
        success: true,
        message: 'Imagem removida com sucesso',
      });
    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro ao remover imagem:', error);
    res.status(500).json({
      success: false,
      message: 'Erro ao remover imagem',
    });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor rodando na porta ${PORT}`);
  console.log(`Database: ${DATABASE_URL ? 'Neon (URL)' : `${DB_HOST}:${DB_PORT}/${DB_DATABASE}`}`);
  console.log(`Acessível em: http://0.0.0.0:${PORT}`);
});


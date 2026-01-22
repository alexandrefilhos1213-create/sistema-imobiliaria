// VERSÃO SIMPLIFICADA DA ROTA REGISTER - SEM DEPENDÊNCIAS EXTERNAS
require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const bcrypt = require('bcrypt');

const app = express();
app.use(express.json());

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

// ROTA REGISTER SIMPLIFICADA
app.post('/register', async (req, res) => {
  try {
    console.log('=== DEBUG REGISTER SIMPLIFICADO ===');
    console.log('REQ BODY:', req.body);
    
    const { nome, email, senha } = req.body || {};

    // Validações básicas
    if (!nome || !email || !senha) {
      return res.status(400).json({
        success: false,
        message: 'Nome, email e senha são obrigatórios.',
      });
    }

    const emailNormalizado = email.trim().toLowerCase();
    
    if (senha.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'A senha deve ter pelo menos 6 caracteres.',
      });
    }

    const client = await pool.connect();
    try {
      // Verificar se email já existe
      const existingUser = await client.query(
        'SELECT id FROM usuarios WHERE email = $1',
        [emailNormalizado]
      );

      if (existingUser.rowCount > 0) {
        return res.status(400).json({
          success: false,
          message: 'Este email já está cadastrado.',
        });
      }

      // Hash da senha
      const senhaHash = await bcrypt.hash(senha, 10);

      // Inserir novo usuário
      const result = await client.query(
        'INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES ($1, $2, $3, $4) RETURNING id, nome, email, tipo',
        [nome, emailNormalizado, senhaHash, 'usuario']
      );

      const novoUsuario = result.rows[0];

      console.log('✅ Usuário criado:', novoUsuario);

      return res.status(201).json({
        success: true,
        message: 'Usuário criado com sucesso!',
        usuario: {
          id: novoUsuario.id,
          nome: novoUsuario.nome,
          email: novoUsuario.email,
          tipo: novoUsuario.tipo,
        },
      });

    } finally {
      client.release();
    }
  } catch (error) {
    console.error('Erro na rota /register:', error.message);
    console.error('Stack:', error.stack);
    return res.status(500).json({
      success: false,
      message: 'Erro interno no servidor.',
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor de teste rodando na porta ${PORT}`);
});

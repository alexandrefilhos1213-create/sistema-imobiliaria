// HOTFIX - ROTA REGISTER SUPER SIMPLIFICADA
require('dotenv').config();
const express = require('express');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: false
});

// Adicionar ao server.js existente
module.exports = function(app) {
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
};

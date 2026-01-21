// EXEMPLO DE PROXY LOCAL
// Crie um arquivo proxy.js para rodar localmente

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();

// Habilitar CORS
app.use(cors());

// Proxy para o backend no Render
app.use('/api', createProxyMiddleware({
  target: 'https://sistema-imobiliaria.onrender.com',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api do caminho
  },
  onProxyReq: (proxyReq, req, res) => {
    // Adicionar headers CORS
    proxyReq.setHeader('Origin', 'https://sistema-imobiliaria.onrender.com');
  }
}));

const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Proxy CORS rodando em http://localhost:${PORT}`);
});

// Para usar:
// 1. npm install express http-proxy-middleware cors
// 2. node proxy.js
// 3. Altere API_CONFIG para: http://localhost:3001

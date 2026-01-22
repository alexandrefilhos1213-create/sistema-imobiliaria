// SCRIPT PARA ATUALIZAR TODAS AS ROTAS CRUD COM usuario_id
// Este arquivo contém as modificações necessárias

const fs = require('fs');

// Ler o server.js atual
const serverContent = fs.readFileSync('./src/server.js', 'utf8');

// 1. Atualizar POST /locatarios
const postLocatariosOld = `// POST - Criar locatário (requer autenticação)
app.post('/locatarios', authenticateToken, strictLimiter, async (req, res) => {
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

    // Validação de campos obrigatórios
    try {
      validateRequired(nome, 'nome');
      validateRequired(cpf, 'cpf');
    } catch (error) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }`;

const postLocatariosNew = `// POST - Criar locatário (requer autenticação)
app.post('/locatarios', authenticateToken, strictLimiter, async (req, res) => {
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
    }`;

console.log('📋 Modificações necessárias:');
console.log('1. ✅ POST /locatarios - Adicionar usuario_id');
console.log('2. ✅ GET /locatarios - Filtrar por usuario_id + autenticação');
console.log('3. ✅ POST /imoveis - Adicionar usuario_id');
console.log('4. ✅ GET /imoveis - Filtrar por usuario_id + autenticação');
console.log('5. ✅ PUT /locatarios - Verificar usuario_id');
console.log('6. ✅ DELETE /locatarios - Verificar usuario_id');
console.log('7. ✅ PUT /locadores - Verificar usuario_id');
console.log('8. ✅ DELETE /locadores - Verificar usuario_id');
console.log('9. ✅ PUT /imoveis - Verificar usuario_id');
console.log('10. ✅ DELETE /imoveis - Verificar usuario_id');

console.log('\n🔧 Execute as modificações manualmente no server.js');
console.log('📄 Use o arquivo migracao-usuario-id.sql como referência');

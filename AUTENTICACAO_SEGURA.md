# 🔐 Autenticação Segura - Explicação Completa

## 📋 O Problema Atual

No sistema atual, a autenticação tem **vulnerabilidades críticas**:

### ❌ Problemas Identificados

1. **Senhas em Texto Plano**
   ```javascript
   // CÓDIGO ATUAL (INSEGURO)
   if (usuarioDB.senha !== senha) {
     return res.status(401).json({ message: 'Credenciais inválidas' });
   }
   ```
   - Senhas são armazenadas e comparadas diretamente
   - Se o banco for comprometido, todas as senhas são expostas
   - Qualquer pessoa com acesso ao banco vê todas as senhas

2. **Token Temporário Inseguro**
   ```javascript
   // CÓDIGO ATUAL (INSEGURO)
   token: 'temp-token-${Date.now()}-${usuarioDB.id}'
   ```
   - Token previsível e fácil de falsificar
   - Não expira
   - Não pode ser revogado
   - Qualquer pessoa pode criar um token válido

3. **Sem Validação de Token**
   - Nenhuma rota verifica se o token é válido
   - Qualquer pessoa pode acessar qualquer endpoint sem autenticação

---

## ✅ O Que É Autenticação Segura?

Autenticação segura envolve **3 pilares principais**:

### 1. **Hash de Senhas (bcrypt)**

**O que é?**
- Transforma a senha em um texto aleatório irreversível
- Mesma senha sempre gera hash diferente (com salt)
- Impossível reverter o hash para descobrir a senha original

**Como funciona:**
```
Senha: "minhasenha123"
↓ (bcrypt com salt)
Hash: "$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy"
```

**Exemplo de código:**
```javascript
const bcrypt = require('bcrypt');

// Ao criar usuário - HASH da senha
const senhaHash = await bcrypt.hash(senha, 10);
// Armazena: "$2b$10$N9qo8uLOickgx2ZMRZoMye..."

// Ao fazer login - COMPARA hash
const senhaValida = await bcrypt.compare(senhaDigitada, senhaHash);
// Retorna: true ou false
```

**Por que é seguro?**
- ✅ Mesmo que alguém veja o hash, não consegue descobrir a senha
- ✅ Cada hash é único (mesmo para mesma senha)
- ✅ Processo lento propositalmente (dificulta ataques de força bruta)

---

### 2. **JWT (JSON Web Tokens)**

**O que é?**
- Token assinado digitalmente
- Contém informações do usuário (payload)
- Pode expirar automaticamente
- Verificável sem consultar banco de dados

**Estrutura do JWT:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEyMywiZW1haWwiOiJ1c3VhcmlvQGV4YW1wbGUuY29tIiwiaWF0IjoxNjE2MjM5MDIyLCJleHAiOjE2MTYyNDI2MjJ9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

**Partes do token:**
```
HEADER.PAYLOAD.SIGNATURE

HEADER: Tipo de token e algoritmo
PAYLOAD: Dados do usuário (id, email, etc)
SIGNATURE: Assinatura digital (garante autenticidade)
```

**Exemplo de código:**
```javascript
const jwt = require('jsonwebtoken');

// Ao fazer login - GERAR token
const token = jwt.sign(
  { 
    userId: usuario.id, 
    email: usuario.email 
  },
  process.env.JWT_SECRET, // Chave secreta
  { expiresIn: '24h' } // Expira em 24 horas
);

// Em rotas protegidas - VERIFICAR token
const token = req.headers.authorization?.split(' ')[1];
const decoded = jwt.verify(token, process.env.JWT_SECRET);
// decoded = { userId: 123, email: 'usuario@example.com', iat: ..., exp: ... }
```

**Por que é seguro?**
- ✅ Assinado digitalmente (impossível falsificar sem a chave secreta)
- ✅ Expira automaticamente
- ✅ Não precisa consultar banco a cada requisição
- ✅ Pode ser revogado (com blacklist)

---

### 3. **Middleware de Autenticação**

**O que é?**
- Função que verifica se o usuário está autenticado
- Protege rotas que precisam de login
- Valida o token antes de permitir acesso

**Exemplo de código:**
```javascript
// Middleware de autenticação
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // "Bearer TOKEN"

  if (!token) {
    return res.status(401).json({ 
      success: false, 
      message: 'Token não fornecido' 
    });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ 
        success: false, 
        message: 'Token inválido ou expirado' 
      });
    }
    
    req.user = user; // Adiciona dados do usuário na requisição
    next(); // Continua para a próxima função
  });
}

// Usar em rotas protegidas
app.get('/locadores', authenticateToken, async (req, res) => {
  // req.user contém { userId, email }
  // Apenas usuários autenticados chegam aqui
});
```

---

## 🔄 Fluxo Completo de Autenticação Segura

### 1. **Registro de Usuário**
```javascript
app.post('/register', async (req, res) => {
  const { email, senha, nome } = req.body;
  
  // Hash da senha ANTES de salvar
  const senhaHash = await bcrypt.hash(senha, 10);
  
  // Salva no banco (NUNCA a senha original)
  await db.query(
    'INSERT INTO usuarios (email, senha_hash, nome) VALUES ($1, $2, $3)',
    [email, senhaHash, nome]
  );
  
  res.json({ success: true, message: 'Usuário criado' });
});
```

### 2. **Login**
```javascript
app.post('/login', async (req, res) => {
  const { email, senha } = req.body;
  
  // Busca usuário
  const usuario = await db.query(
    'SELECT * FROM usuarios WHERE email = $1',
    [email]
  );
  
  if (!usuario) {
    return res.status(401).json({ message: 'Credenciais inválidas' });
  }
  
  // Compara senha com hash (NÃO compara diretamente)
  const senhaValida = await bcrypt.compare(senha, usuario.senha_hash);
  
  if (!senhaValida) {
    return res.status(401).json({ message: 'Credenciais inválidas' });
  }
  
  // Gera token JWT
  const token = jwt.sign(
    { userId: usuario.id, email: usuario.email },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
  
  res.json({
    success: true,
    token: token,
    usuario: {
      id: usuario.id,
      email: usuario.email,
      nome: usuario.nome
    }
  });
});
```

### 3. **Rotas Protegidas**
```javascript
// Middleware de autenticação
function authenticateToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'Não autenticado' });
  }
  
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.status(403).json({ message: 'Token inválido' });
    req.user = user;
    next();
  });
}

// Aplicar em rotas que precisam de autenticação
app.get('/locadores', authenticateToken, async (req, res) => {
  // req.user.userId contém o ID do usuário logado
  const locadores = await db.query('SELECT * FROM locadores');
  res.json({ success: true, data: locadores });
});

app.post('/locadores', authenticateToken, async (req, res) => {
  // Apenas usuários autenticados podem criar locadores
  // ...
});
```

---

## 📊 Comparação: Antes vs Depois

| Aspecto | ❌ Atual (Inseguro) | ✅ Seguro |
|---------|---------------------|-----------|
| **Armazenamento de Senha** | Texto plano | Hash bcrypt |
| **Comparação de Senha** | `senha === senhaDB` | `bcrypt.compare()` |
| **Token** | String temporária | JWT assinado |
| **Validação de Token** | Não existe | Middleware verifica |
| **Expiração** | Nunca expira | Expira em 24h |
| **Falsificação** | Muito fácil | Impossível sem chave secreta |
| **Proteção de Rotas** | Nenhuma | Middleware em todas |

---

## 🛡️ Benefícios da Autenticação Segura

1. **Proteção de Dados**
   - Senhas não podem ser lidas mesmo com acesso ao banco
   - Tokens não podem ser falsificados

2. **Controle de Acesso**
   - Apenas usuários autenticados acessam rotas protegidas
   - Possibilidade de revogar tokens

3. **Auditoria**
   - Saber quem fez cada ação (via userId no token)
   - Logs de acesso

4. **Conformidade**
   - Atende LGPD (Lei Geral de Proteção de Dados)
   - Boas práticas de segurança

---

## 📦 Dependências Necessárias

```bash
npm install bcrypt jsonwebtoken
```

**Variáveis de ambiente:**
```env
JWT_SECRET=sua_chave_secreta_super_segura_aqui_minimo_32_caracteres
```

---

## ⚠️ Importante

- **JWT_SECRET**: Deve ser uma string longa e aleatória (mínimo 32 caracteres)
- **Nunca** compartilhe a chave secreta
- **Nunca** commite a chave secreta no Git
- Use variáveis de ambiente para armazenar
- Em produção, use chaves diferentes para cada ambiente

---

## 🎯 Resumo

**Autenticação segura =**
1. ✅ Hash de senhas (bcrypt)
2. ✅ Tokens JWT assinados
3. ✅ Middleware de validação
4. ✅ Rotas protegidas

**Resultado:**
- 🔒 Senhas protegidas
- 🛡️ Acesso controlado
- ✅ Sistema seguro e profissional

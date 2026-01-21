# API Sistema Imobiliário

API REST desenvolvida em Node.js/Express para gerenciamento de sistema imobiliário.

## 🚀 Início Rápido

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas configurações

# Desenvolvimento
npm run dev

# Produção
npm start
```

## 📦 Dependências Principais

- **express**: Framework web
- **pg**: Cliente PostgreSQL
- **multer**: Upload de arquivos
- **cors**: Configuração CORS
- **compression**: Compressão de respostas
- **express-rate-limit**: Rate limiting
- **validator**: Validação de dados

## 🔧 Variáveis de Ambiente

```env
PORT=3000
DATABASE_URL=postgresql://user:pass@host:port/db
# OU
DB_HOST=localhost
DB_PORT=5432
DB_USER=usuario
DB_PASSWORD=senha
DB_DATABASE=nome_db

# Autenticação JWT (OBRIGATÓRIO - mude em produção!)
JWT_SECRET=sua_chave_secreta_super_segura_minimo_32_caracteres_aleatorios
JWT_EXPIRES_IN=24h

ALLOWED_ORIGINS=http://localhost:3000,https://dominio.com
NODE_ENV=development
```

## 🔒 Segurança

- ✅ **Autenticação JWT**: Tokens assinados com expiração
- ✅ **Hash de senhas**: bcrypt para proteção de senhas
- ✅ **Rate limiting**: 100 req/15min (geral), 10 req/15min (rotas críticas)
- ✅ **CORS configurado**: Whitelist de origens permitidas
- ✅ **Validação e sanitização**: Todos os inputs são validados
- ✅ **SQL injection prevenido**: Parâmetros preparados em todas as queries
- ✅ **Validação de tipos**: Uploads validados por tipo e tamanho
- ✅ **Rotas protegidas**: CRUD requer autenticação (GET público para listagem)

## 📊 Estrutura de Resposta

### Sucesso
```json
{
  "success": true,
  "data": {...}
}
```

### Erro
```json
{
  "success": false,
  "message": "Mensagem de erro"
}
```

### Paginação
```json
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 100,
    "totalPages": 2
  }
}
```

## 📝 Endpoints

Ver documentação completa no README principal do projeto.

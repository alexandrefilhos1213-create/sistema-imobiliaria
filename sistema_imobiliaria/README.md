# Sistema Imobiliário - + Mais Vida

Sistema completo de gerenciamento imobiliário desenvolvido em Flutter (frontend) e Node.js/Express (backend).

## 📋 Características

- ✅ Gerenciamento de Imóveis
- ✅ Cadastro de Locadores
- ✅ Cadastro de Locatários
- ✅ Upload de imagens para imóveis
- ✅ Interface moderna e responsiva
- ✅ API REST completa
- ✅ Suporte multiplataforma (Web, Android, iOS)

## 🏗️ Arquitetura

### Frontend (Flutter)
- **Framework**: Flutter 3.10.1+
- **Linguagem**: Dart
- **Estado**: Gerenciamento local com cache
- **Tema**: Design system customizado com gradientes e glassmorphism

### Backend (Node.js)
- **Framework**: Express 5.2.1
- **Banco de Dados**: PostgreSQL (Neon)
- **Segurança**: Rate limiting, CORS configurado, validação de dados
- **Upload**: Multer para gerenciamento de imagens

## 🚀 Instalação e Configuração

### Pré-requisitos

- Flutter SDK 3.10.1 ou superior
- Node.js 18+ e npm
- PostgreSQL (ou conta no Neon)
- Conta Firebase (para autenticação)

### Backend

1. Navegue até a pasta do backend:
```bash
cd sistema_imobiliaria_api
```

2. Instale as dependências:
```bash
npm install
```

3. Configure as variáveis de ambiente criando um arquivo `.env`:
```env
PORT=3000
DATABASE_URL=postgresql://user:password@host:port/database
# OU configure individualmente:
DB_HOST=localhost
DB_PORT=5432
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_DATABASE=sistema_imobiliaria

# CORS (opcional, separado por vírgulas)
ALLOWED_ORIGINS=http://localhost:3000,https://seu-dominio.com

# Ambiente
NODE_ENV=development
```

4. Inicie o servidor:
```bash
# Desenvolvimento
npm run dev

# Produção
npm start
```

### Frontend

1. Navegue até a pasta do frontend:
```bash
cd sistema_imobiliaria
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Configure as variáveis de ambiente criando um arquivo `.env` na raiz:
```env
API_BASE_URL=http://localhost:3000
API_BASE_URL_WEB=http://localhost:3000
API_BASE_URL_ANDROID_DEVICE=https://sua-api.com
API_BASE_URL_ANDROID_EMULATOR=http://10.0.2.2:3000
```

4. Execute o aplicativo:
```bash
# Web
flutter run -d chrome

# Android
flutter run

# iOS (apenas no macOS)
flutter run
```

## 📁 Estrutura do Projeto

```
sistema-novo-2025/
├── sistema_imobiliaria/          # Frontend Flutter
│   ├── lib/
│   │   ├── config/               # Configurações
│   │   ├── screens/              # Telas da aplicação
│   │   ├── services/             # Serviços (API, imagens)
│   │   ├── theme/                # Tema e estilos
│   │   ├── utils/                # Utilitários
│   │   ├── widgets/              # Widgets reutilizáveis
│   │   └── main.dart             # Ponto de entrada
│   └── pubspec.yaml              # Dependências Flutter
│
└── sistema_imobiliaria_api/       # Backend Node.js
    ├── src/
    │   └── server.js              # Servidor Express
    ├── uploads/                   # Imagens enviadas
    └── package.json                # Dependências Node.js
```

## 🔌 API Endpoints

### Autenticação
- `POST /login` - Login de usuário

### Locadores
- `GET /locadores` - Listar locadores (com paginação)
- `GET /locadores/:id` - Obter locador por ID
- `POST /locadores` - Criar locador
- `PUT /locadores/:id` - Atualizar locador
- `DELETE /locadores/:id` - Excluir locador

### Locatários
- `GET /locatarios` - Listar locatários (com paginação)
- `GET /locatarios/:id` - Obter locatário por ID
- `POST /locatarios` - Criar locatário
- `PUT /locatarios/:id` - Atualizar locatário
- `DELETE /locatarios/:id` - Excluir locatário

### Imóveis
- `GET /imoveis` - Listar imóveis (com paginação)
- `GET /imoveis/:id` - Obter imóvel por ID
- `POST /imoveis` - Criar imóvel
- `PUT /imoveis/:id` - Atualizar imóvel
- `DELETE /imoveis/:id` - Excluir imóvel
- `POST /imoveis/:id/imagens` - Upload de imagens
- `GET /imoveis/:id/imagens` - Listar imagens do imóvel
- `DELETE /imoveis-imagens/:id` - Remover imagem

### Estatísticas
- `GET /estatisticas` - Obter estatísticas gerais

### Paginação

Todas as rotas de listagem suportam paginação via query parameters:
```
GET /locadores?page=1&limit=50
```

Resposta inclui metadados de paginação:
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

## 🔒 Segurança

- ✅ Rate limiting implementado
- ✅ CORS configurado com origens permitidas
- ✅ Validação de dados de entrada
- ✅ Sanitização de strings
- ✅ Validação de tipos de arquivo para uploads
- ✅ Limite de tamanho de arquivo (5MB por imagem)
- ✅ Parâmetros preparados para prevenir SQL injection

## 📝 Notas de Desenvolvimento

### Validações Implementadas

- CPF: Formato e tamanho validados
- Email: Validação com biblioteca validator
- Campos obrigatórios: Validação antes de inserção
- IDs: Validação numérica antes de consultas

### Tratamento de Erros

- Erros são logados sem expor dados sensíveis
- Mensagens de erro amigáveis para o usuário
- Códigos HTTP apropriados (400, 404, 500)

### Performance

- Compressão de respostas HTTP habilitada
- Paginação para listagens grandes
- Cache local no frontend como fallback
- Timeout de requisições (15 segundos)

## 🐛 Troubleshooting

### Problemas de Conexão

1. Verifique se o backend está rodando
2. Confirme as variáveis de ambiente no `.env`
3. Para Android físico, use o IP da máquina ou URL pública
4. Para Android emulador, use `10.0.2.2` ao invés de `localhost`

### Problemas de Encoding

O sistema possui tratamento automático de encoding UTF-8. Se ainda houver problemas:
1. Verifique a configuração do banco de dados (UTF-8)
2. Confirme que os headers HTTP estão corretos

### Upload de Imagens

- Tamanho máximo: 5MB por imagem
- Formatos aceitos: JPEG, JPG, PNG, GIF, WebP
- Máximo de 20 imagens por requisição

## 📄 Licença

Este projeto é privado e de uso interno.

## 👥 Desenvolvimento

Para contribuir ou reportar problemas, entre em contato com a equipe de desenvolvimento.

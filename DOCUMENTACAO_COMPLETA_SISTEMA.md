# 📚 Documentação Completa do Sistema Imobiliário - "+ Mais Vida"

## 🎯 Visão Geral do Sistema

Este é um **Sistema de Gerenciamento Imobiliário** completo que permite gerenciar imóveis, locadores (proprietários) e locatários (inquilinos). O sistema foi desenvolvido com arquitetura **cliente-servidor**, onde o frontend (aplicativo móvel/web) se comunica com o backend (API) para realizar todas as operações.

### O Que o Sistema Faz?

O sistema permite:
1. **Cadastrar e gerenciar Locadores** (proprietários de imóveis)
2. **Cadastrar e gerenciar Locatários** (inquilinos)
3. **Cadastrar e gerenciar Imóveis** com informações detalhadas
4. **Associar imóveis a locadores e locatários**
5. **Fazer upload de imagens** para cada imóvel
6. **Visualizar estatísticas** do sistema
7. **Autenticação de usuários** para acesso ao sistema

---

## 🏗️ Arquitetura do Sistema

### Estrutura Geral

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (Flutter)                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Telas UI   │  │   Serviços   │  │   Widgets    │  │
│  │  (Screens)   │  │  (Services)  │  │  (Widgets)   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP/REST
                        │ JSON
                        ▼
┌─────────────────────────────────────────────────────────┐
│                  BACKEND (Node.js/Express)               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Rotas API  │  │  Validação   │  │  Autenticação│  │
│  │  (Routes)    │  │  (Middleware)│  │  (JWT)       │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ SQL
                        │ PostgreSQL
                        ▼
┌─────────────────────────────────────────────────────────┐
│              BANCO DE DADOS (PostgreSQL)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   usuarios   │  │  locadores   │  │  locatarios  │  │
│  │   imoveis    │  │imoveis_imagens│  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 📱 FRONTEND - Flutter (Aplicativo)

### Tecnologias Utilizadas

- **Framework**: Flutter 3.10.1+
- **Linguagem**: Dart
- **Plataformas**: Web, Android, iOS (teoricamente)
- **Gerenciamento de Estado**: Local (sem Provider/Riverpod)
- **HTTP Client**: `http` package
- **Armazenamento Local**: `shared_preferences`

### Estrutura de Pastas

```
lib/
├── main.dart                    # Ponto de entrada da aplicação
├── config/
│   └── api_config.dart         # Configuração de URLs da API
├── screens/                     # Todas as telas da aplicação
│   ├── login_screen.dart        # Tela de login
│   ├── user_hub_screen.dart     # Tela principal (hub)
│   ├── add_locador_screen.dart  # Cadastrar locador
│   ├── add_locatario_screen.dart# Cadastrar locatário
│   ├── add_imovel_screen.dart   # Cadastrar imóvel
│   ├── edit_locador_screen.dart # Editar locador
│   ├── edit_locatario_screen.dart# Editar locatário
│   ├── edit_imovel_screen.dart  # Editar imóvel
│   ├── locador_detail_screen.dart# Detalhes do locador
│   ├── locatario_detail_screen.dart# Detalhes do locatário
│   ├── imovel_detail_screen.dart# Detalhes do imóvel
│   └── premium_*.dart           # Telas premium (não utilizadas)
├── services/                    # Serviços de comunicação
│   ├── database_service.dart    # Comunicação com API REST
│   ├── auth_service.dart        # Gerenciamento de autenticação
│   └── image_service.dart       # Upload/download de imagens
├── theme/
│   └── app_theme.dart           # Tema visual da aplicação
├── utils/
│   └── error_handler.dart       # Tratamento centralizado de erros
└── widgets/                     # Componentes reutilizáveis
    ├── loading_widget.dart      # Indicadores de carregamento
    ├── error_widget.dart        # Widgets de erro
    └── premium_bottom_nav_bar.dart# Barra de navegação
```

---

## 🔧 Componentes Principais do Frontend

### 1. **main.dart** - Ponto de Entrada

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");        // Carrega variáveis de ambiente
  await ApiConfig.initialize();               // Configura URL da API
  await DatabaseService.initialize();          // Inicializa serviço de dados
  runApp(const MaisVidaApp());                 // Inicia aplicação
}
```

**O que faz:**
- Inicializa o Flutter
- Carrega configurações do arquivo `.env`
- Configura a URL base da API (diferente para Web/Android)
- Inicializa serviços necessários
- Inicia a aplicação na tela de login

---

### 2. **ApiConfig** - Configuração Inteligente de API

**Localização**: `lib/config/api_config.dart`

**O que faz:**
Este é um componente **muito importante** que resolve automaticamente qual URL usar baseado na plataforma:

- **Web**: Usa `API_BASE_URL_WEB` ou URL padrão
- **Android Emulador**: Converte `localhost` para `10.0.2.2` (IP especial do emulador)
- **Android Físico**: Usa URL pública (não funciona com localhost)
- **Outras plataformas**: Usa URL padrão

**Por que é necessário?**
- Emulador Android não consegue acessar `localhost` da máquina
- Dispositivo físico precisa de IP real ou URL pública
- Web funciona normalmente com qualquer URL

**Exemplo de uso:**
```dart
final uri = ApiConfig.uri('/locadores');  // Retorna: http://localhost:3000/locadores
```

---

### 3. **DatabaseService** - Serviço de Comunicação com API

**Localização**: `lib/services/database_service.dart`

**O que faz:**
Este é o **coração da comunicação** entre frontend e backend. Ele:

1. **Faz requisições HTTP** para a API
2. **Inclui token de autenticação** automaticamente
3. **Trata erros** de conexão
4. **Mantém cache local** como fallback
5. **Loga todas as requisições** para debug

**Métodos principais:**

```dart
// Locadores
DatabaseService.getLocadores()           // Lista todos
DatabaseService.getLocadorById(id)       // Busca por ID
DatabaseService.addLocador(dados)       // Cria novo
DatabaseService.updateLocador(id, dados)// Atualiza
DatabaseService.deleteLocador(id)       // Remove

// Locatários (mesmos métodos)
DatabaseService.getLocatarios()
DatabaseService.addLocatario(dados)
// etc...

// Imóveis (mesmos métodos)
DatabaseService.getImoveis()
DatabaseService.addImovel(dados)
// etc...
```

**Como funciona internamente:**

```dart
static Future<Map<String, dynamic>> _makeRequest(
  String method,      // GET, POST, PUT, DELETE
  String endpoint,    // /locadores, /imoveis, etc
  {Map<String, dynamic>? body}  // Dados para POST/PUT
) async {
  // 1. Obtém token de autenticação
  final token = AuthService.getTokenSync();
  
  // 2. Monta headers
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'  // Se tiver token
  };
  
  // 3. Faz requisição HTTP
  final response = await http.post(uri, headers: headers, body: jsonEncode(body));
  
  // 4. Trata resposta
  if (response.statusCode >= 400) {
    throw Exception('Erro na requisição');
  }
  
  // 5. Retorna dados decodificados
  return jsonDecode(response.body);
}
```

**Cache Local:**
O serviço mantém listas em memória (`_locadores`, `_locatarios`, `_imoveis`) que são usadas como fallback se a API não responder. Isso permite que o app funcione parcialmente mesmo sem internet.

---

### 4. **AuthService** - Gerenciamento de Autenticação

**Localização**: `lib/services/auth_service.dart`

**O que faz:**
Gerencia o token JWT do usuário logado:

```dart
// Salvar token após login
await AuthService.saveToken(token, userId: 123, email: 'user@email.com');

// Obter token (para incluir nas requisições)
final token = await AuthService.getToken();

// Verificar se está logado
final isLogged = await AuthService.isAuthenticated();

// Fazer logout
await AuthService.clearToken();
```

**Armazenamento:**
- **Memória**: Token fica em `_currentToken` para acesso rápido
- **SharedPreferences**: Persiste token no dispositivo para sobreviver a reinicializações

---

### 5. **ImageService** - Upload de Imagens

**Localização**: `lib/services/image_service.dart`

**O que faz:**
Gerencia upload e download de imagens de imóveis:

```dart
// Upload de múltiplas imagens
await ImageService.uploadImagens(idImovel, listaDeArquivos);

// Buscar imagens de um imóvel
final imagens = await ImageService.getImagens(idImovel);

// Remover imagem
await ImageService.removerImagem(idImagem);
```

**Como funciona:**
1. Converte arquivos para `MultipartFile`
2. Cria requisição `MultipartRequest`
3. Inclui token de autenticação
4. Envia para `/imoveis/:id/imagens`
5. Backend salva arquivo físico e registra no banco

---

### 6. **Telas (Screens)**

#### **LoginScreen** - Tela de Login

**Fluxo:**
1. Usuário digita email e senha
2. Clica em "Entrar"
3. App envia POST para `/login`
4. Backend valida credenciais
5. Se válido, retorna token JWT
6. App salva token no `AuthService`
7. Navega para `UserHubScreen`

**Código chave:**
```dart
final response = await http.post(uri, body: jsonEncode({
  'email': email,
  'senha': senha
}));

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  await AuthService.saveToken(data['token']);  // Salva token
  Navigator.pushReplacement(...);              // Vai para próxima tela
}
```

---

#### **UserHubScreen** - Tela Principal (Hub)

**O que faz:**
Esta é a **tela principal** após login. Ela:

1. **Mostra estatísticas** (quantidade de imóveis, locadores, locatários)
2. **Tem 3 abas** (tabs): Imóveis, Locadores, Locatários
3. **Lista itens** de cada categoria
4. **Permite navegar** para detalhes ao clicar
5. **Tem botão flutuante** para adicionar novos itens

**Estrutura:**
```
UserHubScreen
├── Header (Bem-vindo + Logo)
├── Cards de Estatísticas (3 cards lado a lado)
├── Tabs (Imóveis | Locadores | Locatários)
├── Lista de Itens (scrollável)
└── FloatingActionButton (Adicionar)
```

**Como carrega dados:**
```dart
Future<void> _loadData() async {
  final imoveis = await DatabaseService.getImoveis();
  final locadores = await DatabaseService.getLocadores();
  final locatarios = await DatabaseService.getLocatarios();
  
  setState(() {
    _imoveis = imoveis;
    _locadores = locadores;
    _locatarios = locatarios;
  });
}
```

---

#### **AddLocadorScreen / AddLocatarioScreen / AddImovelScreen**

**O que fazem:**
Telas de formulário para cadastrar novos registros.

**Estrutura comum:**
1. **Formulário** com campos específicos
2. **Validação** de campos obrigatórios
3. **Botão Salvar** que chama `DatabaseService.addX()`
4. **Feedback visual** (loading, sucesso, erro)
5. **Navegação** de volta após salvar

**Exemplo (AddLocadorScreen):**
```dart
final dados = {
  'nome': _nameController.text,
  'cpf': _cpfController.text,
  'telefone': _telefoneController.text,
  // ... outros campos
};

await DatabaseService.addLocador(dados);
Navigator.pop(context);  // Volta para tela anterior
```

---

#### **DetailScreens** (LocadorDetail, LocatarioDetail, ImovelDetail)

**O que fazem:**
Mostram **detalhes completos** de um registro específico.

**Funcionalidades:**
- Exibe todos os campos do registro
- Botão "Editar" que navega para `EditXScreen`
- Botão "Excluir" que remove o registro
- Para imóveis: mostra imagens e permite adicionar/remover

**Estrutura:**
```
DetailScreen
├── Header com título
├── Cards com informações agrupadas
│   ├── Informações Básicas
│   ├── Contatos
│   ├── Documentos
│   └── (para imóveis) Utilidades
├── Seção de Imagens (apenas imóveis)
└── Botões de Ação (Editar, Excluir)
```

---

#### **EditScreens** (EditLocador, EditLocatario, EditImovel)

**O que fazem:**
Permitem **editar** registros existentes.

**Diferença dos AddScreens:**
- Campos já vêm **preenchidos** com dados existentes
- Chama `DatabaseService.updateX()` ao invés de `addX()`
- Recebe o registro completo como parâmetro

---

### 7. **AppTheme** - Sistema de Design

**Localização**: `lib/theme/app_theme.dart`

**O que faz:**
Define o **visual completo** da aplicação:

**Cores principais:**
- `roseGoldStart` / `roseGoldEnd` - Dourado rosado (botões principais)
- `deepPurpleBlue` - Roxo escuro (background)
- `softPurple` - Roxo suave
- `white` - Branco
- `graphiteGray` - Cinza grafite

**Gradientes:**
- `primaryGradient` - Gradiente roxo para backgrounds
- `roseGoldGradient` - Gradiente dourado para botões

**Estilos:**
- Tipografia (fontes Georgia e Arial)
- Botões (elevated buttons com bordas arredondadas)
- Cards (com glassmorphism)
- Inputs (campos de texto estilizados)

**Widgets customizados:**
- `glassContainer()` - Container com efeito de vidro
- `premiumButton()` - Botão com gradiente

---

### 8. **Widgets Reutilizáveis**

#### **LoadingWidget**
Mostra indicador de carregamento com mensagem opcional.

#### **ErrorWidget**
Exibe erros de forma amigável com opção de retry.

#### **PremiumBottomNavBar**
Barra de navegação inferior com animações (usado em versão premium).

---

## 🖥️ BACKEND - Node.js/Express (API)

### Tecnologias Utilizadas

- **Runtime**: Node.js
- **Framework**: Express 5.2.1
- **Banco de Dados**: PostgreSQL (via `pg`)
- **Upload**: Multer
- **Segurança**: bcrypt, jsonwebtoken, express-rate-limit
- **Validação**: validator
- **Compressão**: compression

### Estrutura do Backend

```
sistema_imobiliaria_api/
├── src/
│   └── server.js              # Arquivo principal (tudo em um arquivo)
├── uploads/                    # Pasta onde imagens são salvas
├── package.json               # Dependências
└── .env                        # Variáveis de ambiente (não commitado)
```

---

## 🔌 API - Endpoints Detalhados

### Autenticação

#### `POST /login`
**O que faz:** Autentica usuário e retorna token JWT

**Request:**
```json
{
  "email": "usuario@email.com",
  "senha": "senha123"
}
```

**Response (sucesso):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usuario": {
    "id": 1,
    "nome": "João Silva",
    "login": "usuario@email.com"
  }
}
```

**Como funciona:**
1. Busca usuário no banco por email
2. Compara senha (suporta texto plano ou hash bcrypt)
3. Se válido, gera token JWT
4. Retorna token e dados do usuário

---

### Locadores

#### `GET /locadores`
**O que faz:** Lista todos os locadores com paginação

**Query Parameters:**
- `page` (opcional): Número da página (padrão: 1)
- `limit` (opcional): Itens por página (padrão: 50, máximo: 100)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nome": "João Silva",
      "cpf": "123.456.789-00",
      "telefone": "(62) 99999-9999",
      "email": "joao@email.com",
      // ... outros campos
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 100,
    "totalPages": 2
  }
}
```

**Autenticação:** Não requerida (rota pública)

---

#### `GET /locadores/:id`
**O que faz:** Busca um locador específico por ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nome": "João Silva",
    // ... todos os campos
  }
}
```

**Autenticação:** Não requerida

---

#### `POST /locadores`
**O que faz:** Cria um novo locador

**Autenticação:** ✅ **REQUERIDA** (precisa de token JWT)

**Request:**
```json
{
  "nome": "João Silva",
  "cpf": "123.456.789-00",
  "rg": "1234567",
  "estado_civil": "Solteiro",
  "profissao": "Engenheiro",
  "endereco": "Rua ABC, 123",
  "dataNascimento": "1990-01-01",
  "renda": 5000.00,
  "cnh": "123456789",
  "email": "joao@email.com",
  "telefone": "(62) 99999-9999",
  "referencia": "Referência comercial"
}
```

**Validações:**
- `nome` e `cpf` são obrigatórios
- CPF deve ter formato válido (11 dígitos ou máscara)
- Email é validado se fornecido
- Todos os campos são sanitizados (escapados)

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nome": "João Silva",
    // ... dados criados
  }
}
```

---

#### `PUT /locadores/:id`
**O que faz:** Atualiza um locador existente

**Autenticação:** ✅ **REQUERIDA**

**Request:** Mesmo formato do POST, mas só campos que quer atualizar

**Response:** Retorna locador atualizado

---

#### `DELETE /locadores/:id`
**O que faz:** Remove um locador do banco

**Autenticação:** ✅ **REQUERIDA**

**Response:**
```json
{
  "success": true,
  "message": "Locador excluído com sucesso",
  "data": {
    "id": 1,
    "nome": "João Silva"
  }
}
```

---

### Locatários

**Endpoints idênticos aos de Locadores:**
- `GET /locatarios` - Lista (com paginação)
- `GET /locatarios/:id` - Busca por ID
- `POST /locatarios` - Cria (requer auth)
- `PUT /locatarios/:id` - Atualiza (requer auth)
- `DELETE /locatarios/:id` - Remove (requer auth)

**Campos adicionais de Locatários:**
- `referencia_comercial` - Referência comercial
- `fiador` - Nome do fiador
- `fiador_cpf` - CPF do fiador

---

### Imóveis

#### `GET /imoveis`
**O que faz:** Lista todos os imóveis com informações de locador e locatário

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "endereco": "Rua ABC, 123",
      "tipo": "Apartamento",
      "descricao": "Apartamento 2 quartos",
      "locador_nome": "João Silva",
      "locador_cpf": "123.456.789-00",
      "locatario_nome": "Maria Santos",
      // ... muitos outros campos
    }
  ],
  "pagination": { ... }
}
```

**Query SQL usado:**
```sql
SELECT 
  i.*,
  l.nome as locador_nome,
  l.cpf as locador_cpf,
  lt.nome as locatario_nome,
  lt.cpf as locatario_cpf
FROM imoveis i
LEFT JOIN locadores l ON i.id_locador = l.id
LEFT JOIN locatarios lt ON i.id_locatario = lt.id
ORDER BY i.endereco
LIMIT $1 OFFSET $2
```

**Por que LEFT JOIN?**
- Permite imóveis sem locador ou locatário associado
- Não perde dados se relacionamento não existir

---

#### `POST /imoveis`
**O que faz:** Cria um novo imóvel

**Autenticação:** ✅ **REQUERIDA**

**Campos do imóvel:**
- **Básicos**: endereco, tipo, descricao, cadastro_iptu
- **Energia Elétrica**: unidade_consumidora_numero, titular, cpf
- **Água (Saneago)**: numero_conta, titular, cpf
- **Gás**: numero_conta, titular, cpf
- **Condomínio**: titular, valor_estimado
- **Relacionamentos**: id_locador (obrigatório), id_locatario (opcional)

**Validações:**
- Verifica se locador existe antes de criar
- Verifica se locatário existe (se fornecido)
- Valida IDs numéricos

---

#### `POST /imoveis/:id/imagens`
**O que faz:** Faz upload de imagens para um imóvel

**Autenticação:** ✅ **REQUERIDA**

**Request:** Multipart form-data
- Campo: `imagens` (array de arquivos)
- Máximo: 20 imagens por requisição
- Tamanho máximo: 5MB por imagem
- Formatos: JPEG, JPG, PNG, GIF, WebP

**Como funciona:**
1. Recebe arquivos via Multer
2. Valida tipo e tamanho
3. Salva arquivo físico em `uploads/`
4. Registra no banco (`imoveis_imagens`)
5. Primeira imagem é marcada como `principal`

**Response:**
```json
{
  "success": true,
  "message": "3 imagens salvas com sucesso",
  "data": [
    {
      "id": 1,
      "id_imovel": 5,
      "caminho_imagem": "/uploads/imagens-1234567890-123.jpg",
      "principal": true,
      "ordem": 0
    }
  ]
}
```

---

#### `GET /imoveis/:id/imagens`
**O que faz:** Lista todas as imagens de um imóvel

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "caminho_imagem": "/uploads/imagem.jpg",
      "principal": true,
      "ordem": 0
    }
  ]
}
```

**Como acessar imagem:**
```
http://localhost:3000/uploads/imagem.jpg
```
O backend serve arquivos estáticos da pasta `uploads/`

---

#### `DELETE /imoveis-imagens/:id`
**O que faz:** Remove uma imagem

**Autenticação:** ✅ **REQUERIDA**

**Como funciona:**
1. Busca caminho da imagem no banco
2. Remove registro do banco
3. Deleta arquivo físico do servidor

---

### Estatísticas

#### `GET /estatisticas`
**O que faz:** Retorna contagem total de registros

**Response:**
```json
{
  "success": true,
  "data": {
    "locadores": 25,
    "locatarios": 30,
    "imoveis": 15
  }
}
```

**Query SQL:**
```sql
SELECT COUNT(*) FROM locadores;
SELECT COUNT(*) FROM locatarios;
SELECT COUNT(*) FROM imoveis;
```

---

## 🔒 Segurança Implementada

### 1. Autenticação JWT

**Como funciona:**
1. Usuário faz login → Backend valida credenciais
2. Se válido → Gera token JWT assinado
3. Token contém: `{ userId, email, nome }`
4. Token expira em 24 horas (configurável)
5. Frontend envia token no header: `Authorization: Bearer TOKEN`
6. Middleware valida token antes de permitir acesso

**Middleware `authenticateToken`:**
```javascript
function authenticateToken(req, res, next) {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ message: 'Token não fornecido' });
  }
  
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ message: 'Token inválido' });
    req.user = decoded;  // Adiciona dados do usuário na requisição
    next();              // Continua
  });
}
```

---

### 2. Hash de Senhas (bcrypt)

**Sistema atual:**
- Suporta **ambos** os formatos (compatibilidade)
- Senhas antigas: texto plano
- Senhas novas: hash bcrypt

**Como funciona:**
```javascript
// Ao fazer login
if (usuarioDB.senha_hash) {
  // Sistema novo: compara com bcrypt
  senhaValida = await bcrypt.compare(senha, usuarioDB.senha_hash);
} else {
  // Sistema antigo: compara texto plano
  senhaValida = usuarioDB.senha === senha;
}
```

**Por que bcrypt?**
- Hash irreversível (não dá para descobrir senha original)
- Cada hash é único (mesmo para mesma senha)
- Processo lento propositalmente (dificulta força bruta)

---

### 3. Rate Limiting

**Dois níveis:**

1. **Limiter geral**: 100 requisições por 15 minutos por IP
2. **Strict limiter**: 10 requisições por 15 minutos (rotas críticas)

**Rotas com strict limiter:**
- POST `/locadores`
- POST `/locatarios`
- POST `/imoveis`
- DELETE `/locadores/:id`
- DELETE `/locatarios/:id`
- DELETE `/imoveis/:id`

**Por que?**
- Previne ataques de força bruta
- Protege contra spam
- Limita abuso da API

---

### 4. CORS Configurado

**O que é CORS?**
Cross-Origin Resource Sharing - controla quais sites podem fazer requisições para sua API.

**Configuração atual:**
```javascript
const allowedOrigins = [
  'http://localhost:3000',
  'http://localhost:8080',
  'https://sistema-imobiliaria.onrender.com'
];

app.use(cors({
  origin: function (origin, callback) {
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Não permitido pelo CORS'));
    }
  }
}));
```

**Por que importante?**
- Previne que sites maliciosos façam requisições
- Protege dados dos usuários
- Segurança básica de API

---

### 5. Validação e Sanitização

**Validações implementadas:**

1. **CPF**: Formato e tamanho
2. **Email**: Validação com biblioteca `validator`
3. **Campos obrigatórios**: Verificados antes de inserir
4. **IDs**: Validados como números
5. **Sanitização**: Strings são escapadas (previne XSS)

**Exemplo:**
```javascript
function sanitizeString(str) {
  return validator.escape(str.trim());  // Remove HTML e espaços
}
```

---

### 6. SQL Injection Prevenido

**Como:**
- **SEMPRE** usa parâmetros preparados (`$1`, `$2`, etc)
- **NUNCA** interpola strings diretamente na query

**❌ ERRADO (vulnerável):**
```javascript
query(`SELECT * FROM usuarios WHERE id = ${id}`);  // SQL Injection!
```

**✅ CORRETO (seguro):**
```javascript
query('SELECT * FROM usuarios WHERE id = $1', [id]);  // Seguro
```

---

### 7. Validação de Uploads

**Validações:**
- Tipo de arquivo (apenas imagens)
- Tamanho máximo (5MB)
- Quantidade máxima (20 por requisição)
- Verifica extensão E mimetype

---

## 💾 Banco de Dados - Estrutura

### Tabelas Principais

#### **usuarios**
Armazena usuários do sistema (para login)

```sql
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  senha VARCHAR(255),           -- Texto plano (antigo)
  senha_hash VARCHAR(255)       -- Hash bcrypt (novo)
);
```

---

#### **locadores**
Armazena proprietários de imóveis

```sql
CREATE TABLE locadores (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  cpf VARCHAR(14) UNIQUE NOT NULL,
  rg VARCHAR(50),
  estado_civil VARCHAR(50),
  profissao VARCHAR(255),
  endereco TEXT,
  data_nascimento DATE,
  renda DECIMAL(10,2),
  cnh VARCHAR(50),
  email VARCHAR(255),
  telefone VARCHAR(20),
  referencia TEXT
);
```

**Campos importantes:**
- `cpf` é UNIQUE (não pode ter duplicados)
- `nome` e `cpf` são obrigatórios

---

#### **locatarios**
Armazena inquilinos

```sql
CREATE TABLE locatarios (
  id SERIAL PRIMARY KEY,
  nome VARCHAR(255) NOT NULL,
  cpf VARCHAR(14) UNIQUE NOT NULL,
  rg VARCHAR(50),
  estado_civil VARCHAR(50),
  profissao VARCHAR(255),
  endereco TEXT,
  email VARCHAR(255),
  telefone VARCHAR(20),
  data_nascimento DATE,
  renda DECIMAL(10,2),
  referencia TEXT,
  referencia_comercial TEXT,
  fiador VARCHAR(255),
  fiador_cpf VARCHAR(14)
);
```

**Diferenças de locadores:**
- Tem campos de fiador
- Tem referência comercial

---

#### **imoveis**
Armazena imóveis cadastrados

```sql
CREATE TABLE imoveis (
  id SERIAL PRIMARY KEY,
  endereco VARCHAR(255) NOT NULL,
  tipo VARCHAR(100) NOT NULL,
  descricao TEXT,
  cadastro_iptu VARCHAR(100),
  
  -- Energia Elétrica
  unidade_consumidora_numero VARCHAR(100),
  unidade_consumidora_titular VARCHAR(255),
  unidade_consumidora_cpf VARCHAR(14),
  
  -- Água (Saneago)
  saneago_numero_conta VARCHAR(100),
  saneago_titular VARCHAR(255),
  saneago_cpf VARCHAR(14),
  
  -- Gás
  gas_numero_conta VARCHAR(100),
  gas_titular VARCHAR(255),
  gas_cpf VARCHAR(14),
  
  -- Condomínio
  condominio_titular VARCHAR(255),
  condominio_valor_estimado DECIMAL(10,2),
  
  -- Relacionamentos
  id_locador INTEGER REFERENCES locadores(id),
  id_locatario INTEGER REFERENCES locatarios(id)
);
```

**Relacionamentos:**
- `id_locador` → FK para `locadores.id` (obrigatório)
- `id_locatario` → FK para `locatarios.id` (opcional)

---

#### **imoveis_imagens**
Armazena referências às imagens dos imóveis

```sql
CREATE TABLE imoveis_imagens (
  id SERIAL PRIMARY KEY,
  id_imovel INTEGER REFERENCES imoveis(id) ON DELETE CASCADE,
  caminho_imagem VARCHAR(500) NOT NULL,
  principal BOOLEAN DEFAULT false,
  ordem INTEGER DEFAULT 0
);
```

**Campos:**
- `caminho_imagem`: Caminho relativo do arquivo (ex: `/uploads/imagem.jpg`)
- `principal`: Se é a imagem principal do imóvel
- `ordem`: Ordem de exibição

**ON DELETE CASCADE:**
- Se imóvel for deletado, imagens são deletadas automaticamente

---

## 🔄 Fluxos de Dados Completos

### Fluxo 1: Login

```
1. Usuário abre app
   ↓
2. LoginScreen aparece
   ↓
3. Usuário digita email e senha
   ↓
4. Clica "Entrar"
   ↓
5. LoginScreen faz POST /login
   ↓
6. Backend valida credenciais
   ├─ Se inválido → Retorna 401
   └─ Se válido → Gera token JWT
   ↓
7. Backend retorna token
   ↓
8. LoginScreen salva token no AuthService
   ↓
9. Navega para UserHubScreen
```

---

### Fluxo 2: Listar Locadores

```
1. Usuário está em UserHubScreen
   ↓
2. Clica na aba "Locadores"
   ↓
3. UserHubScreen chama DatabaseService.getLocadores()
   ↓
4. DatabaseService faz GET /locadores
   ├─ Inclui token no header (se tiver)
   └─ Backend não requer auth (rota pública)
   ↓
5. Backend busca no PostgreSQL
   ↓
6. Backend retorna JSON com lista + paginação
   ↓
7. DatabaseService atualiza cache local
   ↓
8. UserHubScreen atualiza UI com lista
```

---

### Fluxo 3: Criar Locador

```
1. Usuário clica botão "Adicionar Locador"
   ↓
2. Navega para AddLocadorScreen
   ↓
3. Preenche formulário
   ↓
4. Clica "Salvar"
   ↓
5. AddLocadorScreen valida campos
   ├─ Se inválido → Mostra erro
   └─ Se válido → Continua
   ↓
6. Chama DatabaseService.addLocador(dados)
   ↓
7. DatabaseService faz POST /locadores
   ├─ Inclui token JWT no header
   └─ Backend valida token (middleware)
   ↓
8. Backend valida dados
   ├─ CPF válido?
   ├─ Email válido?
   └─ Campos obrigatórios?
   ↓
9. Backend sanitiza dados (escape strings)
   ↓
10. Backend insere no PostgreSQL
    ↓
11. Backend retorna locador criado
    ↓
12. DatabaseService atualiza cache local
    ↓
13. AddLocadorScreen mostra sucesso
    ↓
14. Navega de volta para UserHubScreen
    ↓
15. UserHubScreen recarrega lista (atualizada)
```

---

### Fluxo 4: Upload de Imagens

```
1. Usuário está em ImovelDetailScreen
   ↓
2. Clica "Adicionar Imagem"
   ↓
3. App abre seletor de arquivo
   ├─ Web: Input HTML
   └─ Mobile: ImagePicker (galeria)
   ↓
4. Usuário seleciona imagem
   ↓
5. App converte para File/XFile
   ↓
6. ImovelDetailScreen chama ImageService.uploadImagens()
   ↓
7. ImageService cria MultipartRequest
   ├─ Adiciona token JWT
   └─ Adiciona arquivo como MultipartFile
   ↓
8. Envia POST /imoveis/:id/imagens
   ↓
9. Backend valida token
   ↓
10. Backend valida arquivo
    ├─ Tipo correto?
    ├─ Tamanho OK?
    └─ Quantidade OK?
    ↓
11. Backend salva arquivo físico em uploads/
    ↓
12. Backend registra no banco (imoveis_imagens)
    ↓
13. Backend retorna dados da imagem salva
    ↓
14. ImovelDetailScreen atualiza UI
    ↓
15. Imagem aparece na lista
```

---

## 🎨 Design System e UI

### Paleta de Cores

**Cores principais:**
- **Roxo Escuro** (`#3A2F8F`): Background principal
- **Roxo Suave** (`#7C63E0`): Acentos
- **Dourado Rosado** (`#E5A3A8` a `#F6C7B6`): Botões e destaques
- **Branco** (`#FFFFFF`): Textos principais
- **Cinza Grafite** (`#1E1E2A`): Cards e superfícies

### Estilo Visual

**Características:**
- **Glassmorphism**: Efeito de vidro fosco nos cards
- **Gradientes**: Backgrounds com gradientes roxos
- **Sombras suaves**: Box shadows para profundidade
- **Bordas arredondadas**: Border radius de 12-24px
- **Animações**: Transições suaves (300ms)

**Tipografia:**
- **Títulos**: Georgia (serifada, elegante)
- **Corpo**: Arial (sans-serif, legível)
- **Tamanhos**: 12px a 32px conforme hierarquia

---

## 📊 Estrutura de Dados

### Modelo de Locador

```typescript
interface Locador {
  id: number;
  nome: string;              // Obrigatório
  cpf: string;              // Obrigatório, único
  rg?: string;
  estado_civil?: string;
  profissao?: string;
  endereco?: string;
  data_nascimento?: Date;
  renda?: number;
  cnh?: string;
  email?: string;
  telefone?: string;
  referencia?: string;
}
```

### Modelo de Locatário

```typescript
interface Locatario {
  id: number;
  nome: string;              // Obrigatório
  cpf: string;              // Obrigatório, único
  rg?: string;
  estado_civil?: string;
  profissao?: string;
  endereco?: string;
  email?: string;
  telefone?: string;
  data_nascimento?: Date;
  renda?: number;
  referencia?: string;
  referencia_comercial?: string;
  fiador?: string;
  fiador_cpf?: string;
}
```

### Modelo de Imóvel

```typescript
interface Imovel {
  id: number;
  endereco: string;          // Obrigatório
  tipo: string;              // Obrigatório (ex: "Apartamento", "Casa")
  descricao?: string;
  cadastro_iptu?: string;
  
  // Energia
  unidade_consumidora_numero?: string;
  unidade_consumidora_titular?: string;
  unidade_consumidora_cpf?: string;
  
  // Água
  saneago_numero_conta?: string;
  saneago_titular?: string;
  saneago_cpf?: string;
  
  // Gás
  gas_numero_conta?: string;
  gas_titular?: string;
  gas_cpf?: string;
  
  // Condomínio
  condominio_titular?: string;
  condominio_valor_estimado?: number;
  
  // Relacionamentos
  id_locador: number;        // Obrigatório
  id_locatario?: number;     // Opcional
  
  // Dados relacionados (vindos do JOIN)
  locador_nome?: string;
  locador_cpf?: string;
  locador_telefone?: string;
  locador_email?: string;
  locatario_nome?: string;
  locatario_cpf?: string;
  locatario_telefone?: string;
  locatario_email?: string;
}
```

---

## 🔧 Configurações e Variáveis de Ambiente

### Backend (.env)

```env
# Porta do servidor
PORT=3000

# Banco de dados (opção 1: URL completa)
DATABASE_URL=postgresql://user:pass@host:port/db

# Banco de dados (opção 2: Configuração individual)
DB_HOST=localhost
DB_PORT=5432
DB_USER=usuario
DB_PASSWORD=senha
DB_DATABASE=nome_banco

# Autenticação JWT
JWT_SECRET=sua_chave_secreta_minimo_32_caracteres
JWT_EXPIRES_IN=24h

# CORS (origens permitidas, separadas por vírgula)
ALLOWED_ORIGINS=http://localhost:3000,https://seu-dominio.com

# Ambiente
NODE_ENV=development
```

### Frontend (.env)

```env
# URL base da API
API_BASE_URL=http://localhost:3000

# URLs específicas por plataforma (opcional)
API_BASE_URL_WEB=http://localhost:3000
API_BASE_URL_ANDROID_DEVICE=https://sua-api.com
API_BASE_URL_ANDROID_EMULATOR=http://10.0.2.2:3000
```

---

## 🚀 Como Executar o Sistema

### Backend

```bash
cd sistema_imobiliaria_api
npm install                    # Instala dependências
npm run dev                    # Desenvolvimento (com nodemon)
# ou
npm start                      # Produção
```

**O servidor inicia em:** `http://localhost:3000`

---

### Frontend

```bash
cd sistema_imobiliaria
flutter pub get                # Instala dependências
flutter run -d chrome          # Web
# ou
flutter run                    # Android/iOS
```

---

## 📝 Padrões de Código

### Nomenclatura

**Flutter (Dart):**
- Classes: `PascalCase` (ex: `UserHubScreen`)
- Variáveis: `camelCase` (ex: `_isLoading`)
- Constantes: `camelCase` com `const` (ex: `const maxImages = 20`)
- Arquivos: `snake_case.dart` (ex: `user_hub_screen.dart`)

**Backend (JavaScript):**
- Funções: `camelCase` (ex: `authenticateToken`)
- Constantes: `UPPER_SNAKE_CASE` (ex: `JWT_SECRET`)
- Rotas: `kebab-case` (ex: `/imoveis-imagens`)

---

### Estrutura de Resposta da API

**Sucesso:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Erro:**
```json
{
  "success": false,
  "message": "Mensagem de erro"
}
```

**Com paginação:**
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 50,
    "total": 100,
    "totalPages": 2
  }
}
```

---

## 🐛 Tratamento de Erros

### Frontend

**Níveis de tratamento:**

1. **DatabaseService**: Captura erros HTTP e converte em Exceptions
2. **ErrorHandler**: Trata erros globais do Flutter
3. **Telas**: Mostram mensagens amigáveis ao usuário

**Tipos de erro tratados:**
- Sem conexão (`SocketException`)
- Timeout (`TimeoutException`)
- Erro de servidor (500)
- Erro de validação (400)
- Não autorizado (401)

---

### Backend

**Tratamento:**
- Try/catch em todas as rotas
- Logs de erro (sem dados sensíveis)
- Mensagens amigáveis
- Códigos HTTP apropriados

**Middleware de erro global:**
```javascript
app.use((error, req, res, next) => {
  console.error('Erro não tratado:', error);
  res.status(500).json({
    success: false,
    message: 'Erro interno no servidor'
  });
});
```

---

## 🔍 Funcionalidades Especiais

### 1. Cache Local no Frontend

**O que é:**
O `DatabaseService` mantém listas em memória que são atualizadas a cada requisição bem-sucedida.

**Vantagens:**
- App funciona parcialmente sem internet
- Respostas mais rápidas (dados já em memória)
- Fallback se API não responder

**Desvantagens:**
- Pode ficar desatualizado
- Não sincroniza entre dispositivos

---

### 2. Compatibilidade Retroativa de Senhas

**O que é:**
O sistema suporta senhas antigas (texto plano) e novas (hash) simultaneamente.

**Como funciona:**
```javascript
if (usuarioDB.senha_hash) {
  // Usa bcrypt
  senhaValida = await bcrypt.compare(senha, usuarioDB.senha_hash);
} else {
  // Usa texto plano (compatibilidade)
  senhaValida = usuarioDB.senha === senha;
}
```

**Por que?**
- Permite migração gradual
- Não quebra sistema existente
- Usuários antigos continuam funcionando

---

### 3. Upload Multiplataforma

**Web:**
- Usa `html.FileUploadInputElement`
- Converte para `XFile` via Data URL
- Base64 encoding

**Mobile:**
- Usa `image_picker` package
- Acesso direto à galeria
- Permissões automáticas

**Desktop:**
- Mostra mensagem de não suportado
- Funcionalidade limitada

---

### 4. Encoding UTF-8 Automático

**Problema:**
PostgreSQL pode retornar dados com encoding incorreto (latin1 ao invés de UTF-8).

**Solução:**
Função `fixObjectEncoding()` que:
1. Detecta se string está em UTF-8 válido
2. Se não, converte de latin1 para UTF-8
3. Aplica recursivamente em objetos e arrays

---

## 📈 Performance e Otimizações

### Backend

1. **Compressão HTTP**: Respostas comprimidas (gzip)
2. **Paginação**: Limita resultados (máx 100 por página)
3. **Connection Pooling**: Reutiliza conexões do PostgreSQL
4. **Rate Limiting**: Previne abuso

### Frontend

1. **Cache Local**: Dados em memória
2. **Timeout**: 15 segundos por requisição
3. **Lazy Loading**: Imagens carregadas sob demanda
4. **Compressão de Imagens**: Qualidade 80% no upload

---

## 🧪 Testes e Debug

### Logs

**Frontend:**
- Usa biblioteca `logger` com cores
- Logs de requisições HTTP
- Logs de erros com stack trace

**Backend:**
- Console.log para requisições
- Console.error para erros
- Logs estruturados (JSON)

### Debug

**Frontend:**
- `print()` statements em telas
- Logger com diferentes níveis
- Debug mode do Flutter

**Backend:**
- Console logs detalhados
- Stack traces em erros
- Variável `NODE_ENV=development`

---

## 📦 Dependências Principais

### Backend (package.json)

```json
{
  "dependencies": {
    "bcrypt": "^5.1.1",              // Hash de senhas
    "compression": "^1.7.4",         // Compressão HTTP
    "cors": "^2.8.5",                 // CORS
    "dotenv": "^17.2.3",              // Variáveis de ambiente
    "express": "^5.2.1",              // Framework web
    "express-rate-limit": "^7.4.1",   // Rate limiting
    "jsonwebtoken": "^9.0.2",         // JWT
    "multer": "^2.0.2",               // Upload de arquivos
    "pg": "^8.16.3",                  // Cliente PostgreSQL
    "validator": "^13.13.0"           // Validação de dados
  }
}
```

### Frontend (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  postgres: ^3.0.1              # PostgreSQL (não usado diretamente)
  http: ^1.1.0                   # Cliente HTTP
  flutter_dotenv: ^5.1.0         # Variáveis de ambiente
  logger: ^2.6.2                 # Logging
  device_info_plus: 9.1.2        # Info do dispositivo
  image_picker: ^1.0.4           # Seleção de imagens
  firebase_auth: ^5.7.0          # Firebase (não usado)
  google_sign_in: ^6.2.1         # Google Sign In (não usado)
  firebase_core: ^3.4.1          # Firebase Core (não usado)
  shared_preferences: ^2.2.2     # Armazenamento local
```

---

## 🎯 Casos de Uso Principais

### Caso 1: Imobiliária Cadastra Novo Imóvel

1. Funcionário faz login
2. Vai para aba "Imóveis"
3. Clica "Adicionar Imóvel"
4. Preenche formulário completo:
   - Endereço, tipo, descrição
   - Dados de energia, água, gás, condomínio
   - Seleciona locador (obrigatório)
   - Seleciona locatário (opcional)
5. Adiciona fotos do imóvel
6. Salva
7. Sistema cria imóvel e faz upload das imagens
8. Imóvel aparece na lista

---

### Caso 2: Consultar Informações de Locador

1. Funcionário vai para aba "Locadores"
2. Vê lista de todos os locadores
3. Clica em um locador específico
4. Vê detalhes completos:
   - Dados pessoais
   - Contatos
   - Documentos
5. Pode editar ou excluir

---

### Caso 3: Associar Locatário a Imóvel

1. Funcionário vai para detalhes de um imóvel
2. Clica "Editar"
3. Na seção "Locatário", seleciona um locatário da lista
4. Salva
5. Imóvel agora mostra informações do locatário

---

## ⚠️ Limitações e Considerações

### Limitações Atuais

1. **Sem gerenciamento de estado global**: Cada tela gerencia seu próprio estado
2. **Cache local simples**: Não sincroniza entre dispositivos
3. **Sem testes automatizados**: Não há testes unitários ou de integração
4. **Upload apenas imagens**: Não suporta outros tipos de arquivo
5. **Sem busca/filtro**: Listas mostram tudo, sem filtros
6. **Sem ordenação customizada**: Sempre ordena por nome/endereço

### Considerações de Segurança

1. **JWT_SECRET**: Deve ser mudado em produção
2. **Senhas antigas**: Devem ser migradas para hash
3. **CORS**: Deve ser restrito em produção
4. **Rate limiting**: Pode precisar ajuste conforme uso
5. **Uploads**: Não há validação de conteúdo (apenas tipo/tamanho)

---

## 🔮 Possíveis Melhorias Futuras

1. **Gerenciamento de estado**: Provider ou Riverpod
2. **Testes**: Unitários e de integração
3. **Busca e filtros**: Por nome, CPF, endereço, etc
4. **Relatórios**: PDFs, estatísticas avançadas
5. **Notificações**: Push notifications
6. **Backup automático**: Export de dados
7. **Multi-tenant**: Suporte a múltiplas imobiliárias
8. **API versionada**: `/v1/locadores` para futuras mudanças

---

## 📞 Suporte e Manutenção

### Arquivos Importantes

- **Backend**: `src/server.js` - Tudo em um arquivo (monolítico)
- **Frontend**: `lib/main.dart` - Ponto de entrada
- **Configuração**: `.env` - Variáveis de ambiente
- **Documentação**: README.md em cada pasta

### Logs

**Backend:**
- Console do Node.js
- Logs de requisições e erros

**Frontend:**
- Console do Flutter/Dart
- Logger com cores e emojis

---

## 🎓 Conclusão

Este é um sistema **completo e funcional** de gerenciamento imobiliário com:

✅ **Frontend moderno** em Flutter  
✅ **Backend robusto** em Node.js  
✅ **Segurança implementada** (JWT, bcrypt, validações)  
✅ **Interface bonita** com design system próprio  
✅ **Funcionalidades completas** de CRUD  
✅ **Upload de imagens** funcionando  
✅ **Documentação** detalhada  

O sistema está **pronto para uso** após configurar variáveis de ambiente e banco de dados.

-- SQL PARA EXECUTAR NO BANCO DO RENDER
-- CONECTE VIA PSQL OU INTERFACE DO RENDER

-- 1. APAGAR USUÁRIO PROBLEMÁTICO
DELETE FROM usuarios WHERE email = 'admin@sistema.com';

-- 2. INSERIR COM HASH CORRETO
INSERT INTO usuarios (nome, email, senha_hash, tipo) VALUES (
  'Admin',
  'admin@sistema.com',
  '$2b$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQjQ',
  'admin'
);

-- 3. VERIFICAR
SELECT id, nome, email, tipo FROM usuarios WHERE email = 'admin@sistema.com';

-- RESULTADO ESPERADO:
-- id | nome  | email               | tipo
-- ----+-------+---------------------+-------
--  X  | Admin | admin@sistema.com   | admin

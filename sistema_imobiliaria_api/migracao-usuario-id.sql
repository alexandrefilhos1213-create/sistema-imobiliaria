-- MIGRAÇÃO PARA ADICIONAR usuario_id EM TODAS AS TABELAS
-- Execute isso no banco do Render

-- 1. ADICIONAR usuario_id NA TABELA IMOVEIS
ALTER TABLE imoveis 
ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id);

-- 2. ADICIONAR usuario_id NA TABELA LOCADORES  
ALTER TABLE locadores 
ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id);

-- 3. ADICIONAR usuario_id NA TABELA LOCATARIOS
ALTER TABLE locatarios 
ADD COLUMN IF NOT EXISTS usuario_id INTEGER REFERENCES usuarios(id);

-- 4. ATUALIZAR REGISTROS EXISTENTES (associar ao admin ID 6)
UPDATE imoveis SET usuario_id = 6 WHERE usuario_id IS NULL;
UPDATE locadores SET usuario_id = 6 WHERE usuario_id IS NULL;
UPDATE locatarios SET usuario_id = 6 WHERE usuario_id IS NULL;

-- 5. VERIFICAR RESULTADO
SELECT 'imoveis' as tabela, COUNT(*) as total, COUNT(usuario_id) as com_usuario_id FROM imoveis
UNION ALL
SELECT 'locadores' as tabela, COUNT(*) as total, COUNT(usuario_id) as com_usuario_id FROM locadores  
UNION ALL
SELECT 'locatarios' as tabela, COUNT(*) as total, COUNT(usuario_id) as com_usuario_id FROM locatarios;

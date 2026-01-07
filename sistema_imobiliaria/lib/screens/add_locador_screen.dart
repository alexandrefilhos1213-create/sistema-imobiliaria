import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';

class AddLocadorScreen extends StatefulWidget {
  const AddLocadorScreen({super.key});

  @override
  State<AddLocadorScreen> createState() => _AddLocadorScreenState();
}

class _AddLocadorScreenState extends State<AddLocadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _rendaController = TextEditingController();
  final _cnhController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _referenciaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _dataNascimentoController.dispose();
    _profissaoController.dispose();
    _rendaController.dispose();
    _cnhController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1D29),
              Color(0xFF2D3142),
              Color(0xFF4A5568),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE2E8F0),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Novo Locador',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A5568),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar placeholder
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
                                  Icons.person_add,
                                  size: 40,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Form fields
                            _buildSectionTitle('Informações Pessoais'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Nome Completo',
                              hint: 'João Silva',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o nome';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _cpfController,
                              label: 'CPF',
                              hint: '123.456.789-00',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o CPF';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _enderecoController,
                              label: 'Endereço Completo',
                              hint: 'Rua das Flores, 123 - Centro',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o endereço';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _telefoneController,
                              label: 'Telefone',
                              hint: '(61) 9 9123-4567',
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o telefone';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'joao.silva@email.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Informações Adicionais'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _rgController,
                              label: 'RG',
                              hint: 'MG-12.345.678',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _dataNascimentoController,
                              label: 'Data de Nascimento',
                              hint: 'DD/MM/AAAA',
                              keyboardType: TextInputType.datetime,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _profissaoController,
                              label: 'Profissão',
                              hint: 'Engenheiro, Médico, etc.',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _rendaController,
                              label: 'Renda Mensal',
                              hint: 'R\$ 5.000,00',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Documentação'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _cnhController,
                              label: 'CNH',
                              hint: '12345678901',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _referenciaController,
                              label: 'Referência Comercial',
                              hint: 'Nome e telefone de referência',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 32),
                            // Botão de salvar
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE2E8F0),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF10B981)),
        hintStyle: TextStyle(color: const Color(0xFF9CA3AF).withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4A5568), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D3142),
      ),
      style: const TextStyle(color: Color(0xFFE2E8F0)),
      validator: validator,
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (_formKey.currentState!.validate()) {
              // Salvar dados no banco
              final locadorData = {
                'nome': _nameController.text,
                'cpf': _cpfController.text,
                'rg': _rgController.text,
                'dataNascimento': _dataNascimentoController.text,
                'profissao': _profissaoController.text,
                'renda': _rendaController.text,
                'cnh': _cnhController.text,
                'email': _emailController.text,
                'telefone': _telefoneController.text,
                'endereco': _enderecoController.text,
                'referencia': _referenciaController.text,
              };

              try {
                await DatabaseService.addLocador(locadorData);
                
                // Mostrar mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Locador salvo com sucesso!'),
                    backgroundColor: Color(0xFF10B981),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Voltar para a tela anterior
                Navigator.pop(context);
              } catch (e) {
                // Mostrar mensagem de erro
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao salvar locador!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Salvar Locador',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

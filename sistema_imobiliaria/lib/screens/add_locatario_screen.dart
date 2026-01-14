import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';

class AddLocatarioScreen extends StatefulWidget {
  const AddLocatarioScreen({super.key});

  @override
  State<AddLocatarioScreen> createState() => _AddLocatarioScreenState();
}

class _AddLocatarioScreenState extends State<AddLocatarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _estadoCivilController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _cnhController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _rendaController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _referenciaComercialController = TextEditingController();
  final _fiadorController = TextEditingController();
  final _fiadorCpfController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _estadoCivilController.dispose();
    _dataNascimentoController.dispose();
    _cnhController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _profissaoController.dispose();
    _rendaController.dispose();
    _referenciaController.dispose();
    _referenciaComercialController.dispose();
    _fiadorController.dispose();
    _fiadorCpfController.dispose();
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
                      'Novo Locatário',
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
                        color: const Color(0xFFF59E0B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Color(0xFFF59E0B),
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
                                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
                                  Icons.person_add,
                                  size: 40,
                                  color: Color(0xFFF59E0B),
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
                              hint: 'Maria Souza',
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
                                if (value.length > 14) {
                                  return 'CPF deve ter no máximo 14 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _rgController,
                              label: 'RG',
                              hint: 'MG-12.345.678',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o RG';
                                }
                                return null;
                              },
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
                              controller: _emailController,
                              label: 'Email',
                              hint: 'maria.souza@email.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o email';
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
                            const SizedBox(height: 24),
                            _buildSectionTitle('Endereço e Contato'),
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
                              controller: _profissaoController,
                              label: 'Profissão',
                              hint: 'Profissional autônomo, etc.',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _rendaController,
                              label: 'Renda Mensal',
                              hint: 'R\$ 3.000,00',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Informações de Locação'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _referenciaController,
                              label: 'Referência Pessoal',
                              hint: 'Nome e telefone de referência pessoal',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _referenciaComercialController,
                              label: 'Referência Comercial',
                              hint: 'Nome e telefone de referência comercial',
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _fiadorController,
                              label: 'Nome do Fiador',
                              hint: 'Nome completo do fiador',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _fiadorCpfController,
                              label: 'CPF do Fiador',
                              hint: '123.456.789-00',
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
        labelStyle: const TextStyle(color: Color(0xFFF59E0B)),
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
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
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
        color: const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
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
              final locatarioData = {
                'nome': _nameController.text,
                'cpf': _cpfController.text,
                'rg': _rgController.text,
                'estado_civil': _estadoCivilController.text,
                'data_nascimento': _dataNascimentoController.text,
                'cnh': _cnhController.text,
                'email': _emailController.text,
                'telefone': _telefoneController.text,
                'endereco': _enderecoController.text,
                'profissao': _profissaoController.text,
                'renda': _rendaController.text,
                'referencia': _referenciaController.text,
                'referencia_comercial': _referenciaComercialController.text,
                'fiador': _fiadorController.text,
                'fiador_cpf': _fiadorCpfController.text,
              };

              try {
                await DatabaseService.addLocatario(locatarioData);
                
                // Mostrar mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Locatário salvo com sucesso!'),
                    backgroundColor: Color(0xFFF59E0B),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Voltar para a tela anterior
                Navigator.pop(context);
              } catch (e) {
                // Mostrar mensagem de erro específica
                String errorMessage = 'Erro ao salvar locatário!';
                
                if (e.toString().contains('duplicate_cpf') || 
                    e.toString().contains('CPF já cadastrado')) {
                  errorMessage = 'CPF já cadastrado no sistema!';
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
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
                'Salvar Locatário',
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

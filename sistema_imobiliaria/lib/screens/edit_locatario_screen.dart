import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';
import 'package:sistema_imobiliaria/screens/user_hub_screen.dart';

class EditLocatarioScreen extends StatefulWidget {
  final Map<String, dynamic> locatario;

  const EditLocatarioScreen({super.key, required this.locatario});

  @override
  State<EditLocatarioScreen> createState() => _EditLocatarioScreenState();
}

class _EditLocatarioScreenState extends State<EditLocatarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _rgController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _profissaoController = TextEditingController();
  final _rendaController = TextEditingController();
  final _cnhController = TextEditingController();
  final _estadoCivilController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _referenciaController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _nameController.text = widget.locatario['nome'] ?? '';
    _cpfController.text = widget.locatario['cpf'] ?? '';
    _rgController.text = widget.locatario['rg'] ?? '';
    _telefoneController.text = widget.locatario['telefone'] ?? '';
    _emailController.text = widget.locatario['email'] ?? '';
    _profissaoController.text = widget.locatario['profissao'] ?? '';
    _rendaController.text = widget.locatario['renda'] ?? '';
    _cnhController.text = widget.locatario['cnh'] ?? '';
    _estadoCivilController.text = widget.locatario['estado_civil'] ?? '';
    _dataNascimentoController.text = widget.locatario['data_nascimento'] ?? '';
    _referenciaController.text = widget.locatario['referencia'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _profissaoController.dispose();
    _rendaController.dispose();
    _cnhController.dispose();
    _estadoCivilController.dispose();
    _dataNascimentoController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  Future<void> _updateLocatario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final locatarioData = {
        'nome': _nameController.text,
        'cpf': _cpfController.text,
        'rg': _rgController.text,
        'telefone': _telefoneController.text,
        'email': _emailController.text,
        'profissao': _profissaoController.text,
        'renda': _rendaController.text,
        'cnh': _cnhController.text,
        'estado_civil': _estadoCivilController.text,
        'data_nascimento': _dataNascimentoController.text,
        'referencia': _referenciaController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await DatabaseService.updateLocatario(widget.locatario['id'].toString(), locatarioData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Locatário atualizado com sucesso!'),
              ],
            ),
            backgroundColor: const Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Forçar recarga da UserHubScreen
        UserHubScreen.refreshData();
        
        // Voltar para a tela de detalhes
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Erro ao atualizar locatário: ${e.toString()}'),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A5568),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFF59E0B)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Editar Locatário',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          Text(
                            'ID: ${widget.locatario['id'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSectionTitle('Dados Pessoais'),
                        _buildTextField(_nameController, 'Nome completo', Icons.person, validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome completo';
                          }
                          return null;
                        }),
                        _buildTextField(_cpfController, 'CPF', Icons.badge, validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o CPF';
                          }
                          return null;
                        }),
                        _buildTextField(_rgController, 'RG', Icons.credit_card),
                        _buildTextField(_dataNascimentoController, 'Data de Nascimento', Icons.calendar_today),
                        _buildTextField(_estadoCivilController, 'Estado Civil', Icons.favorite),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Contato'),
                        _buildTextField(_telefoneController, 'Telefone', Icons.phone, validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o telefone';
                          }
                          return null;
                        }),
                        _buildTextField(_emailController, 'Email', Icons.email),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Informações Profissionais'),
                        _buildTextField(_profissaoController, 'Profissão', Icons.work),
                        _buildTextField(_rendaController, 'Renda', Icons.attach_money),
                        _buildTextField(_cnhController, 'CNH', Icons.drive_eta),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Referência'),
                        _buildTextField(_referenciaController, 'Referência Pessoal', Icons.people),

                        const SizedBox(height: 40),
                        _buildSaveButton(),
                        const SizedBox(height: 40),
                      ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A5568),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          color: Color(0xFFE2E8F0),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFF59E0B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _updateLocatario,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Salvar Alterações',
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
    );
  }
}

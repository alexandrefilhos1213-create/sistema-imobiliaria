import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';
import 'package:sistema_imobiliaria/screens/user_hub_screen.dart';

class EditImovelScreen extends StatefulWidget {
  final Map<String, dynamic> imovel;

  const EditImovelScreen({super.key, required this.imovel});

  @override
  State<EditImovelScreen> createState() => _EditImovelScreenState();
}

class _EditImovelScreenState extends State<EditImovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _enderecoController = TextEditingController();
  final _tipoController = TextEditingController();
  final _valorController = TextEditingController();
  final _areaController = TextEditingController();
  final _quartosController = TextEditingController();
  final _banheirosController = TextEditingController();
  final _vagasController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _unidadeConsumidoraNumeroController = TextEditingController();
  final _unidadeConsumidoraTitularController = TextEditingController();
  final _unidadeConsumidoraCpfController = TextEditingController();
  final _gasNumeroContaController = TextEditingController();
  final _gasTitularController = TextEditingController();
  final _gasCpfController = TextEditingController();
  final _aguaNumeroContaController = TextEditingController();
  final _aguaTitularController = TextEditingController();
  final _saneagoNumeroContaController = TextEditingController();
  final _saneagoTitularController = TextEditingController();
  final _saneagoCpfController = TextEditingController();
  final _cadastroIptuController = TextEditingController();
  final _condominioTitularController = TextEditingController();
  final _condominioValorEstimadoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateFields();
  }

  void _populateFields() {
    _enderecoController.text = widget.imovel['endereco'] ?? '';
    _tipoController.text = widget.imovel['tipo'] ?? '';
    _valorController.text = widget.imovel['valor']?.toString() ?? '';
    _areaController.text = widget.imovel['area']?.toString() ?? '';
    _quartosController.text = widget.imovel['quartos']?.toString() ?? '';
    _banheirosController.text = widget.imovel['banheiros']?.toString() ?? '';
    _vagasController.text = widget.imovel['vagas']?.toString() ?? '';
    _descricaoController.text = widget.imovel['descricao'] ?? '';
    _unidadeConsumidoraNumeroController.text = widget.imovel['unidade_consumidora_numero'] ?? '';
    _unidadeConsumidoraTitularController.text = widget.imovel['unidade_consumidora_titular'] ?? '';
    _unidadeConsumidoraCpfController.text = widget.imovel['unidade_consumidora_cpf'] ?? '';
    _gasNumeroContaController.text = widget.imovel['gas_numero_conta'] ?? '';
    _gasTitularController.text = widget.imovel['gas_titular'] ?? '';
    _gasCpfController.text = widget.imovel['gas_cpf'] ?? '';
    _aguaNumeroContaController.text = widget.imovel['agua_numero_conta'] ?? '';
    _aguaTitularController.text = widget.imovel['agua_titular'] ?? '';
    _saneagoNumeroContaController.text = widget.imovel['saneago_numero_conta'] ?? '';
    _saneagoTitularController.text = widget.imovel['saneago_titular'] ?? '';
    _saneagoCpfController.text = widget.imovel['saneago_cpf'] ?? '';
    _cadastroIptuController.text = widget.imovel['cadastro_iptu'] ?? '';
    _condominioTitularController.text = widget.imovel['condominio_titular'] ?? '';
    _condominioValorEstimadoController.text = widget.imovel['condominio_valor_estimado']?.toString() ?? '';
  }

  @override
  void dispose() {
    _enderecoController.dispose();
    _tipoController.dispose();
    _valorController.dispose();
    _areaController.dispose();
    _quartosController.dispose();
    _banheirosController.dispose();
    _vagasController.dispose();
    _descricaoController.dispose();
    _unidadeConsumidoraNumeroController.dispose();
    _unidadeConsumidoraTitularController.dispose();
    _unidadeConsumidoraCpfController.dispose();
    _gasNumeroContaController.dispose();
    _gasTitularController.dispose();
    _gasCpfController.dispose();
    _aguaNumeroContaController.dispose();
    _aguaTitularController.dispose();
    _saneagoNumeroContaController.dispose();
    _saneagoTitularController.dispose();
    _saneagoCpfController.dispose();
    _cadastroIptuController.dispose();
    _condominioTitularController.dispose();
    _condominioValorEstimadoController.dispose();
    super.dispose();
  }

  Future<void> _updateImovel() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imovelData = {
        'endereco': _enderecoController.text,
        'tipo': _tipoController.text,
        'valor': _valorController.text,
        'area': _areaController.text,
        'quartos': _quartosController.text,
        'banheiros': _banheirosController.text,
        'vagas': _vagasController.text,
        'descricao': _descricaoController.text,
        'unidade_consumidora_numero': _unidadeConsumidoraNumeroController.text,
        'unidade_consumidora_titular': _unidadeConsumidoraTitularController.text,
        'unidade_consumidora_cpf': _unidadeConsumidoraCpfController.text,
        'gas_numero_conta': _gasNumeroContaController.text,
        'gas_titular': _gasTitularController.text,
        'gas_cpf': _gasCpfController.text,
        'agua_numero_conta': _aguaNumeroContaController.text,
        'agua_titular': _aguaTitularController.text,
        'saneago_numero_conta': _saneagoNumeroContaController.text,
        'saneago_titular': _saneagoTitularController.text,
        'saneago_cpf': _saneagoCpfController.text,
        'cadastro_iptu': _cadastroIptuController.text,
        'condominio_titular': _condominioTitularController.text,
        'condominio_valor_estimado': _condominioValorEstimadoController.text,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await DatabaseService.updateImovel(widget.imovel['id'].toString(), imovelData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Imóvel atualizado com sucesso!'),
              ],
            ),
            backgroundColor: const Color(0xFF3B82F6),
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
                Text('Erro ao atualizar imóvel: ${e.toString()}'),
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
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Editar Imóvel',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          Text(
                            'ID: ${widget.imovel['id'] ?? 'N/A'}',
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
                        _buildSectionTitle('Informações Básicas'),
                        _buildTextField(_enderecoController, 'Endereço', Icons.location_on, validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o endereço';
                          }
                          return null;
                        }),
                        _buildTextField(_tipoController, 'Tipo de Imóvel', Icons.apartment, validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o tipo do imóvel';
                          }
                          return null;
                        }),
                        _buildTextField(_valorController, 'Valor', Icons.attach_money, validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o valor';
                          }
                          return null;
                        }),
                        _buildTextField(_areaController, 'Área (m²)', Icons.square_foot),
                        _buildTextField(_quartosController, 'Quartos', Icons.bed),
                        _buildTextField(_banheirosController, 'Banheiros', Icons.bathtub),
                        _buildTextField(_vagasController, 'Vagas', Icons.local_parking),
                        _buildTextField(_descricaoController, 'Descrição', Icons.description, maxLines: 3),

                        const SizedBox(height: 32),
                        _buildSectionTitle('Contas e Serviços'),
                        _buildTextField(_unidadeConsumidoraNumeroController, 'Número da Unidade Consumidora', Icons.electrical_services),
                        _buildTextField(_unidadeConsumidoraTitularController, 'Titular da Unidade Consumidora', Icons.person),
                        _buildTextField(_unidadeConsumidoraCpfController, 'CPF do Titular', Icons.badge),
                        _buildTextField(_gasNumeroContaController, 'Número da Conta de Gás', Icons.local_fire_department),
                        _buildTextField(_gasTitularController, 'Titular da Conta de Gás', Icons.person),
                        _buildTextField(_gasCpfController, 'CPF do Titular do Gás', Icons.badge),
                        _buildTextField(_aguaNumeroContaController, 'Número da Conta de Água', Icons.water_drop),
                        _buildTextField(_aguaTitularController, 'Titular da Conta de Água', Icons.person),
                        _buildTextField(_saneagoNumeroContaController, 'Número da Conta Saneago', Icons.water_drop),
                        _buildTextField(_saneagoTitularController, 'Titular da Conta Saneago', Icons.person),
                        _buildTextField(_saneagoCpfController, 'CPF do Titular Saneago', Icons.badge),
                        _buildTextField(_cadastroIptuController, 'Cadastro IPTU', Icons.description),
                        _buildTextField(_condominioTitularController, 'Titular do Condomínio', Icons.apartment),
                        _buildTextField(_condominioValorEstimadoController, 'Valor Estimado do Condomínio', Icons.attach_money),

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
            color: Color(0xFF3B82F6),
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
    int maxLines = 1,
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
        maxLines: maxLines,
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
          prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
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
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _updateImovel,
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

import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';

class AddImovelScreen extends StatefulWidget {
  const AddImovelScreen({super.key});

  @override
  State<AddImovelScreen> createState() => _AddImovelScreenState();
}

class _AddImovelScreenState extends State<AddImovelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _valorController = TextEditingController();
  final _areaController = TextEditingController();
  final _quartosController = TextEditingController();
  final _suitesController = TextEditingController();
  final _banheirosController = TextEditingController();
  final _vagasController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _tipoImovel = 'Apartamento';
  String _situacao = 'Disponível';
  bool _mobiliado = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _enderecoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    _valorController.dispose();
    _areaController.dispose();
    _quartosController.dispose();
    _suitesController.dispose();
    _banheirosController.dispose();
    _vagasController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
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
                      'Novo Imóvel',
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
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add_home,
                        color: Color(0xFF3B82F6),
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
                                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: const Icon(
                                  Icons.add_home,
                                  size: 40,
                                  color: Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Form fields
                            _buildSectionTitle('Informações Básicas'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _tituloController,
                              label: 'Título do Imóvel',
                              hint: 'Apartamento com 2 quartos no Centro',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o título';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Tipo de Imóvel',
                              value: _tipoImovel,
                              items: ['Apartamento', 'Casa', 'Cobertura', 'Kitnet', 'Studio', 'Terreno', 'Sala Comercial', 'Loja'],
                              onChanged: (value) {
                                setState(() {
                                  _tipoImovel = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              label: 'Situação',
                              value: _situacao,
                              items: ['Disponível', 'Alugado', 'Vendido', 'Em Manutenção'],
                              onChanged: (value) {
                                setState(() {
                                  _situacao = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Localização'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _enderecoController,
                              label: 'Endereço',
                              hint: 'Rua das Flores, 123',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o endereço';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _bairroController,
                                    label: 'Bairro',
                                    hint: 'Centro',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _cepController,
                                    label: 'CEP',
                                    hint: '74000-000',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                    controller: _cidadeController,
                                    label: 'Cidade',
                                    hint: 'Goiânia',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _estadoController,
                                    label: 'UF',
                                    hint: 'GO',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Características'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _areaController,
                                    label: 'Área (m²)',
                                    hint: '85',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _valorController,
                                    label: 'Valor (R\$)',
                                    hint: '1.200',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _quartosController,
                                    label: 'Quartos',
                                    hint: '2',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _suitesController,
                                    label: 'Suítes',
                                    hint: '1',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _banheirosController,
                                    label: 'Banheiros',
                                    hint: '2',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _vagasController,
                              label: 'Vagas de Garagem',
                              hint: '1',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            _buildSwitchField(
                              label: 'Mobiliado',
                              value: _mobiliado,
                              onChanged: (value) {
                                setState(() {
                                  _mobiliado = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Descrição'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _descricaoController,
                              label: 'Descrição do Imóvel',
                              hint: 'Apartamento bem localizado, próximo ao comércio...',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _observacoesController,
                              label: 'Observações Adicionais',
                              hint: 'Informações complementares...',
                              maxLines: 3,
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
        labelStyle: const TextStyle(color: Color(0xFF3B82F6)),
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D3142),
      ),
      style: const TextStyle(color: Color(0xFFE2E8F0)),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF3B82F6)),
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
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2D3142),
      ),
      style: const TextStyle(color: Color(0xFFE2E8F0)),
      dropdownColor: const Color(0xFF2D3142),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Color(0xFFE2E8F0)),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3142),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4A5568), width: 1),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFFE2E8F0),
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFF4A5568),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
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
              final imovelData = {
                'titulo': _tituloController.text,
                'tipo': _tipoImovel,
                'situacao': _situacao,
                'endereco': _enderecoController.text,
                'bairro': _bairroController.text,
                'cidade': _cidadeController.text,
                'estado': _estadoController.text,
                'cep': _cepController.text,
                'valor': _valorController.text,
                'area': _areaController.text,
                'quartos': _quartosController.text,
                'suites': _suitesController.text,
                'banheiros': _banheirosController.text,
                'vagas': _vagasController.text,
                'mobiliado': _mobiliado,
                'descricao': _descricaoController.text,
                'observacoes': _observacoesController.text,
              };

              try {
                await DatabaseService.addImovel(imovelData);
                
                // Mostrar mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Imóvel salvo com sucesso!'),
                    backgroundColor: Color(0xFF3B82F6),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Voltar para a tela anterior
                Navigator.pop(context);
              } catch (e) {
                // Mostrar mensagem de erro
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao salvar imóvel!'),
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
                'Salvar Imóvel',
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

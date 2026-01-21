import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';
import 'package:sistema_imobiliaria/screens/user_hub_screen.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class AddImovelScreen extends StatefulWidget {
  const AddImovelScreen({super.key});

  @override
  State<AddImovelScreen> createState() => _AddImovelScreenState();
}

class _AddImovelScreenState extends State<AddImovelScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Campos obrigatórios
  final _enderecoController = TextEditingController();
  final _tipoController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cadastroIptuController = TextEditingController();
  
  // Campos de energia elétrica
  final _unidadeConsumidoraNumeroController = TextEditingController();
  final _unidadeConsumidoraTitularController = TextEditingController();
  final _unidadeConsumidoraCpfController = TextEditingController();
  
  // Campos de água (Saneago)
  final _saneagoNumeroContaController = TextEditingController();
  final _saneagoTitularController = TextEditingController();
  final _saneagoCpfController = TextEditingController();
  
  // Campos de gás
  final _gasNumeroContaController = TextEditingController();
  final _gasTitularController = TextEditingController();
  final _gasCpfController = TextEditingController();
  
  // Campos de condomínio
  final _condominioTitularController = TextEditingController();
  final _condominioValorEstimadoController = TextEditingController();
  
  // Campos de localização
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  
  // Campos de características
  final _areaController = TextEditingController();
  final _quartosController = TextEditingController();
  final _banheirosController = TextEditingController();
  final _vagasController = TextEditingController();
  
  // Campos do locador
  final _locadorNomeController = TextEditingController();
  final _locadorCpfController = TextEditingController();
  final _locadorTelefoneController = TextEditingController();
  final _locadorEmailController = TextEditingController();
  
  // Campos do locatário
  final _locatarioNomeController = TextEditingController();
  final _locatarioCpfController = TextEditingController();
  final _locatarioTelefoneController = TextEditingController();
  final _locatarioEmailController = TextEditingController();
  
  // Chaves estrangeiras
  int? _selectedLocadorId;
  int? _selectedLocatarioId;
  
  // Lista de locadores e locatários (virá da API)
  List<Map<String, dynamic>> _locadores = [];
  List<Map<String, dynamic>> _locatarios = [];
  
  String _tipoImovel = 'Apartamento';
  String _situacao = 'Disponível';
  bool _mobiliado = false;
  
  // Controle de imagens
  final List<XFile> _imagens = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Máscarers
  final _cpfMaskFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      if (newText.length > 11) {
        newText = newText.substring(0, 11);
      }
      
      if (newText.length <= 3) {
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      } else if (newText.length <= 6) {
        return TextEditingValue(
          text: '${newText.substring(0, 3)}.${newText.substring(3)}',
          selection: TextSelection.collapsed(offset: newText.length + 1),
        );
      } else {
        return TextEditingValue(
          text: '${newText.substring(0, 3)}.${newText.substring(3, 6)}.${newText.substring(6)}',
          selection: TextSelection.collapsed(offset: newText.length + 2),
        );
      }
    },
  );

  final _currencyMaskFormatter = TextInputFormatter.withFunction(
    (oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;
      
      String newText = newValue.text.replaceAll(RegExp(r'[^0-9,]'), '');
      List<String> parts = newText.split(',');
      
      if (parts.length > 2) {
        parts = [parts[0], parts.sublist(1).join('')];
      }
      
      if (parts[0].length > 6) {
        parts[0] = parts[0].substring(0, 6);
      }
      
      String formatted = parts.join(',');
      
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    },
  );

  @override
  void initState() {
    super.initState();
    _carregarLocadoresELocatarios();
  }

  Future<void> _carregarLocadoresELocatarios() async {
    try {
      // Carregar locadores
      final locadoresResponse = await DatabaseService.getLocadores();
      setState(() {
        _locadores = locadoresResponse;
      });
      
      // Carregar locatários
      final locatariosResponse = await DatabaseService.getLocatarios();
      setState(() {
        _locatarios = locatariosResponse;
      });
    } catch (e) {
      // Silenciar erro em produção
    }
  }

  @override
  void dispose() {
    // Campos obrigatórios
    _enderecoController.dispose();
    _tipoController.dispose();
    
    // Campos opcionais
    _descricaoController.dispose();
    _cadastroIptuController.dispose();
    _unidadeConsumidoraNumeroController.dispose();
    _unidadeConsumidoraTitularController.dispose();
    _unidadeConsumidoraCpfController.dispose();
    _saneagoNumeroContaController.dispose();
    _saneagoTitularController.dispose();
    _saneagoCpfController.dispose();
    _gasNumeroContaController.dispose();
    _gasTitularController.dispose();
    _gasCpfController.dispose();
    _condominioTitularController.dispose();
    _condominioValorEstimadoController.dispose();
    
    super.dispose();
  }

  // Métodos para gerenciar imagens
  Future<void> _adicionarImagem() async {
    if (_imagens.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de 20 imagens permitido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      XFile? imagem;
      
      if (kIsWeb) {
        // Para web, mostrar mensagem temporária
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionalidade de imagens em desenvolvimento para web'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Para móveis, usar image_picker
        imagem = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
      } else {
        // Para outras plataformas (Windows/Linux), mostrar mensagem
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Funcionalidade de imagens disponível apenas em dispositivos móveis'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      if (imagem != null) {
        setState(() {
          _imagens.add(imagem!);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Imagem adicionada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Erro ao adicionar imagem';
      
      // Tratar erros específicos
      if (e.toString().contains('MissingPluginException')) {
        errorMessage = 'Galeria não disponível. Use o navegador web ou dispositivo móvel.';
      } else if (e.toString().contains('PermissionDenied')) {
        errorMessage = 'Permissão negada. Permita o acesso à galeria.';
      } else if (e.toString().contains('ImageFormatException')) {
        errorMessage = 'Formato de imagem não suportado.';
      } else {
        errorMessage = 'Erro ao adicionar imagem: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Converter Data URL para bytes
  Uint8List? _dataUrlToBytes(String dataUrl) {
    try {
      // Remover o prefixo "data:image/...;base64,"
      final headerIndex = dataUrl.indexOf(',');
      if (headerIndex == -1) return null;
      
      final header = dataUrl.substring(0, headerIndex);
      final data = dataUrl.substring(headerIndex + 1);
      
      // Verificar se é base64
      if (!header.contains('base64')) return null;
      
      // Decodificar base64
      final decodedBytes = const Base64Decoder().convert(data);
      return decodedBytes;
    } catch (e) {
      return null;
    }
  }

  void _removerImagem(int index) {
    setState(() {
      _imagens.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Imagem removida'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildImagemGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos do Imóvel (${_imagens.length}/20)',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E8F0),
              ),
            ),
            if (_imagens.length < 20)
              ElevatedButton.icon(
                onPressed: _adicionarImagem,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar Foto'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_imagens.isNotEmpty)
          Container(
            height: 200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _imagens.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4A5568)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                          ? Image.network(
                              _imagens[index].path,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF4A5568),
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Color(0xFF9CA3AF),
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Image.file(
                              File(_imagens[index].path),
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF4A5568),
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Color(0xFF9CA3AF),
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removerImagem(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        if (_imagens.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF4A5568).withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4A5568)),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Nenhuma foto adicionada',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
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

                            // Campo obrigatório: Tipo
                            _buildTextField(
                              controller: _tipoController,
                              label: 'Tipo do Imóvel *',
                              hint: 'Apartamento, Casa, etc.',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, informe o tipo do imóvel';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Campo obrigatório: Endereço
                            _buildTextField(
                              controller: _enderecoController,
                              label: 'Endereço *',
                              hint: 'Rua das Flores, 123',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Por favor, informe o endereço';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Campo opcional: Descrição
                            _buildTextField(
                              controller: _descricaoController,
                              label: 'Descrição',
                              hint: 'Descrição detalhada do imóvel...',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),

                            // Seção: Locador e Locatário
                            _buildSectionTitle('Responsáveis'),
                            const SizedBox(height: 16),

                            // Dropdown Locador
                            _buildDropdownField(
                              label: 'Locador *',
                              value: _selectedLocadorId?.toString(),
                              items: _locadores.map((locador) => 
                                DropdownMenuItem<String>(
                                  value: locador['id'].toString(),
                                  child: Text('${locador['nome']} (${locador['cpf']})'),
                                ),
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocadorId = int.tryParse(value!);
                                });
                              },
                              validator: (value) {
                                if (_selectedLocadorId == null) {
                                  return 'Por favor, selecione um locador';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Dropdown Locatário
                            _buildDropdownField(
                              label: 'Locatário',
                              value: _selectedLocatarioId?.toString(),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: '',
                                  child: Text('Nenhum locatário'),
                                ),
                                ..._locatarios.map((locatario) => 
                                  DropdownMenuItem<String>(
                                    value: locatario['id'].toString(),
                                    child: Text('${locatario['nome']} (${locatario['cpf']})'),
                                  ),
                                ).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocatarioId = value?.isEmpty == true ? null : int.tryParse(value!);
                                });
                              },
                            ),
                            const SizedBox(height: 32),

                            // Seção: Dados de Consumo
                            _buildSectionTitle('Dados de Consumo'),
                            const SizedBox(height: 16),

                            // Cadastro IPTU
                            _buildTextField(
                              controller: _cadastroIptuController,
                              label: 'Cadastro IPTU',
                              hint: 'Número do cadastro IPTU',
                            ),
                            const SizedBox(height: 16),

                            // Unidade Consumidora
                            _buildSectionTitle('Unidade Consumidora (Energia)'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _unidadeConsumidoraNumeroController,
                              label: 'Número da Unidade',
                              hint: 'Número da unidade consumidora',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _unidadeConsumidoraTitularController,
                              label: 'Titular da Unidade',
                              hint: 'Nome do titular',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _unidadeConsumidoraCpfController,
                              label: 'CPF do Titular',
                              hint: '000.000.000-00',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfMaskFormatter],
                            ),
                            const SizedBox(height: 24),

                            // Saneago
                            _buildSectionTitle('SANEAGO (Água)'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _saneagoNumeroContaController,
                              label: 'Número da Conta',
                              hint: 'Número da conta SANEAGO',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _saneagoTitularController,
                              label: 'Titular da Conta',
                              hint: 'Nome do titular',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _saneagoCpfController,
                              label: 'CPF do Titular',
                              hint: '000.000.000-00',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfMaskFormatter],
                            ),
                            const SizedBox(height: 24),

                            // Gás
                            _buildSectionTitle('Gás'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _gasNumeroContaController,
                              label: 'Número da Conta',
                              hint: 'Número da conta de gás',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _gasTitularController,
                              label: 'Titular da Conta',
                              hint: 'Nome do titular',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _gasCpfController,
                              label: 'CPF do Titular',
                              hint: '000.000.000-00',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_cpfMaskFormatter],
                            ),
                            const SizedBox(height: 24),

                            // Condomínio
                            _buildSectionTitle('Condomínio'),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _condominioTitularController,
                              label: 'Titular do Condomínio',
                              hint: 'Nome do titular do condomínio',
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _condominioValorEstimadoController,
                              label: 'Valor Estimado',
                              hint: '0,00',
                              keyboardType: TextInputType.number,
                              inputFormatters: [_currencyMaskFormatter],
                            ),
                            const SizedBox(height: 32),

                            // Campo de Imagens
                            _buildImagemGrid(),
                            const SizedBox(height: 32),

                            // Botão Salvar
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      inputFormatters: inputFormatters,
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
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
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
      items: items,
      onChanged: onChanged,
      validator: validator,
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
              // Mostrar loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                ),
              );

              try {
                // Salvar dados do imóvel no banco
                final imovelData = {
                  // Campos obrigatórios
                  'endereco': _enderecoController.text.trim(),
                  'tipo': _tipoController.text.trim(),
                  
                  // Campos opcionais
                  'descricao': _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
                  'cadastro_iptu': _cadastroIptuController.text.trim().isEmpty ? null : _cadastroIptuController.text.trim(),
                  'unidade_consumidora_numero': _unidadeConsumidoraNumeroController.text.trim().isEmpty ? null : _unidadeConsumidoraNumeroController.text.trim(),
                  'unidade_consumidora_titular': _unidadeConsumidoraTitularController.text.trim().isEmpty ? null : _unidadeConsumidoraTitularController.text.trim(),
                  'unidade_consumidora_cpf': _unidadeConsumidoraCpfController.text.trim().isEmpty ? null : _unidadeConsumidoraCpfController.text.trim(),
                  'saneago_numero_conta': _saneagoNumeroContaController.text.trim().isEmpty ? null : _saneagoNumeroContaController.text.trim(),
                  'saneago_titular': _saneagoTitularController.text.trim().isEmpty ? null : _saneagoTitularController.text.trim(),
                  'saneago_cpf': _saneagoCpfController.text.trim().isEmpty ? null : _saneagoCpfController.text.trim(),
                  'gas_numero_conta': _gasNumeroContaController.text.trim().isEmpty ? null : _gasNumeroContaController.text.trim(),
                  'gas_titular': _gasTitularController.text.trim().isEmpty ? null : _gasTitularController.text.trim(),
                  'gas_cpf': _gasCpfController.text.trim().isEmpty ? null : _gasCpfController.text.trim(),
                  'condominio_titular': _condominioTitularController.text.trim().isEmpty ? null : _condominioTitularController.text.trim(),
                  'condominio_valor_estimado': _condominioValorEstimadoController.text.trim().isEmpty ? null : double.tryParse(_condominioValorEstimadoController.text.replaceAll(',', '.')),
                  
                  // Chaves estrangeiras
                  'id_locador': _selectedLocadorId,
                  'id_locatario': _selectedLocatarioId,
                };

                final result = await DatabaseService.addImovel(imovelData);
                
                // Imóvel salvo com sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Imóvel salvo com sucesso!'),
                    backgroundColor: const Color(0xFF3B82F6),
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                // Forçar recarga da UserHubScreen
                UserHubScreen.refreshData();
                
                // Voltar para a tela anterior
                Navigator.pop(context);
              } catch (e) {
                // Fechar loading
                Navigator.pop(context);
                
                // Mostrar mensagem de erro
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro ao salvar imóvel: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
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

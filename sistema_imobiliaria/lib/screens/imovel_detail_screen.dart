import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';
import 'package:sistema_imobiliaria/screens/user_hub_screen.dart';
import 'package:sistema_imobiliaria/screens/edit_imovel_screen.dart';
import 'dart:convert';
import 'dart:io';

class ImovelDetailScreen extends StatefulWidget {
  final Map<String, dynamic> imovel;

  const ImovelDetailScreen({super.key, required this.imovel});

  @override
  State<ImovelDetailScreen> createState() => _ImovelDetailScreenState();
}

class _ImovelDetailScreenState extends State<ImovelDetailScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  List<XFile> _imagens = [];

  // Getter para acessar o imovel do widget
  Map<String, dynamic> get imovel => widget.imovel;

  @override
  void initState() {
    super.initState();
    
    // Carregar imagens existentes do imóvel (se houver)
    _carregarImagensExistentes();
  }

  void _carregarImagensExistentes() {
    // Aqui você pode carregar imagens existentes do banco
    // Por enquanto, vamos iniciar com lista vazia
    setState(() {
      _imagens = [];
    });
  }

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
        if (_imagens.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _imagens.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // TODO: Implementar visualização ampliada
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            child: kIsWeb
                              ? Image.network(
                                  _imagens[index].path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.withOpacity(0.2),
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 32,
                                      ),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(_imagens[index].path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.withOpacity(0.2),
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white54,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                          ),
                          // Overlay sutil
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent,
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
              },
            ),
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white.withOpacity(0.4),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma imagem cadastrada para este imóvel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // Método para corrigir encoding de caracteres especiais
  String _fixEncoding(String text) {
    if (text == null) return 'Sem dados';
    
    // Substituir caracteres corrompidos por caracteres corretos
    return text
        // Letras minúsculas com acento
        .replaceAll('�', 'á')
        .replaceAll('�', 'à')
        .replaceAll('�', 'â')
        .replaceAll('�', 'ã')
        .replaceAll('�', 'ä')
        .replaceAll('�', 'å')
        .replaceAll('�', 'é')
        .replaceAll('�', 'è')
        .replaceAll('�', 'ê')
        .replaceAll('�', 'ë')
        .replaceAll('�', 'í')
        .replaceAll('�', 'ì')
        .replaceAll('�', 'î')
        .replaceAll('�', 'ï')
        .replaceAll('�', 'ó')
        .replaceAll('�', 'ò')
        .replaceAll('�', 'ô')
        .replaceAll('�', 'õ')
        .replaceAll('�', 'ö')
        .replaceAll('�', 'ø')
        .replaceAll('�', 'ú')
        .replaceAll('�', 'ù')
        .replaceAll('�', 'û')
        .replaceAll('�', 'ü')
        .replaceAll('�', 'ý')
        .replaceAll('�', 'ÿ')
        // Letras maiúsculas com acento
        .replaceAll('�', 'Á')
        .replaceAll('�', 'À')
        .replaceAll('�', 'Â')
        .replaceAll('�', 'Ã')
        .replaceAll('�', 'Ä')
        .replaceAll('�', 'Å')
        .replaceAll('�', 'É')
        .replaceAll('�', 'È')
        .replaceAll('�', 'Ê')
        .replaceAll('�', 'Ë')
        .replaceAll('�', 'Í')
        .replaceAll('�', 'Ì')
        .replaceAll('�', 'Î')
        .replaceAll('�', 'Ï')
        .replaceAll('�', 'Ó')
        .replaceAll('�', 'Ò')
        .replaceAll('�', 'Ô')
        .replaceAll('�', 'Õ')
        .replaceAll('�', 'Ö')
        .replaceAll('�', 'Ø')
        .replaceAll('�', 'Ú')
        .replaceAll('�', 'Ù')
        .replaceAll('�', 'Û')
        .replaceAll('�', 'Ü')
        .replaceAll('�', 'Ý')
        // Caracteres especiais
        .replaceAll('�', 'ç')
        .replaceAll('�', 'Ç')
        .replaceAll('�', 'ñ')
        .replaceAll('�', 'Ñ')
        .replaceAll('�', 'ý')
        // Combinações comuns
        .replaceAll('Jo�o', 'João')
        .replaceAll('S�o', 'São')
        .replaceAll('�', 'ão')
        .replaceAll('�', 'ões')
        .replaceAll('�', 'ãe')
        .replaceAll('�', 'ões');
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
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Detalhes do Imóvel',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                      ),
                      child: IconButton(
                        onPressed: _editImovel,
                        icon: const Icon(Icons.edit, color: Color(0xFF3B82F6), size: 24),
                        tooltip: 'Editar Imóvel',
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        onPressed: () => _showDeleteConfirmation(),
                        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 24),
                        tooltip: 'Excluir Imóvel',
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              // Conteúdo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header com ID e Tipo
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3B82F6).withOpacity(0.1),
                              const Color(0xFF8B5CF6).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ID #${imovel['id']}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _fixEncoding(imovel['tipo'] ?? 'Imóvel'),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Seção - Identificação do Imóvel
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.info_outline,
                              title: 'Identificação do Imóvel',
                            ),
                            _buildInfoRowModern(
                              label: 'ID do Imóvel',
                              value: '${imovel['id'] ?? 'N/A'}',
                              icon: Icons.tag,
                            ),
                            _buildInfoRowModern(
                              label: 'Tipo do Imóvel',
                              value: _formatValue(imovel['tipo']),
                              icon: Icons.category,
                            ),
                            _buildInfoRowModern(
                              label: 'Descrição',
                              value: _formatValue(imovel['descricao']),
                              icon: Icons.description,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Localização
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.location_on_outlined,
                              title: 'Localização',
                              iconColor: const Color(0xFF10B981),
                            ),
                            _buildInfoRowModern(
                              label: 'Endereço Completo',
                              value: _formatValue(imovel['endereco']),
                              icon: Icons.home_outlined,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Cadastro e Documentação
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.description_outlined,
                              title: 'Cadastro e Documentação',
                              iconColor: const Color(0xFFF59E0B),
                            ),
                            _buildInfoRowModern(
                              label: 'Cadastro IPTU',
                              value: _formatValue(imovel['cadastro_iptu']),
                              icon: Icons.receipt_outlined,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Unidade Consumidora (Energia Elétrica)
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.electrical_services_outlined,
                              title: 'Unidade Consumidora (Energia Elétrica)',
                              iconColor: const Color(0xFFEAB308),
                            ),
                            _buildInfoRowModern(
                              label: 'Número da Unidade',
                              value: _formatValue(imovel['unidade_consumidora_numero']),
                              icon: Icons.numbers_outlined,
                            ),
                            _buildInfoRowModern(
                              label: 'Titular da Unidade',
                              value: _formatValue(imovel['unidade_consumidora_titular']),
                              icon: Icons.person_outline,
                            ),
                            _buildInfoRowModern(
                              label: 'CPF do Titular',
                              value: _formatCpf(imovel['unidade_consumidora_cpf']),
                              icon: Icons.badge_outlined,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Saneamento (Saneago)
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.water_drop_outlined,
                              title: 'Saneamento (Saneago)',
                              iconColor: const Color(0xFF06B6D4),
                            ),
                            _buildInfoRowModern(
                              label: 'Número da Conta',
                              value: _formatValue(imovel['saneago_numero_conta']),
                              icon: Icons.numbers_outlined,
                            ),
                            _buildInfoRowModern(
                              label: 'Titular da Conta',
                              value: _formatValue(imovel['saneago_titular']),
                              icon: Icons.person_outline,
                            ),
                            _buildInfoRowModern(
                              label: 'CPF do Titular',
                              value: _formatCpf(imovel['saneago_cpf']),
                              icon: Icons.badge_outlined,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Gás
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.local_fire_department_outlined,
                              title: 'Gás',
                              iconColor: const Color(0xFFEF4444),
                            ),
                            _buildInfoRowModern(
                              label: 'Número da Conta',
                              value: _formatValue(imovel['gas_numero_conta']),
                              icon: Icons.numbers_outlined,
                            ),
                            _buildInfoRowModern(
                              label: 'Titular da Conta',
                              value: _formatValue(imovel['gas_titular']),
                              icon: Icons.person_outline,
                            ),
                            _buildInfoRowModern(
                              label: 'CPF do Titular',
                              value: _formatCpf(imovel['gas_cpf']),
                              icon: Icons.badge_outlined,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Condomínio
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.apartment_outlined,
                              title: 'Condomínio',
                              iconColor: const Color(0xFF8B5CF6),
                            ),
                            _buildInfoRowModern(
                              label: 'Titular do Condomínio',
                              value: _formatValue(imovel['condominio_titular']),
                              icon: Icons.person_outline,
                            ),
                            _buildInfoRowModern(
                              label: 'Valor Estimado',
                              value: _formatCurrency(imovel['condominio_valor_estimado']),
                              icon: Icons.attach_money_outlined,
                            ),
                          ],
                        ),
                      ),

                      // Seção - Responsáveis pelo Imóvel
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.people_outline,
                              title: 'Responsáveis pelo Imóvel',
                              iconColor: const Color(0xFFEC4899),
                            ),
                            
                            // Locador
                            _buildSubSectionHeader('Locador'),
                            const SizedBox(height: 8),
                            if (imovel['locador_nome'] != null) ...[
                              _buildInfoRowModern(
                                label: 'Nome',
                                value: _formatValue(imovel['locador_nome']),
                                icon: Icons.person_outlined,
                              ),
                              _buildInfoRowModern(
                                label: 'CPF',
                                value: _formatCpf(imovel['locador_cpf']),
                                icon: Icons.badge_outlined,
                              ),
                              _buildInfoRowModern(
                                label: 'Telefone',
                                value: _formatValue(imovel['locador_telefone']),
                                icon: Icons.phone_outlined,
                              ),
                              _buildInfoRowModern(
                                label: 'Email',
                                value: _formatValue(imovel['locador_email']),
                                icon: Icons.email_outlined,
                              ),
                            ] else ...[
                              _buildInfoRowModern(
                                label: 'Locador',
                                value: 'Não informado',
                                icon: Icons.person_off_outlined,
                              ),
                            ],
                            const SizedBox(height: 24),
                            
                            // Locatário
                            _buildSubSectionHeader('Locatário'),
                            const SizedBox(height: 8),
                            if (imovel['locatario_nome'] != null) ...[
                              _buildInfoRowModern(
                                label: 'Nome',
                                value: _formatValue(imovel['locatario_nome']),
                                icon: Icons.person_outlined,
                              ),
                              _buildInfoRowModern(
                                label: 'CPF',
                                value: _formatCpf(imovel['locatario_cpf']),
                                icon: Icons.badge_outlined,
                              ),
                              _buildInfoRowModern(
                                label: 'Telefone',
                                value: _formatValue(imovel['locatario_telefone']),
                                icon: Icons.phone_outlined,
                              ),
                              _buildInfoRowModern(
                                label: 'Email',
                                value: _formatValue(imovel['locatario_email']),
                                icon: Icons.email_outlined,
                              ),
                            ] else ...[
                              _buildInfoRowModern(
                                label: 'Locatário',
                                value: 'Sem locatário vinculado',
                                icon: Icons.person_off_outlined,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Seção - Imagens do Imóvel
                      _buildModernCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              icon: Icons.photo_library_outlined,
                              title: 'Imagens do Imóvel',
                              iconColor: const Color(0xFF10B981),
                            ),
                            _buildImagemGrid(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Métodos de formatação para tratar valores nulos e zeros
  String _formatValue(dynamic value, [String? fallback]) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback ?? 'Não informado';
    }
    return _fixEncoding(value.toString());
  }

  String _formatBool(dynamic value) {
    if (value == null) return 'Não informado';
    return value == true ? 'Sim' : 'Não';
  }

  String _formatNumber(dynamic value, String label) {
    if (value == null || value == 0) {
      return '0 $label';
    }
    final num = int.tryParse(value.toString()) ?? 0;
    return '$num $label';
  }

  String _formatArea(dynamic value) {
    if (value == null || value == 0) {
      return 'Não informada';
    }
    final num = double.tryParse(value.toString()) ?? 0;
    return '${num.toStringAsFixed(0)} m²';
  }

  String _formatCurrency(dynamic value) {
    if (value == null || value == 0) {
      return 'Não informado';
    }
    final num = double.tryParse(value.toString()) ?? 0;
    return 'R\$ ${num.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String _formatCpf(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Não informado';
    }
    
    String cpf = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpf.length != 11) {
      return _fixEncoding(value.toString());
    }
    
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  void _editImovel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImovelScreen(imovel: imovel),
      ),
    );
  }

  // Métodos para construir cards modernos
  Widget _buildModernCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 24),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF3B82F6)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor ?? const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowModern({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value == 'Não informado' 
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF3B82F6),
            width: 3,
          ),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3B82F6),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFD97706), // roseGoldStart
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.white, // AppTheme.white
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o imóvel "${imovel['tipo']}" localizado em "${imovel['endereco']}"?\n\nEsta ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Fecha o dialog
                
                // Salvar context antes da operação assíncrona
                final scaffoldContext = context;
                
                try {
                  // Mostrar loading
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(width: 16),
                          Text('Excluindo imóvel...'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Excluir imóvel
                  await DatabaseService.deleteImovel(imovel['id']);

                  // Verificar se o widget ainda está montado antes de usar context
                  if (mounted) {
                    // Forçar recarga da lista na UserHubScreen
                    UserHubScreen.refreshData();
                    
                    // Fechar tela de detalhes
                    Navigator.of(scaffoldContext).pop();

                    // Mostrar sucesso
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Imóvel excluído com sucesso!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Verificar se o widget ainda está montado antes de usar context
                  if (mounted) {
                    // Mostrar erro
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir imóvel: ${e.toString()}'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Excluir',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

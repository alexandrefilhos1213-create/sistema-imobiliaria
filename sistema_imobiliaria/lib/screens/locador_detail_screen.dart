import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';
import 'package:sistema_imobiliaria/screens/user_hub_screen.dart';
import 'package:sistema_imobiliaria/screens/edit_locador_screen.dart';

class LocadorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> locador;

  const LocadorDetailScreen({super.key, required this.locador});

  @override
  State<LocadorDetailScreen> createState() => _LocadorDetailScreenState();
}

class _LocadorDetailScreenState extends State<LocadorDetailScreen> {
  // Getter para acessar o locador do widget
  Map<String, dynamic> get locador => widget.locador;

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

  String _formatValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Não informado';
    }
    return _fixEncoding(value.toString());
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
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
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
                            'Detalhes do Locador',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ID: ${locador['id'] ?? 'N/A'}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        onPressed: () => _showDeleteConfirmation(),
                        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 24),
                        tooltip: 'Excluir Locador',
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informações Pessoais
                      _buildModernCard(
                        icon: Icons.person_outline,
                        title: 'Informações Pessoais',
                        color: const Color(0xFF3B82F6),
                        children: [
                          _buildInfoRow('Nome Completo', _formatValue(locador['nome'])),
                          _buildInfoRow('CPF', _formatValue(locador['cpf'])),
                          _buildInfoRow('RG', _formatValue(locador['rg'])),
                          _buildInfoRow('Estado Civil', _formatValue(locador['estado_civil'])),
                          _buildInfoRow('Data de Nascimento', _formatValue(locador['data_nascimento'])),
                        ],
                      ),

                      // Informações Profissionais
                      _buildModernCard(
                        icon: Icons.work_outline,
                        title: 'Informações Profissionais',
                        color: const Color(0xFF10B981),
                        children: [
                          _buildInfoRow('Profissão', _formatValue(locador['profissao'])),
                          _buildInfoRow('Renda', _formatValue(locador['renda'])),
                          _buildInfoRow('CNH', _formatValue(locador['cnh'])),
                        ],
                      ),

                      // Contato
                      _buildModernCard(
                        icon: Icons.contact_phone_outlined,
                        title: 'Contato',
                        color: const Color(0xFFF59E0B),
                        children: [
                          _buildInfoRow('Telefone', _formatValue(locador['telefone'])),
                          _buildInfoRow('Email', _formatValue(locador['email'])),
                        ],
                      ),

                      // Endereço
                      _buildModernCard(
                        icon: Icons.location_on_outlined,
                        title: 'Endereço',
                        color: const Color(0xFF8B5CF6),
                        children: [
                          _buildInfoRow('Endereço Completo', _formatValue(locador['endereco'])),
                        ],
                      ),

                      // Referência
                      _buildModernCard(
                        icon: Icons.people_outline,
                        title: 'Referência',
                        color: const Color(0xFFEC4899),
                        children: [
                          _buildInfoRow('Referência', _formatValue(locador['referencia'])),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "edit_locador",
            onPressed: _editLocador,
            backgroundColor: const Color(0xFF10B981),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "delete_locador",
            onPressed: _showDeleteConfirmation,
            backgroundColor: const Color(0xFFEF4444),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _editLocador() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLocadorScreen(locador: locador),
      ),
    );
  }

  Widget _buildModernCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

  void _showDeleteConfirmation() {
    // Verificar se o ID do locador é válido antes de prosseguir
    if (locador['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID do locador inválido. Não é possível excluir.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
            'Tem certeza que deseja excluir o locador "${_formatValue(locador['nome'])}" (ID: ${locador['id']})?\n\nEsta ação não pode ser desfeita.',
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
                          Text('Excluindo locador...'),
                        ],
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // Excluir locador
                  await DatabaseService.deleteLocador(locador['id']);

                  // Verificar se o widget ainda está montado antes de usar context
                  if (mounted) {
                    // Forçar recarga da lista na UserHubScreen
                    UserHubScreen.refreshData();
                    
                    // Fechar tela de detalhes
                    Navigator.of(scaffoldContext).pop();

                    // Mostrar sucesso
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Locador excluído com sucesso!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  // Verificar se o widget ainda está montado antes de usar context
                  if (mounted) {
                    // Verificar se é erro 404 (não encontrado)
                    String errorMessage = e.toString();
                    String userMessage = 'Erro ao excluir locador';
                    
                    if (errorMessage.contains('404') || errorMessage.contains('não encontrado')) {
                      userMessage = 'Locador não encontrado. Pode já ter sido excluído por outro usuário.';
                    } else if (errorMessage.contains('connection') || errorMessage.contains('conexão')) {
                      userMessage = 'Sem conexão com o servidor. Verifique sua internet.';
                    }
                    
                    // Mostrar erro
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text(userMessage),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 4),
                        action: SnackBarAction(
                          label: 'Fechar',
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                    
                    // Se for 404, fechar a tela de detalhes pois o registro não existe mais
                    if (errorMessage.contains('404') || errorMessage.contains('não encontrado')) {
                      Future.delayed(Duration(seconds: 2), () {
                        if (mounted) {
                          Navigator.of(scaffoldContext).pop();
                        }
                      });
                    }
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

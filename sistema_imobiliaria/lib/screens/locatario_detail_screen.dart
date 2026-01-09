import 'package:flutter/material.dart';

class LocatarioDetailScreen extends StatelessWidget {
  final Map<String, dynamic> locatario;

  const LocatarioDetailScreen({super.key, required this.locatario});

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
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_outline,
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
                            'Detalhes do Locatário',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'ID: ${locatario['id'] ?? 'N/A'}',
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
                        color: const Color(0xFF10B981),
                        children: [
                          _buildInfoRow('Nome Completo', _formatValue(locatario['nome'])),
                          _buildInfoRow('CPF', _formatValue(locatario['cpf'])),
                          _buildInfoRow('RG', _formatValue(locatario['rg'])),
                          _buildInfoRow('Estado Civil', _formatValue(locatario['estado_civil'])),
                          _buildInfoRow('Data de Nascimento', _formatValue(locatario['data_nascimento'])),
                        ],
                      ),

                      // Informações Profissionais
                      _buildModernCard(
                        icon: Icons.work_outline,
                        title: 'Informações Profissionais',
                        color: const Color(0xFFF59E0B),
                        children: [
                          _buildInfoRow('Profissão', _formatValue(locatario['profissao'])),
                          _buildInfoRow('Renda', _formatValue(locatario['renda'])),
                          _buildInfoRow('CNH', _formatValue(locatario['cnh'])),
                        ],
                      ),

                      // Contato
                      _buildModernCard(
                        icon: Icons.contact_phone_outlined,
                        title: 'Contato',
                        color: const Color(0xFF8B5CF6),
                        children: [
                          _buildInfoRow('Telefone', _formatValue(locatario['telefone'])),
                          _buildInfoRow('Email', _formatValue(locatario['email'])),
                        ],
                      ),

                      // Endereço
                      _buildModernCard(
                        icon: Icons.location_on_outlined,
                        title: 'Endereço',
                        color: const Color(0xFFEC4899),
                        children: [
                          _buildInfoRow('Endereço Completo', _formatValue(locatario['endereco'])),
                        ],
                      ),

                      // Referência
                      _buildModernCard(
                        icon: Icons.people_outline,
                        title: 'Referência',
                        color: const Color(0xFF06B6D4),
                        children: [
                          _buildInfoRow('Referência', _formatValue(locatario['referencia'])),
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
}

class LocatarioDetailScreen2 extends StatelessWidget {
  final Map<String, String> locatario;

  const LocatarioDetailScreen2({super.key, required this.locatario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Locatário'),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar do locatário
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6B46C1).withOpacity(0.8),
                      const Color(0xFF9333EA).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B46C1).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Informações principais
            _buildInfoCard('Informações Pessoais', [
              _buildInfoItem('Nome', locatario['name'] ?? ''),
              if (locatario['telefone'] != null) _buildInfoItem('Telefone', locatario['telefone']!),
              if (locatario['email'] != null) _buildInfoItem('Email', locatario['email']!),
              if (locatario['cpf'] != null) _buildInfoItem('CPF', locatario['cpf']!),
              if (locatario['rg'] != null) _buildInfoItem('RG', locatario['rg']!),
            ]),
            
            const SizedBox(height: 24),
            
            // Informações de locação
            _buildInfoCard('Informações de Locação', [
              _buildInfoItem('Status', 'Ativo'),
              _buildInfoItem('Data Início', '01/01/2024'),
              _buildInfoItem('Valor Aluguel', 'R\$ 1.200/mês'),
              _buildInfoItem('Vencimento', 'Todo dia 10'),
            ]),
            
            const SizedBox(height: 24),
            
            // Histórico de pagamentos
            _buildInfoCard('Histórico de Pagamentos', [
              _buildPaymentItem('Dezembro/2024', 'R\$ 1.200', 'Pago', '10/12/2024'),
              _buildPaymentItem('Novembro/2024', 'R\$ 1.200', 'Pago', '08/11/2024'),
              _buildPaymentItem('Outubro/2024', 'R\$ 1.200', 'Pago', '09/10/2024'),
              _buildPaymentItem('Setembro/2024', 'R\$ 1.200', 'Atrasado', '15/09/2024'),
            ]),
            
            const SizedBox(height: 32),
            
            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidade de edição em desenvolvimento'),
                          backgroundColor: Color(0xFF6B46C1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B46C1),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Editar Dados'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Registrar Pagamento'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(String month, String value, String status, String date) {
    Color statusColor = status == 'Pago' ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                month,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: Text(
          'Registrar Pagamento',
          style: TextStyle(color: Colors.grey.shade300),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Mês/Ano',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
              style: TextStyle(color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Valor',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
              style: TextStyle(color: Colors.grey.shade300),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Data de Pagamento',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
              style: TextStyle(color: Colors.grey.shade300),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pagamento registrado com sucesso!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}

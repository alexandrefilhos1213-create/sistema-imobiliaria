import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/theme/app_theme.dart';

class LocatarioDetailScreen extends StatelessWidget {
  final Map<String, dynamic> locatario;

  const LocatarioDetailScreen({super.key, required this.locatario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2B247A),
              Color(0xFF4938A8),
              Color(0xFF8D78FF),
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Detalhes do Locatário',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AppTheme.glassContainer(
                    borderRadius: 20,
                    opacity: 0.05,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppTheme.roseGoldGradient,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.roseGoldStart.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Name
                          Text(
                            locatario['name'] ?? 'Nome não disponível',
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Email
                          Text(
                            locatario['email'] ?? 'Email não disponível',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: AppTheme.bluishGray,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Details
                          _buildDetailItem('Telefone', locatario['phone'] ?? 'Não informado'),
                          _buildDetailItem('CPF', locatario['cpf'] ?? 'Não informado'),
                          _buildDetailItem('Endereço', locatario['address'] ?? 'Não informado'),
                          const SizedBox(height: 30),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: AppTheme.premiumButton(
                                  text: 'Editar',
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: AppTheme.premiumButton(
                                  text: 'Excluir',
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.roseGoldStart,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 16,
              color: AppTheme.white,
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

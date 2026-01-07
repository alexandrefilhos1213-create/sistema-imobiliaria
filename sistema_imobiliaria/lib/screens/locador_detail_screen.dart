import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/theme/app_theme.dart';

class LocadorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> locador;

  const LocadorDetailScreen({super.key, required this.locador});

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
                      'Detalhes do Locador',
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
                            locador['name'] ?? 'Nome não disponível',
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
                            locador['email'] ?? 'Email não disponível',
                            style: TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 16,
                              color: AppTheme.bluishGray,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Details
                          _buildDetailItem('Telefone', locador['phone'] ?? 'Não informado'),
                          _buildDetailItem('CPF', locador['cpf'] ?? 'Não informado'),
                          _buildDetailItem('Endereço', locador['address'] ?? 'Não informado'),
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

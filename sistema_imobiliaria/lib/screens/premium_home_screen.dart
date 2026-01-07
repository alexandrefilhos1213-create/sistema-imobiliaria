import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PremiumHomeScreen extends StatefulWidget {
  const PremiumHomeScreen({super.key});

  @override
  State<PremiumHomeScreen> createState() => _PremiumHomeScreenState();
}

class _PremiumHomeScreenState extends State<PremiumHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Logo premium
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AppTheme.glassContainer(
                      borderRadius: 80,
                      opacity: 0.15,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppTheme.roseGoldGradient,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.roseGoldStart.withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home,
                          size: 60,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Título premium
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    '+ Mais Vida',
                    style: TextStyle(
                      fontFamily: 'Allura',
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.roseGoldStart,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtítulo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Negócios Imobiliários',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Frase de boas-vindas
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.roseGoldStart.withOpacity(0.2),
                      ),
                    ),
                    child: const Text(
                      'Onde seus melhores negócios ganham mais vida',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.lightLavender,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Cards de funcionalidades
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildFeatureCard(
                          'Imóveis Disponíveis',
                          '12 propriedades exclusivas',
                          Icons.home_outlined,
                          () => _navigateToProperties(),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          'Consultores Premium',
                          'Especialistas ao seu dispor',
                          Icons.person_outline,
                          () => _navigateToConsultants(),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          'Avaliações',
                          '5.0 estrelas de satisfação',
                          Icons.star_outline,
                          () => _navigateToReviews(),
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureCard(
                          'Favoritos',
                          'Seus imóveis salvos',
                          Icons.favorite_outline,
                          () => _navigateToFavorites(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botão CTA
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: AppTheme.premiumButton(
                    text: 'Explorar Agora',
                    onPressed: _exploreNow,
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AppTheme.glassContainer(
        borderRadius: 20,
        opacity: 0.08,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppTheme.roseGoldGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppTheme.bluishGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.roseGoldStart,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProperties() {
    // Navegação para lista de imóveis
  }

  void _navigateToConsultants() {
    // Navegação para consultores
  }

  void _navigateToReviews() {
    // Navegação para avaliações
  }

  void _navigateToFavorites() {
    // Navegação para favoritos
  }

  void _exploreNow() {
    // Ação principal
  }
}

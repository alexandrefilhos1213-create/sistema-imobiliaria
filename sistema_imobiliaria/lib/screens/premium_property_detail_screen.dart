import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PremiumPropertyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PremiumPropertyDetailScreen({super.key, required this.property});

  @override
  State<PremiumPropertyDetailScreen> createState() =>
      _PremiumPropertyDetailScreenState();
}

class _PremiumPropertyDetailScreenState
    extends State<PremiumPropertyDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PageController _pageController;
  int _currentImageIndex = 0;

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
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    _pageController = PageController();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
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
              Color(0xFF2B247A),
              Color(0xFF4938A8),
              Color(0xFF8D78FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header com imagem
              _buildImageHeader(),
              
              // Conteúdo do imóvel
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título e preço
                          _buildTitleSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Localização
                          _buildLocationSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Características
                          _buildFeaturesSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Descrição
                          _buildDescriptionSection(),
                          
                          const SizedBox(height: 24),
                          
                          // Consultor responsável
                          _buildConsultantSection(),
                          
                          const SizedBox(height: 32),
                          
                          // Botão de agendar visita
                          AppTheme.premiumButton(
                            text: 'Agendar Visita',
                            onPressed: _scheduleVisit,
                            width: double.infinity,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Botão de WhatsApp
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF25D366).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _contactWhatsApp,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.message,
                                        color: AppTheme.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Conversar no WhatsApp',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
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

  Widget _buildImageHeader() {
    return Container(
      height: 300,
      child: Stack(
        children: [
          // Carrossel de imagens
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: 3, // Simulando 3 imagens
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.roseGoldStart.withOpacity(0.3),
                      AppTheme.softPurple.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.home,
                    size: 80,
                    color: AppTheme.white.withOpacity(0.5),
                  ),
                ),
              );
            },
          ),
          
          // Botão voltar
          Positioned(
            top: 12,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.roseGoldStart.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.white,
                ),
              ),
            ),
          ),
          
          // Indicador de imagens
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index
                        ? AppTheme.roseGoldStart
                        : AppTheme.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          
          // Botão favorito
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.roseGoldStart.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.favorite_border,
                color: AppTheme.roseGoldStart,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.property['title'],
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.property['price'],
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: AppTheme.bluishGray,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return AppTheme.glassContainer(
      borderRadius: 16,
      opacity: 0.08,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.roseGoldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                color: AppTheme.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Localização',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: AppTheme.bluishGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.property['location'],
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return AppTheme.glassContainer(
      borderRadius: 16,
      opacity: 0.08,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Características',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureItem(
                    Icons.bed_outlined,
                    'Dormitórios',
                    '${widget.property['bedrooms']}',
                  ),
                ),
                Expanded(
                  child: _buildFeatureItem(
                    Icons.bathtub_outlined,
                    'Banheiros',
                    '${widget.property['bathrooms']}',
                  ),
                ),
                Expanded(
                  child: _buildFeatureItem(
                    Icons.square_foot,
                    'Área',
                    widget.property['area'],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppTheme.roseGoldGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppTheme.bluishGray,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return AppTheme.glassContainer(
      borderRadius: 16,
      opacity: 0.08,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Descrição',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Uma propriedade excepcional que combina luxo, conforto e localização privilegiada. '
              'Com acabamentos de alta qualidade e design sofisticado, este imóvel oferece '
              'a experiência de vida que você sempre sonhou.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppTheme.bluishGray,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultantSection() {
    return AppTheme.glassContainer(
      borderRadius: 16,
      opacity: 0.08,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.roseGoldGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Consultor Premium',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: AppTheme.bluishGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'João Silva',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.roseGoldStart,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '5.0 (47 avaliações)',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: AppTheme.bluishGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleVisit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.graphiteGray,
        title: const Text(
          'Agendar Visita',
          style: TextStyle(
            fontFamily: 'Montserrat',
            color: AppTheme.white,
          ),
        ),
        content: const Text(
          'Deseja agendar uma visita para este imóvel?',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppTheme.bluishGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.bluishGray),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visita agendada com sucesso!'),
                  backgroundColor: AppTheme.roseGoldStart,
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _contactWhatsApp() {
    // Implementar integração com WhatsApp
  }
}

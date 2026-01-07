import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class PremiumPropertiesScreen extends StatefulWidget {
  const PremiumPropertiesScreen({super.key});

  @override
  State<PremiumPropertiesScreen> createState() => _PremiumPropertiesScreenState();
}

class _PremiumPropertiesScreenState extends State<PremiumPropertiesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> properties = [
    {
      'id': 1,
      'title': 'Mansão dos Sonhos',
      'price': 'R\$ 2.850.000',
      'location': 'Lago Sul, Brasília',
      'bedrooms': 5,
      'bathrooms': 6,
      'area': '850m²',
      'image': 'assets/images/mansion.jpg',
      'featured': true,
    },
    {
      'id': 2,
      'title': 'Apartamento Premium',
      'price': 'R\$ 850.000',
      'location': 'Asa Norte, Brasília',
      'bedrooms': 3,
      'bathrooms': 2,
      'area': '180m²',
      'image': 'assets/images/apartment.jpg',
      'featured': false,
    },
    {
      'id': 3,
      'title': 'Casa de Campo',
      'price': 'R\$ 1.200.000',
      'location': 'Caldas Novas',
      'bedrooms': 4,
      'bathrooms': 3,
      'area': '450m²',
      'image': 'assets/images/country_house.jpg',
      'featured': false,
    },
  ];

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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
              // Header
              _buildHeader(),
              
              // Lista de imóveis
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      final property = properties[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildPropertyCard(property),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.roseGoldStart.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.roseGoldStart,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: const Text(
                  'Imóveis Exclusivos',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.roseGoldStart.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: AppTheme.roseGoldStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          AppTheme.glassContainer(
            borderRadius: 16,
            opacity: 0.1,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar imóveis...',
                hintStyle: TextStyle(
                  color: AppTheme.bluishGray.withOpacity(0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.roseGoldStart,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(
                color: AppTheme.white,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return AppTheme.glassContainer(
      borderRadius: 24,
      opacity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do imóvel
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              gradient: LinearGradient(
                colors: [
                  AppTheme.roseGoldStart.withOpacity(0.3),
                  AppTheme.softPurple.withOpacity(0.3),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Placeholder para imagem
                Center(
                  child: Icon(
                    Icons.home,
                    size: 60,
                    color: AppTheme.white.withOpacity(0.5),
                  ),
                ),
                // Badge de destaque
                if (property['featured'] == true)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppTheme.roseGoldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'DESTAQUE',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                  ),
                // Botão de favorito
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.roseGoldStart.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppTheme.roseGoldStart,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Informações do imóvel
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property['title'],
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    Text(
                      property['price'],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.roseGoldStart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppTheme.bluishGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      property['location'],
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: AppTheme.bluishGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Ícones de características
                Row(
                  children: [
                    _buildFeatureIcon(
                      Icons.bed_outlined,
                      '${property['bedrooms']}',
                    ),
                    const SizedBox(width: 16),
                    _buildFeatureIcon(
                      Icons.bathtub_outlined,
                      '${property['bathrooms']}',
                    ),
                    const SizedBox(width: 16),
                    _buildFeatureIcon(
                      Icons.square_foot,
                      property['area'],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Botão
                AppTheme.premiumButton(
                  text: 'Ver Detalhes',
                  onPressed: () => _viewPropertyDetails(property),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.roseGoldStart,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: AppTheme.bluishGray,
          ),
        ),
      ],
    );
  }

  void _viewPropertyDetails(Map<String, dynamic> property) {
    // Navegação para detalhes do imóvel
  }
}

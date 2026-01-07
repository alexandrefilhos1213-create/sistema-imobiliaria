import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const PremiumBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<PremiumBottomNavBar> createState() => _PremiumBottomNavBarState();
}

class _PremiumBottomNavBarState extends State<PremiumBottomNavBar>
    {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppTheme.roseGoldStart.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.roseGoldStart.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: AppTheme.glassContainer(
          borderRadius: 30,
          opacity: 0.05,
          child: Row(
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Início',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.apartment_outlined,
                label: 'Imóveis',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Perfil',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.search_outlined,
                label: 'Buscar',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = widget.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: isActive ? AppTheme.roseGoldGradient : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.roseGoldStart.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? AppTheme.white : AppTheme.roseGoldStart,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppTheme.white : AppTheme.bluishGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

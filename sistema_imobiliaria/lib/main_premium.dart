import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/premium_home_screen.dart';
import 'screens/premium_properties_screen.dart';
import 'widgets/premium_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  runApp(const MaisVidaApp());
}

class MaisVidaApp extends StatelessWidget {
  const MaisVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '+ Mais Vida – Negócios Imobiliários',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = [
    const PremiumHomeScreen(),
    const PremiumPropertiesScreen(),
    const ProfileScreen(),
    const SearchScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  @override
  void dispose() {
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
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pages.length,
          itemBuilder: (context, index) => _pages[index],
        ),
      ),
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }
}

// Telas placeholder
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        child: const Center(
          child: Text(
            'Perfil',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 24,
              color: AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
        child: const Center(
          child: Text(
            'Buscar',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 24,
              color: AppTheme.white,
            ),
          ),
        ),
      ),
    );
  }
}

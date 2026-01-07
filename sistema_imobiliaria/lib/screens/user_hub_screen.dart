import 'package:flutter/material.dart';
import 'package:sistema_imobiliaria/screens/locador_detail_screen.dart';
import 'package:sistema_imobiliaria/screens/locatario_detail_screen.dart';
import 'package:sistema_imobiliaria/screens/add_locador_screen.dart';
import 'package:sistema_imobiliaria/screens/add_locatario_screen.dart';
import 'package:sistema_imobiliaria/screens/add_imovel_screen.dart';
import 'package:sistema_imobiliaria/services/database_service.dart';

class UserHubScreen extends StatefulWidget {
  const UserHubScreen({super.key});

  @override
  State<UserHubScreen> createState() => _UserHubScreenState();
}

class _UserHubScreenState extends State<UserHubScreen>
    with TickerProviderStateMixin {
  String _activeTab = 'Imóveis';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Listas dinâmicas
  List<Map<String, dynamic>> _locadores = [];
  List<Map<String, dynamic>> _locatarios = [];
  List<Map<String, dynamic>> _imoveis = [];
  
  // Estatísticas dinâmicas
  Map<String, dynamic> _stats = {'imoveis': 0, 'locadores': 0, 'locatarios': 0};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
    
    // Carregar dados do banco
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final locadores = await DatabaseService.getLocadores();
      final locatarios = await DatabaseService.getLocatarios();
      final imoveis = await DatabaseService.getImoveis();
      final stats = await DatabaseService.getStatistics();
      
      setState(() {
        _locadores = locadores;
        _locatarios = locatarios;
        _imoveis = imoveis;
        _stats = stats;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      // Manter dados existentes em caso de erro
    }
  }

  void _refreshData() async {
    await _loadData();
  }

  void _changeTab(String tabName) {
    setState(() {
      _activeTab = tabName;
    });
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A5568),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_outlined,
                            color: Color(0xFFE2E8F0),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-vindo',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              '+ Mais Vida Imóveis',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A5568),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF9CA3AF),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Stats Cards
                    Row(
                      children: [
                        _buildStatCard('Imóveis', _stats['imoveis'].toString(), const Color(0xFF3B82F6)),
                        const SizedBox(width: 12),
                        _buildStatCard('Locadores', _stats['locadores'].toString(), const Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        _buildStatCard('Locatários', _stats['locatarios'].toString(), const Color(0xFFF59E0B)),
                      ],
                    ),
                  ],
                ),
              ),
              // Abas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildTab('Imóveis', _activeTab == 'Imóveis'),
                    const SizedBox(width: 8),
                    _buildTab('Locadores', _activeTab == 'Locadores'),
                    const SizedBox(width: 8),
                    _buildTab('Locatários', _activeTab == 'Locatários'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Conteúdo
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Stack(
                      children: [
                        _buildTabContent(),
                        // Botão flutuante de adicionar
                        Positioned(
                          bottom: 20,
                          left: 24,
                          child: _buildAddButton(),
                        ),
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
  }

  Widget _buildAddButton() {
    IconData icon;
    String label;
    Color color;
    VoidCallback onPressed;

    switch (_activeTab) {
      case 'Imóveis':
        icon = Icons.add_home;
        label = 'Adicionar Imóvel';
        color = const Color(0xFF3B82F6);
        onPressed = () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddImovelScreen()),
          );
          // Recarregar dados quando voltar
          _refreshData();
        };
        break;
      case 'Locadores':
        icon = Icons.person_add;
        label = 'Adicionar Locador';
        color = const Color(0xFF10B981);
        onPressed = () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLocadorScreen()),
          );
          // Recarregar dados quando voltar
          _refreshData();
        };
        break;
      case 'Locatários':
        icon = Icons.person_add;
        label = 'Adicionar Locatário';
        color = const Color(0xFFF59E0B);
        onPressed = () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLocatarioScreen()),
          );
          // Recarregar dados quando voltar
          _refreshData();
        };
        break;
      default:
        icon = Icons.add;
        label = 'Adicionar';
        color = const Color(0xFF4A5568);
        onPressed = () {};
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _changeTab(title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4A5568) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? null : Border.all(
              color: const Color(0xFF4A5568).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? const Color(0xFFE2E8F0) : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_activeTab == 'Imóveis') {
      return _buildImoveisGrid();
    } else if (_activeTab == 'Locadores') {
      return _buildLocadoresGrid();
    } else {
      return _buildLocatariosGrid();
    }
  }

  Widget _buildImoveisGrid() {
    if (_imoveis.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum imóvel cadastrado',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para adicionar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _imoveis.length,
      itemBuilder: (context, index) {
        final imovel = _imoveis[index];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4A5568),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do card
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_outlined,
                    size: 20,
                    color: Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 12),
                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            imovel['tipo'] ?? 'Imóvel',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            imovel['endereco'] ?? 'Endereço não informado',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      if (imovel['descricao'] != null && imovel['descricao'].toString().isNotEmpty)
                        Text(
                          imovel['descricao'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocadoresGrid() {
    if (_locadores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum locador cadastrado',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para adicionar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _locadores.length,
      itemBuilder: (context, index) {
        final locador = _locadores[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF4A5568),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFF10B981), size: 20),
            ),
            title: Text(
              locador['name'] ?? locador['nome'] ?? 'Nome não informado',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E8F0),
              ),
            ),
            subtitle: Text(
              locador['cpf'] ?? 'CPF não informado',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocadorDetailScreen(locador: locador),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLocatariosGrid() {
    if (_locatarios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 64,
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum locatário cadastrado',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para adicionar',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _locatarios.length,
      itemBuilder: (context, index) {
        final locatario = _locatarios[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF4A5568),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline, color: Color(0xFFF59E0B), size: 20),
            ),
            title: Text(
              locatario['name'] ?? locatario['nome'] ?? 'Nome não informado',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2E8F0),
              ),
            ),
            subtitle: Text(
              locatario['email'] ?? locatario['cpf'] ?? 'Dados não informados',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 16,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocatarioDetailScreen(locatario: locatario),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

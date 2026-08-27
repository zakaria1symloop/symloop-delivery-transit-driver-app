import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/bag_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String _locationText = 'Localisation...';
  double? _latitude;
  bool _gpsEnabled = false;

  static const Color _primaryIndigo = Color(0xFF6366F1);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final bagProvider = context.read<BagProvider>();

      await bagProvider.loadBags(driverId: authProvider.user?.id);
      await _getLocation();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationText = 'GPS desactive';
          _gpsEnabled = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationText = 'Permission refusee';
            _gpsEnabled = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationText = 'Permission bloquee';
          _gpsEnabled = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      setState(() {
        _latitude = position.latitude;
        _locationText =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _gpsEnabled = true;
      });
    } catch (e) {
      setState(() {
        _locationText = 'Erreur GPS';
        _gpsEnabled = false;
      });
      debugPrint('GPS Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bagProvider = context.watch<BagProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: _primaryIndigo,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: _primaryIndigo,
                    strokeWidth: 2,
                  ),
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(
                          authProvider, themeProvider, isDark),
                    ),

                    // GPS Location Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: _buildLocationCard(isDark),
                      ),
                    ),

                    // Stats Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStatsGrid(bagProvider, isDark),
                      ),
                    ),

                    // Active Manifest Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child:
                            _buildActiveManifestCard(bagProvider, isDark),
                      ),
                    ),

                    // Recent Bags
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child:
                            _buildRecentBagsCard(bagProvider, isDark),
                      ),
                    ),

                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AuthProvider authProvider,
    ThemeProvider themeProvider,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authProvider.user?.firstName ?? 'Chauffeur',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => themeProvider.toggleTheme(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(8)
                    : Colors.black.withAlpha(5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Iconsax.sun_1 : Iconsax.moon,
                color: isDark ? Colors.white : Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _gpsEnabled
                  ? _successGreen.withAlpha(20)
                  : _errorRed.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Iconsax.gps,
              color: _gpsEnabled ? _successGreen : _errorRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Position actuelle',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _locationText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                    fontFamily: _latitude != null ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _getLocation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryIndigo.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.refresh,
                color: _primaryIndigo,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BagProvider bagProvider, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'En transit',
                value: bagProvider.totalInTransit.toString(),
                icon: Iconsax.truck_fast,
                color: _primaryIndigo,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Livres',
                value: bagProvider.totalCompleted.toString(),
                icon: Iconsax.tick_circle,
                color: _successGreen,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Colis en transit',
                value: bagProvider.totalPackagesInTransit.toString(),
                icon: Iconsax.box_1,
                color: _warningAmber,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: 'Colis livres',
                value: bagProvider.totalPackagesCompleted.toString(),
                icon: Iconsax.box_tick,
                color: _successGreen,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveManifestCard(BagProvider bagProvider, bool isDark) {
    final manifest = bagProvider.activeManifest;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
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
                  color: _primaryIndigo.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.document_text,
                  color: _primaryIndigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Manifeste actif',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (manifest != null) ...[
            _buildManifestRow(
              'Trajet',
              manifest['route_name'] ?? 'N/A',
              isDark,
            ),
            const SizedBox(height: 8),
            _buildManifestRow(
              'Sacs',
              '${manifest['bags_count'] ?? 0} sacs',
              isDark,
            ),
            const SizedBox(height: 8),
            _buildManifestRow(
              'Statut',
              manifest['status_label'] ?? manifest['status'] ?? 'N/A',
              isDark,
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucun manifeste actif',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey.shade600
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManifestRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentBagsCard(BagProvider bagProvider, bool isDark) {
    final recentBags = bagProvider.inTransitBags.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
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
                  color: _warningAmber.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.box,
                  color: _warningAmber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Sacs en transit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Spacer(),
              if (bagProvider.inTransitBags.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primaryIndigo.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${bagProvider.totalInTransit}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _primaryIndigo,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (recentBags.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aucun sac en transit',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.grey.shade600
                        : Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ...recentBags.map(
              (bag) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildBagMiniCard(bag, isDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBagMiniCard(dynamic bag, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(5)
              : Colors.black.withAlpha(5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bag.trackingNumber,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${bag.originName}  -->  ${bag.destinationName}',
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bag.displayStatusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${bag.packageCount} colis',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: bag.displayStatusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

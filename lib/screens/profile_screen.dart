import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _gpsEnabled = false;
  String _gpsStatus = 'Verification...';

  static const Color _primaryIndigo = Color(0xFF6366F1);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _errorRed = Color(0xFFEF4444);
  static const Color _warningAmber = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _checkGps();
  }

  Future<void> _checkGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _gpsEnabled = false;
          _gpsStatus = 'Service desactive';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _gpsEnabled = false;
          _gpsStatus = 'Permission refusee';
        });
        return;
      }

      setState(() {
        _gpsEnabled = true;
        _gpsStatus = 'Actif';
      });
    } catch (e) {
      setState(() {
        _gpsEnabled = false;
        _gpsStatus = 'Erreur';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),

              // User Card
              _buildUserCard(user, isDark),
              const SizedBox(height: 14),

              // Vehicle Card
              _buildVehicleCard(user, isDark),
              const SizedBox(height: 14),

              // GPS Status Card
              _buildGpsCard(isDark),
              const SizedBox(height: 14),

              // Settings Card
              _buildSettingsCard(themeProvider, isDark),
              const SizedBox(height: 14),

              // App Info Card
              _buildAppInfoCard(isDark),
              const SizedBox(height: 14),

              // Logout button
              _buildLogoutButton(authProvider, isDark),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(dynamic user, bool isDark) {
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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryIndigo.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                user != null
                    ? '${user.firstName[0]}${user.lastName[0]}'
                    : '??',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _primaryIndigo,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Chauffeur Transit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
                if (user?.phone != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user!.phone!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _primaryIndigo.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Transit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _primaryIndigo,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(dynamic user, bool isDark) {
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
                  Iconsax.truck,
                  color: _warningAmber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Vehicule',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Plaque',
            user?.vehiclePlate ?? 'Non renseigne',
            Iconsax.card,
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Type',
            user?.vehicleType ?? 'Non renseigne',
            Iconsax.truck_fast,
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Wilaya',
            user?.wilayaName ?? 'Non renseigne',
            Iconsax.map,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildGpsCard(bool isDark) {
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GPS / Localisation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _gpsStatus,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _gpsEnabled
                  ? _successGreen.withAlpha(20)
                  : _errorRed.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _gpsEnabled ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _gpsEnabled ? _successGreen : _errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeProvider themeProvider, bool isDark) {
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
                  Iconsax.setting_2,
                  color: _primaryIndigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Parametres',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Theme toggle
          Row(
            children: [
              Icon(
                themeProvider.isDarkMode ? Iconsax.moon : Iconsax.sun_1,
                size: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mode sombre',
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
              ),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: _primaryIndigo,
                activeTrackColor: _primaryIndigo.withAlpha(77),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard(bool isDark) {
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
        children: [
          _buildInfoRow('Application', 'Transit Driver', Iconsax.mobile, isDark),
          const SizedBox(height: 10),
          _buildInfoRow('Version', '1.0.0', Iconsax.info_circle, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        const Spacer(),
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

  Widget _buildLogoutButton(AuthProvider authProvider, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: authProvider.isLoading
            ? null
            : () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor:
                        isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Deconnexion',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    content: Text(
                      'Voulez-vous vous deconnecter ?',
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Annuler',
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Deconnecter',
                          style: TextStyle(
                            color: _errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  final navigator = Navigator.of(context);
                  await authProvider.logout();
                  if (mounted) {
                    navigator.pushReplacementNamed('/login');
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _errorRed.withAlpha(20),
          foregroundColor: _errorRed,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: _errorRed.withAlpha(50)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.logout, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Se deconnecter',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../models/bag.dart';
import '../providers/auth_provider.dart';
import '../providers/bag_provider.dart';

class BagsScreen extends StatefulWidget {
  const BagsScreen({super.key});

  @override
  State<BagsScreen> createState() => _BagsScreenState();
}

class _BagsScreenState extends State<BagsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _primaryIndigo = Color(0xFF6366F1);
  static const Color _successGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBags());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBags() async {
    final authProvider = context.read<AuthProvider>();
    final bagProvider = context.read<BagProvider>();
    await bagProvider.loadBags(driverId: authProvider.user?.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isDark),

            // Tab Bar
            _buildTabBar(isDark),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBagList(isInTransit: true, isDark: isDark),
                  _buildBagList(isInTransit: false, isDark: isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Mes Sacs',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          Consumer<BagProvider>(
            builder: (context, bagProvider, _) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _primaryIndigo.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bagProvider.totalBags} total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _primaryIndigo,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Consumer<BagProvider>(
      builder: (context, bagProvider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: _primaryIndigo,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor:
                isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                text:
                    'En Transit (${bagProvider.totalInTransit})',
              ),
              Tab(
                text:
                    'Livres (${bagProvider.totalCompleted})',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBagList({required bool isInTransit, required bool isDark}) {
    return Consumer<BagProvider>(
      builder: (context, bagProvider, _) {
        if (bagProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: _primaryIndigo,
              strokeWidth: 2,
            ),
          );
        }

        final bags =
            isInTransit ? bagProvider.inTransitBags : bagProvider.completedBags;

        if (bags.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isInTransit ? Iconsax.truck_fast : Iconsax.tick_circle,
                  size: 48,
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  isInTransit
                      ? 'Aucun sac en transit'
                      : 'Aucun sac livre',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isInTransit
                      ? 'Les sacs assignes apparaitront ici'
                      : 'Les sacs livres apparaitront ici',
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        isDark ? Colors.grey.shade700 : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadBags,
          color: _primaryIndigo,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bags.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildBagCard(bags[index], isDark),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBagCard(Bag bag, bool isDark) {
    return GestureDetector(
      onTap: () => _showBagDetail(bag, isDark),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(8)
                : Colors.black.withAlpha(6),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking number & status
            Row(
              children: [
                Expanded(
                  child: Text(
                    bag.trackingNumber,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                _buildStatusChip(bag),
              ],
            ),
            const SizedBox(height: 10),

            // Route: Origin -> Destination
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _primaryIndigo.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Iconsax.location,
                    color: _primaryIndigo,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bag.originName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color:
                        isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _successGreen.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Iconsax.flag,
                    color: _successGreen,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bag.destinationName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bottom info row
            Row(
              children: [
                _buildInfoChip(
                  icon: Iconsax.box_1,
                  label: '${bag.packageCount} colis',
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                if (bag.destinationWilayaName.isNotEmpty)
                  _buildInfoChip(
                    icon: Iconsax.map,
                    label: bag.destinationWilayaName,
                    isDark: isDark,
                  ),
                const Spacer(),
                if (bag.sealedAt != null)
                  Text(
                    _formatDate(bag.sealedAt!),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Bag bag) {
    final color = bag.displayStatusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        bag.displayStatusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showBagDetail(Bag bag, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BagDetailSheet(bag: bag, isDark: isDark),
    );
  }
}

// ---------- Bag Detail Bottom Sheet ----------

class _BagDetailSheet extends StatelessWidget {
  final Bag bag;
  final bool isDark;

  const _BagDetailSheet({required this.bag, required this.isDark});

  static const Color _primaryIndigo = Color(0xFF6366F1);
  static const Color _successGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A0A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detail du sac',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bag.trackingNumber,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'monospace',
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Route card
                  _buildRouteCard(),
                  const SizedBox(height: 14),

                  // Info card
                  _buildInfoCard(),
                  const SizedBox(height: 14),

                  // Timestamps card
                  _buildTimestampsCard(),

                  // Notes
                  if (bag.notes != null && bag.notes!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _buildNotesCard(),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = bag.displayStatusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(bag.displayStatusIcon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            bag.displayStatusLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
        ),
      ),
      child: Column(
        children: [
          // Origin
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _primaryIndigo.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.location,
                  color: _primaryIndigo,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Origine',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      bag.originName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (bag.originCode.isNotEmpty)
                      Text(
                        bag.originCode,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 18),
                Container(
                  width: 2,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _primaryIndigo.withAlpha(100),
                        _successGreen.withAlpha(100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Destination
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _successGreen.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.flag,
                  color: _successGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      bag.destinationName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (bag.destinationWilayaName.isNotEmpty)
                      Text(
                        bag.destinationWilayaName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Final destination (if multi-hop)
          if (bag.finalDestinationName.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 18),
                  Container(
                    width: 2,
                    height: 20,
                    color: Colors.orange.withAlpha(100),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.location_tick,
                    color: Colors.orange,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destination finale',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        bag.finalDestinationName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
        ),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'Nombre de colis',
            '${bag.packageCount}',
            Iconsax.box_1,
          ),
          _buildDivider(),
          _buildDetailRow(
            'Trajet',
            bag.tripName.isNotEmpty ? bag.tripName : 'Non assigne',
            Iconsax.route_square,
          ),
          if (bag.routingType != null) ...[
            _buildDivider(),
            _buildDetailRow(
              'Type de routage',
              bag.routingType!,
              Iconsax.routing_2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
        ),
      ),
      child: Column(
        children: [
          if (bag.sealedAt != null)
            _buildDetailRow(
              'Scelle le',
              _formatDateTime(bag.sealedAt!),
              Iconsax.lock,
            ),
          if (bag.sealedAt != null && bag.receivedAt != null) _buildDivider(),
          if (bag.receivedAt != null)
            _buildDetailRow(
              'Recu le',
              _formatDateTime(bag.receivedAt!),
              Iconsax.tick_circle,
            ),
          if ((bag.sealedAt != null || bag.receivedAt != null) &&
              bag.createdAt != null)
            _buildDivider(),
          if (bag.createdAt != null)
            _buildDetailRow(
              'Cree le',
              _formatDateTime(bag.createdAt!),
              Iconsax.calendar_1,
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.grey.shade50,
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
              Icon(
                Iconsax.note_text,
                size: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bag.notes!,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(8),
      height: 12,
    );
  }

  String _formatDateTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

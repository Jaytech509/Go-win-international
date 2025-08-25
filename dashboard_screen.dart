import 'package:flutter/material.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/translation_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/screens/board_screen.dart';
import 'package:ascendant_reach/screens/network_screen.dart';
import 'package:ascendant_reach/screens/wallet_screen.dart';
import 'package:ascendant_reach/screens/learning_screen.dart';
import 'package:ascendant_reach/screens/store_screen.dart';
import 'package:ascendant_reach/screens/enhanced_profile_screen.dart';
import 'package:ascendant_reach/screens/admin_approval_screen.dart';
import 'package:ascendant_reach/widgets/common_app_bar.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Member? _currentMember;

  final List<Widget> _screens = [
    const DashboardView(),
    const BoardScreen(),
    const NetworkScreen(),
    const WalletScreen(),
    const LearningScreen(),
    const StoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentMember();
  }

  void _loadCurrentMember() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'dashboard', showActions: true),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard), 
              label: TranslationService.translate('dashboard')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.view_module), 
              label: TranslationService.translate('board')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.people), 
              label: TranslationService.translate('network')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet), 
              label: TranslationService.translate('wallet')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.school), 
              label: TranslationService.translate('learning')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.store), 
              label: TranslationService.translate('store')),
        ],
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Member? _member;

  @override
  void initState() {
    super.initState();
    _loadMember();
  }

  void _loadMember() {
    setState(() {
      _member = StorageService.getCurrentMember();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_member == null)
      return const Center(child: CircularProgressIndicator());

    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            _member!.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${_member!.name}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${_member!.rank.name.toUpperCase()} - Level ${_member!.level}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Referral: ${_member!.referralCode}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Wallet Balance',
                  value: formatter.format(_member!.walletBalance),
                  icon: Icons.account_balance_wallet,
                  color: theme.colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Points',
                  value: '${_member!.points}',
                  icon: Icons.stars,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Direct Referrals',
                  value: '${_member!.directReferrals.length}',
                  icon: Icons.people,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Current Level',
                  value: '${_member!.level}/7',
                  icon: Icons.trending_up,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _QuickActionCard(
                title: 'View Board',
                icon: Icons.view_module,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BoardScreen()),
                ),
              ),
              _QuickActionCard(
                title: 'My Network',
                icon: Icons.people,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NetworkScreen()),
                ),
              ),
              _QuickActionCard(
                title: 'Learning Hub',
                icon: Icons.school,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearningScreen()),
                ),
              ),
              _QuickActionCard(
                title: 'Product Store',
                icon: Icons.store,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StoreScreen()),
                ),
              ),
              _QuickActionCard(
                title: 'Team Pictures',
                icon: Icons.photo_library,
                onTap: () => _showTeamPictures(context),
              ),
              // Admin access - only for admin users
              if (_member!.isAdmin)
                _QuickActionCard(
                  title: 'Admin Panel',
                  icon: Icons.admin_panel_settings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminApprovalScreen()),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTeamPictures(BuildContext context) {
    // Get sample team pictures shared by users
    final teamPictures = _getSampleTeamPictures();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Team Pictures'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: teamPictures.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No team pictures shared yet'),
                      Text('Encourage your team to share photos!',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: teamPictures.length,
                  itemBuilder: (context, index) {
                    final picture = teamPictures[index];
                    return GestureDetector(
                      onTap: () => _showFullscreenImage(context, picture),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: Image.network(
                                  picture['imageUrl']!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Text(
                                    picture['memberName']!,
                                    style: const TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (picture['caption']!.isNotEmpty)
                                    Text(
                                      picture['caption']!,
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey[600]),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFullscreenImage(BuildContext context, Map<String, String> picture) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(picture['memberName']!),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: Image.network(
                picture['imageUrl']!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
            if (picture['caption']!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  picture['caption']!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getSampleTeamPictures() {
    return [
      {
        'imageUrl': 'https://pixabay.com/get/g73b33d8f3be15e3a5a4d09e089e2b95c1b5b9c8be7f2b7e90c86e9b4e6b5d7e7f_1280.jpg',
        'memberName': 'Sarah Johnson',
        'caption': 'Celebrating our team success! 🎉',
      },
      {
        'imageUrl': 'https://pixabay.com/get/g3c6a45b3e8f9c1d2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6_1280.jpg',
        'memberName': 'Michael Chen',
        'caption': 'New product launch event',
      },
      {
        'imageUrl': 'https://pixabay.com/get/g7f5b8c3e2d1a9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9d8c7b6a5f4_1280.jpg',
        'memberName': 'Emma Davis',
        'caption': 'Team building workshop',
      },
      {
        'imageUrl': 'https://pixabay.com/get/g8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7_1280.jpg',
        'memberName': 'James Wilson',
        'caption': 'Training session with the legends',
      },
      {
        'imageUrl': 'https://pixabay.com/get/g4d3c2b1a0f9e8d7c6b5a4f3e2d1c0b9a8f7e6d5c4b3a2f1e0d9c8b7a6f5e4d3_1280.jpg',
        'memberName': 'Lisa Rodriguez',
        'caption': 'Monthly team meeting',
      },
      {
        'imageUrl': 'https://pixabay.com/get/g9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7e6f5a4b3c2d1e0f9a8_1280.jpg',
        'memberName': 'David Kim',
        'caption': 'Achievement awards ceremony',
      },
    ];
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

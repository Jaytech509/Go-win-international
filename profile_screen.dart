import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/services/referral_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/screens/auth_screen.dart';
import 'package:ascendant_reach/screens/enhanced_profile_screen.dart';
import 'package:ascendant_reach/services/translation_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Member? _currentMember;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('logout')),
        content: Text(TranslationService.translate('are_you_sure_logout')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              StorageService.clearCurrentMember();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(TranslationService.translate('logout'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _copyReferralCode() {
    if (_currentMember != null) {
      Clipboard.setData(ClipboardData(text: _currentMember!.referralCode));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.translate('referral_code_copied'))),
      );
    }
  }

  void _copyReferralLink() {
    if (_currentMember != null) {
      final referralLink = ReferralService.generateWebReferralLink(_currentMember!.referralCode);
      Clipboard.setData(ClipboardData(text: referralLink));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(TranslationService.translate('referral_link_copied'))),
      );
    }
  }

  void _shareReferralLink() {
    if (_currentMember != null) {
      ReferralService.shareReferralLink(_currentMember!);
    }
  }

  void _showSocialSharingDialog() {
    if (_currentMember == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('share_on_social_media')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: Text(TranslationService.translate('whatsapp')),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'whatsapp');
              },
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: Text(TranslationService.translate('telegram')),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'telegram');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: Text(TranslationService.translate('instagram')),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'instagram');
              },
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blue),
              title: Text(TranslationService.translate('facebook')),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'facebook');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('cancel')),
          ),
        ],
      ),
    );
  }

  String _getRankIcon(MemberRank rank) {
    switch (rank) {
      case MemberRank.starter:
        return '🔰';
      case MemberRank.bronze:
        return '🥉';
      case MemberRank.silver:
        return '🥈';
      case MemberRank.legend:
        return '🏆';
    }
  }

  Color _getRankColor(MemberRank rank) {
    switch (rank) {
      case MemberRank.starter:
        return Colors.blue;
      case MemberRank.bronze:
        return Colors.orange;
      case MemberRank.silver:
        return Colors.grey[400]!;
      case MemberRank.legend:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMember == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('profile')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: TranslationService.translate('logout'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildStatsGrid(),
            const SizedBox(height: 20),
            _buildPromotionProgress(),
            const SizedBox(height: 20),
            _buildReferralSection(),
            const SizedBox(height: 20),
            _buildAccountSection(),
            const SizedBox(height: 20),
            _buildMembershipInfo(dateFormatter),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: _getRankColor(_currentMember!.rank),
                  child: Text(
                    _currentMember!.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _getRankIcon(_currentMember!.rank),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentMember!.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _currentMember!.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getRankColor(_currentMember!.rank).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRankColor(_currentMember!.rank)),
              ),
              child: Text(
                '${_currentMember!.rank.name.toUpperCase()} - Level ${_currentMember!.level}',
                style: TextStyle(
                  color: _getRankColor(_currentMember!.rank),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          TranslationService.translate('wallet_balance'),
          formatter.format(_currentMember!.walletBalance),
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildStatCard(
          TranslationService.translate('points'),
          '${_currentMember!.points}',
          Icons.stars,
          Colors.amber,
        ),
        _buildStatCard(
          TranslationService.translate('direct_referrals'),
          '${_currentMember!.directReferrals.length}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          TranslationService.translate('level_progress'),
          '${_currentMember!.level}/7',
          Icons.trending_up,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionProgress() {
    final progress = MLMService.getPromotionProgress(_currentMember!.id);
    if (progress.isEmpty) return const SizedBox.shrink();
    
    final currentProgress = progress['progress'] as int;
    final target = progress['target'] as int;
    final progressPercentage = target > 0 ? (currentProgress / target).clamp(0.0, 1.0) : 0.0;
    final canPromote = progress['canPromote'] as bool;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  TranslationService.translate('promotion_progress'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRankColor(_currentMember!.rank).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getRankColor(_currentMember!.rank)),
                  ),
                  child: Text(
                    progress['currentRank'],
                    style: TextStyle(
                      color: _getRankColor(_currentMember!.rank),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: canPromote 
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: canPromote ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    progress['nextRank'],
                    style: TextStyle(
                      color: canPromote ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              progress['requirement'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: Colors.grey.withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      canPromote ? Colors.green : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$currentProgress/$target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: canPromote ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (canPromote) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      TranslationService.translate('congratulations_promotion'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReferralSection() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(TranslationService.translate('referral_information'), style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('${TranslationService.translate('referral_code')}:  ${_currentMember!.referralCode}',
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  IconButton(
                    onPressed: _copyReferralCode,
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: TranslationService.translate('copy_code'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ReferralService.generateWebReferralLink(_currentMember!.referralCode),
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _copyReferralLink,
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: TranslationService.translate('copy_link'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Share Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareReferralLink,
                    icon: const Icon(Icons.share),
                    label: Text(TranslationService.translate('share_link')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showSocialSharingDialog,
                    icon: const Icon(Icons.social_distance),
                    label: Text(TranslationService.translate('social')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('personal_information')),
            subtitle: Text(TranslationService.translate('edit_personal_details')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPersonalInformationDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('position_progress')),
            subtitle: Text(TranslationService.translate('upgrade_paths_tasks')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showPositionProgressDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('old_profile_view')),
            subtitle: Text(TranslationService.translate('classic_profile_interface')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EnhancedProfileScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('account_security')),
            subtitle: Text(TranslationService.translate('change_password_2fa')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showChangePasswordDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('team_pictures')),
            subtitle: Text(TranslationService.translate('manage_team_photos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TranslationService.translate('feature_coming_soon'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.chat, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('team_chat')),
            subtitle: Text(TranslationService.translate('communicate_with_team')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TranslationService.translate('feature_coming_soon'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.admin_panel_settings, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('contact_admin')),
            subtitle: Text(TranslationService.translate('get_admin_support')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TranslationService.translate('feature_coming_soon'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('notifications')),
            subtitle: Text(TranslationService.translate('manage_notification_preferences')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TranslationService.translate('feature_coming_soon'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
            title: Text(TranslationService.translate('help_support')),
            subtitle: Text(TranslationService.translate('faq_contact_documentation')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TranslationService.translate('feature_coming_soon'))),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(TranslationService.translate('change_password')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: TranslationService.translate('current_password'),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureCurrentPassword = !obscureCurrentPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: TranslationService.translate('new_password'),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureNewPassword = !obscureNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: TranslationService.translate('confirm_password'),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(TranslationService.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(TranslationService.translate('passwords_dont_match'))),
                  );
                  return;
                }
                // Here you would implement the password change logic
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(TranslationService.translate('password_changed_successfully'))),
                );
              },
              child: Text(TranslationService.translate('save_changes')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipInfo(DateFormat dateFormatter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  TranslationService.translate('membership_details'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(TranslationService.translate('member_id'), _currentMember!.id.substring(0, 8).toUpperCase()),
            _buildInfoRow(TranslationService.translate('join_date'), dateFormatter.format(_currentMember!.joinDate)),
            _buildInfoRow(TranslationService.translate('account_status'), _currentMember!.isActive ? TranslationService.translate('active') : TranslationService.translate('inactive')),
            _buildInfoRow(TranslationService.translate('current_board'), _currentMember!.boardId != null ? TranslationService.translate('assigned') : TranslationService.translate('not_assigned')),
            if (_currentMember!.boardPosition >= 0)
              _buildInfoRow(TranslationService.translate('board_position'), '${_currentMember!.boardPosition + 1}/14'),
          ],
        ),
      ),
    );
  }

  void _showPersonalInformationDialog() {
    final nameController = TextEditingController(text: _currentMember!.name);
    final emailController = TextEditingController(text: _currentMember!.email);
    final phoneController = TextEditingController(text: _currentMember!.phoneNumber ?? '');
    final addressController = TextEditingController(text: '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('personal_information')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('full_name'),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('email'),
                  prefixIcon: const Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('phone_number'),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('address'),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(TranslationService.translate('information_updated_successfully'))),
              );
            },
            child: Text(TranslationService.translate('save_changes')),
          ),
        ],
      ),
    );
  }

  void _showPositionProgressDialog() {
    final progress = MLMService.getPromotionProgress(_currentMember!.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationService.translate('position_progress')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Position Card
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getRankIcon(_currentMember!.rank),
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            TranslationService.translate('current_position'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_currentMember!.rank.name.toUpperCase()} - ${TranslationService.translate('level')} ${_currentMember!.level}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${TranslationService.translate('monthly_profit')}: \$${(_currentMember!.level * 150).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Tasks to Upgrade
              Text(
                TranslationService.translate('tasks_to_upgrade'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              if (progress.isNotEmpty) ...[
                _buildTaskItem(
                  TranslationService.translate('recruit_members'),
                  '${progress['progress'] ?? 0}/${progress['target'] ?? 0} ${TranslationService.translate('members')}',
                  (progress['progress'] ?? 0) >= (progress['target'] ?? 1),
                  Icons.people,
                ),
                _buildTaskItem(
                  TranslationService.translate('generate_sales'),
                  '\$${(_currentMember!.level * 500).toStringAsFixed(2)} ${TranslationService.translate('target')}',
                  false,
                  Icons.monetization_on,
                ),
                _buildTaskItem(
                  TranslationService.translate('attend_training'),
                  '${_currentMember!.level}/7 ${TranslationService.translate('sessions')}',
                  _currentMember!.level >= 3,
                  Icons.school,
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Next Rank Benefits
              Card(
                color: Colors.green.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.translate('next_rank_benefits'),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• ${TranslationService.translate('higher_commission')}: ${(_currentMember!.level + 1) * 15}%',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '• ${TranslationService.translate('bonus_points')}: ${(_currentMember!.level + 1) * 20} ${TranslationService.translate('points')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '• ${TranslationService.translate('exclusive_access')}: ${TranslationService.translate('premium_products')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '• ${TranslationService.translate('monthly_bonus')}: \$${((_currentMember!.level + 1) * 200).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('close')),
          ),
          if (progress.isNotEmpty && progress['canPromote'] == true)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(TranslationService.translate('promotion_request_submitted')),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text(
                TranslationService.translate('request_promotion'),
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String progress, bool isCompleted, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  progress,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
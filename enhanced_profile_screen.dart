import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/services/referral_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/screens/auth_screen.dart';
import 'package:ascendant_reach/services/translation_service.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen> {
  Member? _currentMember;
  bool _isEditing = false;
  
  // Edit controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
      if (_currentMember != null) {
        _nameController.text = _currentMember!.name;
        _phoneController.text = _currentMember!.phoneNumber;
      }
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  
  void _saveChanges() async {
    await _saveProfile();
    setState(() {
      _isEditing = false;
    });
  }
  
  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset to original values
      if (_currentMember != null) {
        _nameController.text = _currentMember!.name;
        _phoneController.text = _currentMember!.phoneNumber;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_currentMember == null) return;
    
    try {
      // Update member data
      final updatedMember = Member(
        id: _currentMember!.id,
        name: _nameController.text.trim(),
        email: _currentMember!.email,
        phoneNumber: _phoneController.text.trim(),
        referralCode: _currentMember!.referralCode,
        referredBy: _currentMember!.referredBy,
        joinDate: _currentMember!.joinDate,
        rank: _currentMember!.rank,
        level: _currentMember!.level,
        boardId: _currentMember!.boardId,
        boardPosition: _currentMember!.boardPosition,
        directReferrals: _currentMember!.directReferrals,
        points: _currentMember!.points,
        walletBalance: _currentMember!.walletBalance,
        earningWallet: _currentMember!.earningWallet,
        isActive: _currentMember!.isActive,
        isAdmin: _currentMember!.isAdmin,
        profilePicture: _currentMember!.profilePicture,
        boardJoinStatus: _currentMember!.boardJoinStatus,
        approvalDate: _currentMember!.approvalDate,
      );
      
      // Update in storage
      final members = StorageService.getMembers();
      final index = members.indexWhere((m) => m.id == _currentMember!.id);
      if (index != -1) {
        members[index] = updatedMember;
        await StorageService.saveMembers(members);
        await StorageService.saveCurrentMember(updatedMember);
        
        setState(() {
          _currentMember = updatedMember;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Profile updated successfully!',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error updating profile: $e',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changeProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // In a real app, you would upload the image to a server
      // For now, we'll just generate a random avatar
      final newAvatarUrl = 'https://picsum.photos/200/200?random=${DateTime.now().millisecondsSinceEpoch}';
      
      if (_currentMember != null) {
        final updatedMember = Member(
          id: _currentMember!.id,
          name: _currentMember!.name,
          email: _currentMember!.email,
          phoneNumber: _currentMember!.phoneNumber,
          referralCode: _currentMember!.referralCode,
          referredBy: _currentMember!.referredBy,
          joinDate: _currentMember!.joinDate,
          rank: _currentMember!.rank,
          level: _currentMember!.level,
          boardId: _currentMember!.boardId,
          boardPosition: _currentMember!.boardPosition,
          directReferrals: _currentMember!.directReferrals,
          points: _currentMember!.points,
          walletBalance: _currentMember!.walletBalance,
          earningWallet: _currentMember!.earningWallet,
          isActive: _currentMember!.isActive,
          isAdmin: _currentMember!.isAdmin,
          profilePicture: newAvatarUrl,
          boardJoinStatus: _currentMember!.boardJoinStatus,
          approvalDate: _currentMember!.approvalDate,
        );
        
        final members = StorageService.getMembers();
        final index = members.indexWhere((m) => m.id == _currentMember!.id);
        if (index != -1) {
          members[index] = updatedMember;
          await StorageService.saveMembers(members);
          await StorageService.saveCurrentMember(updatedMember);
          
          setState(() {
            _currentMember = updatedMember;
          });
        }
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _copyReferralCode() {
    if (_currentMember != null) {
      Clipboard.setData(ClipboardData(text: _currentMember!.referralCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral code copied to clipboard!')),
      );
    }
  }

  void _copyReferralLink() {
    if (_currentMember != null) {
      final referralLink = ReferralService.generateWebReferralLink(_currentMember!.referralCode);
      Clipboard.setData(ClipboardData(text: referralLink));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral link copied to clipboard!')),
      );
    }
  }

  void _shareReferralLink() {
    if (_currentMember != null) {
      ReferralService.shareReferralLink(_currentMember!);
    }
  }

  void _showCommunicationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TeamCommunicationScreen(currentMember: _currentMember),
    );
  }

  void _contactAdmin() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AdminContactScreen(currentMember: _currentMember),
    );
  }

  void _showSocialSharingDialog() {
    if (_currentMember == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share on Social Media'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message, color: Colors.green),
              title: const Text('WhatsApp'),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'whatsapp');
              },
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blue),
              title: const Text('Telegram'),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'telegram');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.purple),
              title: const Text('Instagram'),
              onTap: () {
                Navigator.pop(context);
                ReferralService.shareOnPlatform(_currentMember!, 'instagram');
              },
            ),
            ListTile(
              leading: const Icon(Icons.facebook, color: Colors.blue),
              title: const Text('Facebook'),
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showPasswordChangeDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PasswordChangeScreen(currentMember: _currentMember),
    );
  }

  void _showTeamPictureUpload() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TeamPictureUploadScreen(currentMember: _currentMember),
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
          if (!_isEditing) ...[
            IconButton(
              onPressed: () => _showCommunicationOptions(context),
              icon: const Icon(Icons.chat),
              tooltip: TranslationService.translate('team_chat'),
            ),
            IconButton(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit),
              tooltip: TranslationService.translate('edit_profile'),
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: TranslationService.translate('logout'),
            ),
          ] else ...[
            IconButton(
              onPressed: _cancelEdit,
              icon: const Icon(Icons.close),
              tooltip: TranslationService.translate('cancel'),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOldProfileInterface(dateFormatter),
            const SizedBox(height: 20),
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
            
            // Save Changes Button (only shown when editing)
            if (_isEditing) ...[
              const SizedBox(height: 20),
              _buildSaveChangesButton(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSaveChangesButton() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.save,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  TranslationService.translate('save_changes'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Text(
              TranslationService.translate('review_changes_instruction'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cancelEdit,
                    icon: const Icon(Icons.cancel),
                    label: Text(TranslationService.translate('cancel')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: Text(TranslationService.translate('save_changes').toUpperCase()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildOldProfileInterface(DateFormat dateFormatter) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  TranslationService.translate('old_profile_interface'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Basic Member Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationService.translate('member_information'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOldInfoRow(TranslationService.translate('full_name'), _currentMember!.name),
                  _buildOldInfoRow(TranslationService.translate('email_username'), _currentMember!.email),
                  _buildOldInfoRow(TranslationService.translate('phone_number'), _currentMember!.phoneNumber),
                  _buildOldInfoRow(TranslationService.translate('member_id'), _currentMember!.id.substring(0, 8).toUpperCase()),
                  _buildOldInfoRow(TranslationService.translate('join_date'), dateFormatter.format(_currentMember!.joinDate)),
                  _buildOldInfoRow(TranslationService.translate('level'), '${_currentMember!.level}/7'),
                  _buildOldInfoRow(TranslationService.translate('points'), '${_currentMember!.points}'),
                  _buildOldInfoRow(TranslationService.translate('account_status'), _currentMember!.isActive ? TranslationService.translate('active') : TranslationService.translate('inactive')),
                  _buildOldInfoRow(TranslationService.translate('current_board'), _currentMember!.boardId != null ? TranslationService.translate('assigned') : TranslationService.translate('not_assigned')),
                  if (_currentMember!.boardPosition >= 0)
                    _buildOldInfoRow(TranslationService.translate('board_position'), '${_currentMember!.boardPosition + 1}/14'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Referral Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    TranslationService.translate('referral_information'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${TranslationService.translate('referral_code')}: ${_currentMember!.referralCode}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        onPressed: _copyReferralCode,
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: TranslationService.translate('copy_code'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildOldInfoRow(TranslationService.translate('direct_referrals'), '${_currentMember!.directReferrals.length}'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Text(
              TranslationService.translate('quick_actions'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildOldActionChip(
                  icon: Icons.edit,
                  label: TranslationService.translate('edit_profile'),
                  onPressed: _toggleEdit,
                  color: Colors.blue,
                ),
                _buildOldActionChip(
                  icon: Icons.lock_reset,
                  label: TranslationService.translate('change_password'),
                  onPressed: _showPasswordChangeDialog,
                  color: Colors.green,
                ),
                _buildOldActionChip(
                  icon: Icons.chat,
                  label: TranslationService.translate('team_chat'),
                  onPressed: () => _showCommunicationOptions(context),
                  color: Colors.purple,
                ),
                _buildOldActionChip(
                  icon: Icons.admin_panel_settings,
                  label: TranslationService.translate('contact_admin'),
                  onPressed: _contactAdmin,
                  color: Colors.orange,
                ),
                _buildOldActionChip(
                  icon: Icons.logout,
                  label: TranslationService.translate('logout'),
                  onPressed: _logout,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOldInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOldActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
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
                  backgroundImage: _currentMember!.profilePicture != null
                      ? NetworkImage(_currentMember!.profilePicture!)
                      : null,
                  child: _currentMember!.profilePicture == null
                      ? Text(
                          _currentMember!.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : null,
                ),
                if (_isEditing)
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: GestureDetector(
                      onTap: _changeProfilePicture,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                if (!_isEditing)
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
            
            // Editable Name Field
            if (_isEditing)
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    hintText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.blue.shade600),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  textCapitalization: TextCapitalization.words,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                _currentMember!.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              
            const SizedBox(height: 8),
            
            Text(
              _currentMember!.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Editable Phone Field
            if (_isEditing)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '+1 234 567 8900',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.phone, color: Colors.green.shade600),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  keyboardType: TextInputType.phone,
                ),
              )
            else
              Text(
                _currentMember!.phoneNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getRankColor(_currentMember!.rank).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getRankColor(_currentMember!.rank)),
              ),
              child: Column(
                children: [
                  Text(
                    '${_currentMember!.rank.name.toUpperCase()} - Level ${_currentMember!.level}',
                    style: TextStyle(
                      color: _getRankColor(_currentMember!.rank),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '⭐' * _currentMember!.stars,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_currentMember!.stars}/7)',
                        style: TextStyle(
                          color: _getRankColor(_currentMember!.rank),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

  Widget _buildStatsGrid() {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildStatCard(
          'Wallet Balance',
          formatter.format(_currentMember!.walletBalance),
          Icons.account_balance_wallet,
          Colors.green,
        ),
        _buildStatCard(
          'Points',
          '${_currentMember!.points}',
          Icons.stars,
          Colors.amber,
        ),
        _buildStatCard(
          'Direct Referrals',
          '${_currentMember!.directReferrals.length}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Level Progress',
          '${_currentMember!.level}/7',
          Icons.trending_up,
          Colors.purple,
        ),
        _buildStatCard(
          'Stars Earned',
          '${'⭐' * (_currentMember!.stars)} (${_currentMember!.stars}/7)',
          Icons.star,
          Colors.amber,
        ),
        _buildStatCard(
          'Earning Wallet',
          formatter.format(_currentMember!.earningWallet),
          Icons.account_balance,
          Colors.green,
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
                  'Promotion Progress',
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
                      'Congratulations! You can be promoted!',
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
            Text('Referral Information', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Code: ${_currentMember!.referralCode}',
                      style: theme.textTheme.titleSmall),
                  const Spacer(),
                  IconButton(
                    onPressed: _copyReferralCode,
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy Code',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                    tooltip: 'Copy Link',
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
                    label: const Text('Share Link'),
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
                    label: const Text('Social'),
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
            leading: const Icon(Icons.chat_bubble, color: Colors.green),
            title: const Text('Team Communication'),
            subtitle: const Text('Chat with your team and upline'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCommunicationOptions(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.orange),
            title: const Text('Contact Administrator'),
            subtitle: const Text('Get support from GO-WIN team'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _contactAdmin(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.lock_reset, color: Theme.of(context).colorScheme.primary),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password securely'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPasswordChangeDialog(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.camera_alt, color: Colors.purple),
            title: const Text('Upload Team Picture'),
            subtitle: const Text('Share a picture with your team'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTeamPictureUpload(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.notifications, color: Theme.of(context).colorScheme.primary),
            title: const Text('Notifications'),
            subtitle: const Text('Manage your notification preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
            title: const Text('Help & Support'),
            subtitle: const Text('FAQ, contact support, documentation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feature coming soon!')),
              );
            },
          ),
        ],
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
                  'Membership Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Member ID', _currentMember!.id.substring(0, 8).toUpperCase()),
            _buildInfoRow('Join Date', dateFormatter.format(_currentMember!.joinDate)),
            _buildInfoRow('Account Status', _currentMember!.isActive ? 'Active' : 'Inactive'),
            _buildInfoRow('Current Board', _currentMember!.boardId != null ? 'Assigned' : 'Not Assigned'),
            if (_currentMember!.boardPosition >= 0)
              _buildInfoRow('Board Position', '${_currentMember!.boardPosition + 1}/14'),
          ],
        ),
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

// Team Communication Screen
class TeamCommunicationScreen extends StatefulWidget {
  final Member? currentMember;
  
  const TeamCommunicationScreen({super.key, this.currentMember});

  @override
  State<TeamCommunicationScreen> createState() => _TeamCommunicationScreenState();
}

class _TeamCommunicationScreenState extends State<TeamCommunicationScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Load sample messages
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: 'admin-jaytechpromo',
        senderName: 'Jay Tech Admin',
        message: 'Welcome to the GO-WIN International team chat! 🎉',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isAdmin: true,
      ),
      ChatMessage(
        id: '2',
        senderId: 'member_1234',
        senderName: 'Sarah Johnson',
        message: 'Great to be here! Looking forward to reaching new levels!',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isAdmin: false,
      ),
      ChatMessage(
        id: '3',
        senderId: 'admin-lubejy09',
        senderName: 'Lube Admin',
        message: 'Remember, teamwork makes the dream work! Keep supporting each other 💪',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isAdmin: true,
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || widget.currentMember == null) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.currentMember!.id,
      senderName: widget.currentMember!.name,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isAdmin: widget.currentMember!.isAdmin,
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.group_work, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Communication',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Connect with your GO-WIN team',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Messages
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isOwnMessage = message.senderId == widget.currentMember?.id;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: isOwnMessage 
                        ? MainAxisAlignment.end 
                        : MainAxisAlignment.start,
                    children: [
                      if (!isOwnMessage) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: message.isAdmin ? Colors.orange : Colors.blue,
                          child: Text(
                            message.senderName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isOwnMessage 
                              ? CrossAxisAlignment.end 
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isOwnMessage)
                              Text(
                                message.senderName + (message.isAdmin ? ' (Admin)' : ''),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: message.isAdmin ? Colors.orange : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isOwnMessage 
                                    ? Colors.blue.shade100 
                                    : message.isAdmin 
                                        ? Colors.orange.shade50
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: message.isAdmin 
                                    ? Border.all(color: Colors.orange.shade200)
                                    : null,
                              ),
                              child: Text(message.message),
                            ),
                            
                            Text(
                              DateFormat('HH:mm').format(message.timestamp),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (isOwnMessage) ...[
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Text(
                            message.senderName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Admin Contact Screen
class AdminContactScreen extends StatefulWidget {
  final Member? currentMember;
  
  const AdminContactScreen({super.key, this.currentMember});

  @override
  State<AdminContactScreen> createState() => _AdminContactScreenState();
}

class _AdminContactScreenState extends State<AdminContactScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'General Support';

  final List<String> _categories = [
    'General Support',
    'Account Issues',
    'Board Questions',
    'Payment Support',
    'Technical Issues',
    'Business Inquiry',
  ];

  void _sendMessage() {
    if (_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Simulate sending message to admin
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent to administrator! You will receive a response soon.'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.support_agent, color: Colors.orange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Administrator',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get help from GO-WIN International team',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subject
                  Text(
                    'Subject',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      hintText: 'Brief description of your issue',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.subject),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Message
                  Text(
                    'Message',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Describe your issue in detail...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 6,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Contact Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Administrator Contacts',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '📧 Email: support@gowin-international.com',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '📱 WhatsApp: +1 (555) 123-4567',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '⏰ Response time: 24-48 hours',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Send Button
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Send Message to Administrator',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Password Change Screen
class PasswordChangeScreen extends StatefulWidget {
  final Member? currentMember;
  
  const PasswordChangeScreen({super.key, this.currentMember});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _verificationSent = false;
  String _verificationMethod = 'email'; // 'email' or 'phone'
  String? _verificationCode;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _sendVerificationCode() async {
    if (widget.currentMember == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Generate a random verification code
      _verificationCode = (1000 + (9000 * (DateTime.now().millisecondsSinceEpoch % 9))).toString();
      
      // Simulate sending verification
      await Future.delayed(const Duration(seconds: 2));
      
      final contact = _verificationMethod == 'email' 
          ? widget.currentMember!.email 
          : widget.currentMember!.phoneNumber;
      
      setState(() {
        _verificationSent = true;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verification code sent to $contact\\n\\nDemo Code: $_verificationCode',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changePassword() async {
    if (widget.currentMember == null) return;

    // Validation
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_verificationCodeController.text != _verificationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate password change
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would validate current password and update in backend
      
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Password changed successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.security, color: Colors.blue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Secure your GO-WIN account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Password
                  Text(
                    'Current Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: !_isCurrentPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter current password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // New Password
                  Text(
                    'New Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_isNewPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter new password (min 6 characters)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password
                  Text(
                    'Confirm New Password',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_reset),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Verification Method Selection
                  Text(
                    'Verification Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Email'),
                          subtitle: Text(widget.currentMember?.email ?? ''),
                          value: 'email',
                          groupValue: _verificationMethod,
                          onChanged: (value) {
                            setState(() {
                              _verificationMethod = value!;
                              _verificationSent = false;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Phone'),
                          subtitle: Text(widget.currentMember?.phoneNumber ?? ''),
                          value: 'phone',
                          groupValue: _verificationMethod,
                          onChanged: (value) {
                            setState(() {
                              _verificationMethod = value!;
                              _verificationSent = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Send Verification Code Button
                  if (!_verificationSent) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _sendVerificationCode,
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(_isLoading ? 'Sending...' : 'Send Verification Code'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Verification Code Input
                    Text(
                      'Verification Code',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _verificationCodeController,
                      decoration: InputDecoration(
                        hintText: 'Enter 4-digit verification code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.verified_user),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _sendVerificationCode,
                          child: const Text('Resend Code'),
                        ),
                        Text(
                          'Code expires in 5 minutes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _changePassword,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.security),
                        label: Text(_isLoading ? 'Changing Password...' : 'Change Password'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // Security Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tips_and_updates, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Security Tips',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Use a strong password with at least 8 characters\\n'
                          '• Include uppercase, lowercase, numbers, and symbols\\n'
                          '• Do not reuse passwords from other accounts\\n'
                          '• Keep your password confidential',
                          style: TextStyle(color: Colors.orange.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Team Picture Upload Screen
class TeamPictureUploadScreen extends StatefulWidget {
  final Member? currentMember;
  
  const TeamPictureUploadScreen({super.key, this.currentMember});

  @override
  State<TeamPictureUploadScreen> createState() => _TeamPictureUploadScreenState();
}

class _TeamPictureUploadScreenState extends State<TeamPictureUploadScreen> {
  final _captionController = TextEditingController();
  String? _selectedImageUrl;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Generate a random image URL for demo purposes
      final imageUrl = 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
      
      setState(() {
        _selectedImageUrl = imageUrl;
      });
    }
  }

  void _uploadPicture() async {
    if (_selectedImageUrl == null || _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image and add a caption'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    
    try {
      // Simulate upload
      await Future.delayed(const Duration(seconds: 2));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Picture shared with your team successfully!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.camera_alt, color: Colors.purple, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Share with Team',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Upload a picture to share with your team',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Selection
                  Text(
                    'Select Picture',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: _selectedImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _selectedImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to select picture',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Caption
                  Text(
                    'Caption',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: 'Add a caption for your team picture...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                    ),
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Sharing Guidelines',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Share positive team moments and achievements\n'
                          '• Keep content professional and appropriate\n'
                          '• Pictures will be visible to your direct team members\n'
                          '• Help motivate and inspire your team',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Upload Button
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadPicture,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Share Picture with Team'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isAdmin;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isAdmin,
  });
}
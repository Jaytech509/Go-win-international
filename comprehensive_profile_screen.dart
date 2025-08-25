import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/services/referral_service.dart';
import 'package:ascendant_reach/services/translation_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/widgets/common_app_bar.dart';

class ComprehensiveProfileScreen extends StatefulWidget {
  const ComprehensiveProfileScreen({super.key});

  @override
  State<ComprehensiveProfileScreen> createState() => _ComprehensiveProfileScreenState();
}

class _ComprehensiveProfileScreenState extends State<ComprehensiveProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Member? _currentMember;
  bool _isEditing = false;
  
  // Edit controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Password change controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadProfile();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'profile'),
      body: _currentMember == null 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildProfileHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPersonalInfoTab(),
                    _buildTasksProgressTab(),
                    _buildEarningsTab(),
                    _buildSecurityTab(),
                    _buildCommunicationTab(),
                  ],
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: _currentMember?.profilePicture != null
              ? ClipOval(child: Image.network(_currentMember!.profilePicture!, width: 80, height: 80, fit: BoxFit.cover))
              : Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentMember?.name ?? TranslationService.translate('unknown'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${TranslationService.translate('level')} ${_currentMember?.level ?? 0}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentMember?.points ?? 0} ${TranslationService.translate('points')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: _isEditing ? _saveChanges : _toggleEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey[100],
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: [
          Tab(
            icon: const Icon(Icons.person),
            text: TranslationService.translate('personal_info'),
          ),
          Tab(
            icon: const Icon(Icons.task_alt),
            text: TranslationService.translate('tasks'),
          ),
          Tab(
            icon: const Icon(Icons.monetization_on),
            text: TranslationService.translate('earnings'),
          ),
          Tab(
            icon: const Icon(Icons.security),
            text: TranslationService.translate('security'),
          ),
          Tab(
            icon: const Icon(Icons.chat),
            text: TranslationService.translate('communication'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            TranslationService.translate('basic_information'),
            [
              _buildEditableField(
                TranslationService.translate('full_name'),
                _nameController,
                Icons.person,
                enabled: _isEditing,
              ),
              _buildEditableField(
                TranslationService.translate('email'),
                TextEditingController(text: _currentMember?.email ?? ''),
                Icons.email,
                enabled: false,
              ),
              _buildEditableField(
                TranslationService.translate('phone'),
                _phoneController,
                Icons.phone,
                enabled: _isEditing,
              ),
              _buildEditableField(
                TranslationService.translate('referral_code'),
                TextEditingController(text: _currentMember?.referralCode ?? ''),
                Icons.qr_code,
                enabled: false,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _currentMember?.referralCode ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(TranslationService.translate('referral_code_copied'))),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('membership_details'),
            [
              _buildInfoTile(TranslationService.translate('member_since'), 
                DateFormat.yMMMd().format(_currentMember?.joinDate ?? DateTime.now())),
              _buildInfoTile(TranslationService.translate('current_level'), '${_currentMember?.level ?? 0}'),
              _buildInfoTile(TranslationService.translate('current_rank'), _currentMember?.rank.name ?? 'Starter'),
              _buildInfoTile(TranslationService.translate('board_position'), '${_currentMember?.boardPosition ?? 0}'),
              _buildInfoTile(TranslationService.translate('direct_referrals'), '${_currentMember?.directReferrals.length ?? 0}'),
              _buildInfoTile(TranslationService.translate('total_points'), '${_currentMember?.points ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTasksProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            TranslationService.translate('current_tasks'),
            [
              _buildTaskItem(
                TranslationService.translate('recruit_referrals'),
                'Recruit 2 direct referrals',
                _currentMember?.directReferrals.length ?? 0,
                2,
                Colors.blue,
              ),
              _buildTaskItem(
                TranslationService.translate('earn_points'),
                'Earn 100 points from activities',
                _currentMember?.points ?? 0,
                100,
                Colors.green,
              ),
              _buildTaskItem(
                TranslationService.translate('complete_board'),
                'Fill board positions',
                _getCurrentBoardProgress(),
                14,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('level_progression'),
            [
              _buildLevelProgress(),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('next_level_requirements'),
            [
              _buildRequirementItem(
                TranslationService.translate('direct_referrals_needed'),
                '${_getRequiredReferrals()} direct referrals',
                (_currentMember?.directReferrals.length ?? 0) >= _getRequiredReferrals(),
              ),
              _buildRequirementItem(
                TranslationService.translate('points_needed'),
                '${_getRequiredPoints()} total points',
                (_currentMember?.points ?? 0) >= _getRequiredPoints(),
              ),
              _buildRequirementItem(
                TranslationService.translate('board_completion'),
                'Complete current board',
                _getCurrentBoardProgress() >= 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    final directReferralEarnings = (_currentMember?.directReferrals.length ?? 0) * 5.0; // $5 per direct referral
    final levelBonuses = (_currentMember?.level ?? 0) * 20.0; // $20 per level
    final totalEarnings = _currentMember?.earningWallet ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            TranslationService.translate('earning_summary'),
            [
              _buildEarningsTile(
                TranslationService.translate('total_earnings'),
                '\$${totalEarnings.toStringAsFixed(2)}',
                Colors.green,
                Icons.account_balance_wallet,
              ),
              _buildEarningsTile(
                TranslationService.translate('main_wallet'),
                '\$${_currentMember?.walletBalance?.toStringAsFixed(2) ?? '0.00'}',
                Colors.blue,
                Icons.wallet,
              ),
              _buildEarningsTile(
                TranslationService.translate('earning_wallet'),
                '\$${_currentMember?.earningWallet?.toStringAsFixed(2) ?? '0.00'}',
                Colors.orange,
                Icons.savings,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('earning_breakdown'),
            [
              _buildEarningsBreakdown(
                TranslationService.translate('direct_referral_bonuses'),
                '\$${directReferralEarnings.toStringAsFixed(2)}',
                '${_currentMember?.directReferrals.length ?? 0} × \$5.00',
              ),
              _buildEarningsBreakdown(
                TranslationService.translate('level_upgrade_bonuses'),
                '\$${levelBonuses.toStringAsFixed(2)}',
                '${_currentMember?.level ?? 0} × \$20.00',
              ),
              _buildEarningsBreakdown(
                TranslationService.translate('board_completion_bonuses'),
                '\$0.00',
                'No completed boards yet',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('earning_opportunities'),
            [
              _buildOpportunityItem(
                TranslationService.translate('refer_friends'),
                'Earn \$5 for each direct referral',
                Icons.people,
                Colors.blue,
              ),
              _buildOpportunityItem(
                TranslationService.translate('complete_levels'),
                'Earn \$20 bonus for each level upgrade',
                Icons.trending_up,
                Colors.green,
              ),
              _buildOpportunityItem(
                TranslationService.translate('board_recycling'),
                'Earn board completion bonuses',
                Icons.refresh,
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            TranslationService.translate('change_password'),
            [
              _buildPasswordField(
                TranslationService.translate('current_password'),
                _currentPasswordController,
                _showCurrentPassword,
                () => setState(() => _showCurrentPassword = !_showCurrentPassword),
              ),
              _buildPasswordField(
                TranslationService.translate('new_password'),
                _newPasswordController,
                _showNewPassword,
                () => setState(() => _showNewPassword = !_showNewPassword),
              ),
              _buildPasswordField(
                TranslationService.translate('confirm_new_password'),
                _confirmPasswordController,
                _showConfirmPassword,
                () => setState(() => _showConfirmPassword = !_showConfirmPassword),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(TranslationService.translate('change_password')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('security_information'),
            [
              _buildInfoTile(TranslationService.translate('last_login'), 'Today at 10:30 AM'),
              _buildInfoTile(TranslationService.translate('account_status'), 
                _currentMember?.isActive == true ? 'Active' : 'Inactive'),
              _buildInfoTile(TranslationService.translate('two_factor_auth'), 'Disabled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            TranslationService.translate('team_communication'),
            [
              _buildCommunicationOption(
                TranslationService.translate('team_chat'),
                TranslationService.translate('chat_with_your_team'),
                Icons.chat_bubble,
                Colors.blue,
                () => _openTeamChat(),
              ),
              _buildCommunicationOption(
                TranslationService.translate('post_update'),
                TranslationService.translate('share_update_with_team'),
                Icons.post_add,
                Colors.green,
                () => _createPost(),
              ),
              _buildCommunicationOption(
                TranslationService.translate('team_announcements'),
                TranslationService.translate('view_team_announcements'),
                Icons.announcement,
                Colors.orange,
                () => _viewAnnouncements(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            TranslationService.translate('support'),
            [
              _buildCommunicationOption(
                TranslationService.translate('contact_admin'),
                TranslationService.translate('send_message_to_admin'),
                Icons.support_agent,
                Colors.purple,
                () => _contactAdmin(),
              ),
              _buildCommunicationOption(
                TranslationService.translate('help_center'),
                TranslationService.translate('view_help_documentation'),
                Icons.help_center,
                Colors.teal,
                () => _openHelpCenter(),
              ),
              _buildCommunicationOption(
                TranslationService.translate('report_issue'),
                TranslationService.translate('report_technical_issue'),
                Icons.report_problem,
                Colors.red,
                () => _reportIssue(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for building UI components
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTaskItem(String title, String description, int current, int target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$current/$target', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    final currentLevel = _currentMember?.level ?? 0;
    final maxLevel = 7;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${TranslationService.translate('current_level')}: $currentLevel'),
            Text('${TranslationService.translate('max_level')}: $maxLevel'),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: currentLevel / maxLevel,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLevel, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                Icons.star,
                color: index < currentLevel ? Colors.amber : Colors.grey[300],
                size: 20,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String title, String description, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTile(String title, String amount, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(String title, String amount, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool show, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: !show,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCommunicationOption(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  // Action methods
  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }
  
  void _saveChanges() async {
    if (_currentMember == null) return;
    
    try {
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
        walletCommissionProducts: _currentMember!.walletCommissionProducts,
        investmentWallet: _currentMember!.investmentWallet,
        hasProductSharingSubscription: _currentMember!.hasProductSharingSubscription,
        subscriptionExpiryDate: _currentMember!.subscriptionExpiryDate,
        stars: _currentMember!.stars,
        hasNextLevelPayment: _currentMember!.hasNextLevelPayment,
        activeInvestments: _currentMember!.activeInvestments,
        depositAmount: _currentMember!.depositAmount,
        hasMinimumDeposit: _currentMember!.hasMinimumDeposit,
        paymentProof: _currentMember!.paymentProof,
      );
      
      await StorageService.saveCurrentMember(updatedMember);
      _currentMember = updatedMember;
      
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('profile_updated_successfully')),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('failed_to_update_profile')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('please_fill_all_fields')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('passwords_do_not_match')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('password_too_short')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Here you would typically verify the current password and update it
    // For now, we'll just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(TranslationService.translate('password_changed_successfully')),
        backgroundColor: Colors.green,
      ),
    );

    // Clear password fields
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _openTeamChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening team chat...')),
    );
  }

  void _createPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening post creator...')),
    );
  }

  void _viewAnnouncements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening announcements...')),
    );
  }

  void _contactAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening admin contact form...')),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening help center...')),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening issue report form...')),
    );
  }

  // Helper methods
  int _getCurrentBoardProgress() {
    // This would typically check the actual board progress
    // For now, return a mock value based on level
    return (_currentMember?.level ?? 0) * 2;
  }

  int _getRequiredReferrals() {
    final currentLevel = _currentMember?.level ?? 0;
    return (currentLevel + 1) * 2; // Each level requires 2 more referrals
  }

  int _getRequiredPoints() {
    final currentLevel = _currentMember?.level ?? 0;
    return (currentLevel + 1) * 50; // Each level requires 50 more points
  }
}
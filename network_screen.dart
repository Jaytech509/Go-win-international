import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/models/member.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  Member? _currentMember;
  List<Member> _networkMembers = [];

  @override
  void initState() {
    super.initState();
    _loadNetworkData();
  }

  void _loadNetworkData() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
      if (_currentMember != null) {
        _networkMembers = MLMService.getNetworkMembers(_currentMember!.id);
      }
    });
  }

  void _copyReferralCode() {
    if (_currentMember != null) {
      Clipboard.setData(ClipboardData(text: _currentMember!.referralCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Referral code copied to clipboard!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMember == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Network'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _buildReferralCard(),
          _buildNetworkStats(),
          Expanded(child: _buildNetworkList()),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Your Referral Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _currentMember!.referralCode,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _copyReferralCode,
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Copy code',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Share this code with others to grow your network',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStats() {
    final directReferrals = _networkMembers.where((m) => m.referredBy == _currentMember!.id).length;
    final indirectReferrals = _networkMembers.length - directReferrals;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Direct',
              directReferrals.toString(),
              Icons.people,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Indirect',
              indirectReferrals.toString(),
              Icons.groups,
              Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'Total',
              _networkMembers.length.toString(),
              Icons.account_tree,
              Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkList() {
    if (_networkMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Network Members Yet',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Share your referral code to start building your network!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // Group members by relationship
    final directMembers = _networkMembers.where((m) => m.referredBy == _currentMember!.id).toList();
    final indirectMembers = _networkMembers.where((m) => m.referredBy != _currentMember!.id).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (directMembers.isNotEmpty) ...[
          Text(
            'Direct Referrals',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...directMembers.map((member) => _buildMemberCard(member, true)),
          const SizedBox(height: 16),
        ],
        if (indirectMembers.isNotEmpty) ...[
          Text(
            'Indirect Network',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...indirectMembers.map((member) => _buildMemberCard(member, false)),
        ],
      ],
    );
  }

  Widget _buildMemberCard(Member member, bool isDirect) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDirect 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          child: Text(
            member.name[0].toUpperCase(),
            style: TextStyle(
              color: isDirect 
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${member.rank.name.toUpperCase()} - Level ${member.level}'),
            Text(
              'Joined: ${member.joinDate.day}/${member.joinDate.month}/${member.joinDate.year}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDirect ? Icons.person : Icons.people,
              color: isDirect 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondary,
            ),
            Text(
              isDirect ? 'Direct' : 'Indirect',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
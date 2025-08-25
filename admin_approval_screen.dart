import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/services/notification_service.dart';
import 'package:ascendant_reach/services/translation_service.dart';
import 'package:ascendant_reach/models/board_join_request.dart';
import 'package:ascendant_reach/models/withdrawal_request.dart';
import 'package:ascendant_reach/models/pending_transaction.dart';
import 'package:ascendant_reach/models/transaction.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/models/notification.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BoardJoinRequest> _pendingRequests = [];
  List<BoardJoinRequest> _allRequests = [];
  List<WithdrawalRequest> _pendingWithdrawals = [];
  List<WithdrawalRequest> _allWithdrawals = [];
  List<PendingTransaction> _pendingTransactions = [];
  List<PendingTransaction> _allPendingTransactions = [];
  List<Member> _allMembers = [];
  List<Map<String, dynamic>> _progressReports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this); // Added 2 more tabs
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRequests() {
    setState(() {
      _pendingRequests = MLMService.getPendingJoinRequests();
      _allRequests = MLMService.getJoinRequestHistory();
      _pendingWithdrawals = MLMService.getPendingWithdrawalRequests();
      _allWithdrawals = MLMService.getWithdrawalRequestHistory();
      _pendingTransactions = StorageService.getPendingTransactions()
          .where((t) => t.status == ApprovalStatus.pending)
          .toList();
      _allPendingTransactions = StorageService.getPendingTransactions();
      _allMembers = MLMService.getAllMembers();
      _progressReports = StorageService.getProgressReports() ?? [];
    });
  }

  Future<void> _approveRequest(BoardJoinRequest request) async {
    setState(() => _isLoading = true);
    try {
      await MLMService.approveJoinRequest(request.id, 'admin');
      
      // Send notification to approved member
      await _sendApprovalNotification(request, true);
      
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Approved ${request.memberName}\'s request and sent notification!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRequest(BoardJoinRequest request) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    setState(() => _isLoading = true);
    try {
      await MLMService.rejectJoinRequest(request.id, 'admin', reason);
      
      // Send notification to rejected member
      await _sendApprovalNotification(request, false, reason);
      
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rejected ${request.memberName}\'s request and sent notification.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approveWithdrawal(WithdrawalRequest request) async {
    setState(() => _isLoading = true);
    try {
      await MLMService.approveWithdrawalRequest(request.id, 'admin');
      
      // Send notification to approved member
      await _sendWithdrawalNotification(request, true);
      
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Approved ${request.memberName}\'s withdrawal and sent notification!',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving withdrawal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectWithdrawal(WithdrawalRequest request) async {
    final reason = await _showRejectDialog();
    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await MLMService.rejectWithdrawalRequest(request.id, 'admin', reason);
      
      // Send notification to rejected member
      await _sendWithdrawalNotification(request, false, reason);
      
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rejected ${request.memberName}\'s withdrawal and sent notification.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting withdrawal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendApprovalNotification(BoardJoinRequest request, bool isApproved, [String? reason]) async {
    try {
      // Simulate sending notification (in a real app, this would be done via backend)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final message = isApproved
          ? '🎉 Congratulations! Your board join request for Level ${request.requestedLevel} has been APPROVED! You can now access your board and start earning. Welcome to GO-WIN International!'
          : '❌ Your board join request for Level ${request.requestedLevel} has been rejected. Reason: ${reason ?? 'Not specified'}. Please contact support for more information.';
      
      // In a real app, you would:
      // 1. Send push notification
      // 2. Send email notification
      // 3. Send SMS notification
      // 4. Store notification in database
      
      print('📧 Notification sent to ${request.memberEmail}: $message');
      print('📱 SMS sent to ${request.memberPhone}: $message');
      
    } catch (e) {
      print('❌ Failed to send notification: $e');
    }
  }

  Future<void> _sendWithdrawalNotification(WithdrawalRequest request, bool isApproved, [String? reason]) async {
    try {
      // Simulate sending notification (in a real app, this would be done via backend)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final message = isApproved
          ? '💰 Great news! Your withdrawal request of \$${request.amount.toStringAsFixed(2)} has been APPROVED and processed. The funds should appear in your ${request.paymentMethod} account within 1-3 business days.'
          : '❌ Your withdrawal request of \$${request.amount.toStringAsFixed(2)} has been rejected. Reason: ${reason ?? 'Not specified'}. Please contact support for assistance.';
      
      // In a real app, you would:
      // 1. Send push notification
      // 2. Send email notification
      // 3. Send SMS notification
      // 4. Store notification in database
      
      print('📧 Notification sent to ${request.memberEmail}: $message');
      print('📱 SMS sent to ${request.memberPhone}: $message');
      
    } catch (e) {
      print('❌ Failed to send notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TranslationService.translate('admin_panel')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.pending_actions),
              text: '${TranslationService.translate('deposits')} (${_pendingRequests.length})',
            ),
            Tab(
              icon: const Icon(Icons.history),
              text: TranslationService.translate('deposit_history'),
            ),
            Tab(
              icon: const Icon(Icons.account_balance_wallet),
              text: '${TranslationService.translate('withdrawals')} (${_pendingWithdrawals.length})',
            ),
            Tab(
              icon: const Icon(Icons.receipt_long),
              text: TranslationService.translate('withdrawal_history'),
            ),
            Tab(
              icon: const Icon(Icons.swap_horiz),
              text: '${TranslationService.translate('transfers')} (${_pendingTransactions.where((t) => t.type == PendingTransactionType.transfer).length})',
            ),
            Tab(
              icon: const Icon(Icons.all_inbox),
              text: TranslationService.translate('all_pending'),
            ),
            Tab(
              icon: const Icon(Icons.people),
              text: '${TranslationService.translate('all_users')} (${_allMembers.length})',
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: '${TranslationService.translate('reports')} (${_progressReports.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildHistoryTab(),
          _buildPendingWithdrawalsTab(),
          _buildWithdrawalHistoryTab(),
          _buildPendingTransfersTab(),
          _buildAllPendingTab(),
          _buildAllUsersTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Requests',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'All payments have been reviewed!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        request.memberName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.memberName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            request.memberEmail,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Level ${request.requestedLevel}',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Deposit Amount',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            '\$${request.paymentAmount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Payment Method', style: Theme.of(context).textTheme.bodyMedium),
                          Text(request.paymentMethod, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Submitted', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            request.requestDate.toString().split(' ')[0],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (request.paymentProof != null) ...[
                        const SizedBox(height: 8),
                        Text('Payment Proof:', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.paymentProof!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _rejectRequest(request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _approveRequest(request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_allRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Requests Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Payment requests will appear here once submitted.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allRequests.length,
      itemBuilder: (context, index) {
        final request = _allRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        request.memberName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.memberName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${request.paymentAmount.toStringAsFixed(2)} - Level ${request.requestedLevel}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(request.status),
                        style: TextStyle(
                          color: _getStatusColor(request.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submitted: ${request.requestDate.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (request.approvalDate != null)
                      Text(
                        'Processed: ${request.approvalDate.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                if (request.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejection Reason:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.rejectionReason!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return Colors.orange;
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return 'Pending';
      case ApprovalStatus.approved:
        return 'Approved';
      case ApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  Widget _buildPendingWithdrawalsTab() {
    if (_pendingWithdrawals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No pending withdrawal requests',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All withdrawal requests have been processed',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingWithdrawals.length,
      itemBuilder: (context, index) {
        final request = _pendingWithdrawals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        request.memberName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.memberName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Withdraw \$${request.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            request.memberEmail,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Payment Method', request.paymentMethod),
                      _buildDetailRow('Account ID', request.accountId),
                      _buildDetailRow('Account Name', request.accountName),
                      _buildDetailRow('Request Date', request.requestDate.toString().split(' ')[0]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _approveWithdrawal(request),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _rejectWithdrawal(request),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithdrawalHistoryTab() {
    if (_allWithdrawals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No withdrawal history',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allWithdrawals.length,
      itemBuilder: (context, index) {
        final request = _allWithdrawals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        request.memberName[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.memberName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${request.amount.toStringAsFixed(2)} - ${request.paymentMethod}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(request.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(request.status),
                        style: TextStyle(
                          color: _getStatusColor(request.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Submitted: ${request.requestDate.toString().split(' ')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (request.approvalDate != null)
                      Text(
                        'Processed: ${request.approvalDate.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                if (request.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejection Reason:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.rejectionReason!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingTransfersTab() {
    final pendingTransfers = _pendingTransactions
        .where((t) => t.type == PendingTransactionType.transfer)
        .toList();
    
    if (pendingTransfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.swap_horiz,
              size: 80,
              color: Colors.blue.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Transfers',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'All transfers have been processed!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingTransfers.length,
      itemBuilder: (context, index) {
        final transaction = pendingTransfers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.swap_horiz, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.memberName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Transfer \$${transaction.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            transaction.memberEmail,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('To Email', transaction.metadata?['toEmail'] ?? 'Unknown'),
                      _buildDetailRow('Note', transaction.metadata?['note'] ?? 'No note'),
                      _buildDetailRow('Request Date', transaction.createdAt.toString().split(' ')[0]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _approvePendingTransaction(transaction),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : () => _rejectPendingTransaction(transaction),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllPendingTab() {
    final allPending = [
      ..._pendingRequests.map((r) => {
        'type': 'deposit',
        'data': r,
        'amount': r.paymentAmount,
        'member': r.memberName,
        'date': r.requestDate,
      }),
      ..._pendingWithdrawals.map((w) => {
        'type': 'withdrawal',
        'data': w,
        'amount': w.amount,
        'member': w.memberName,
        'date': w.requestDate,
      }),
      ..._pendingTransactions.map((t) => {
        'type': 'transaction',
        'data': t,
        'amount': t.amount,
        'member': t.memberName,
        'date': t.createdAt,
      }),
    ];
    
    // Sort by date (newest first)
    allPending.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    
    if (allPending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Requests',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'All transactions have been processed!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allPending.length,
      itemBuilder: (context, index) {
        final item = allPending[index];
        final type = item['type'] as String;
        final amount = item['amount'] as double;
        final member = item['member'] as String;
        final date = item['date'] as DateTime;
        
        IconData icon;
        Color color;
        String title;
        
        switch (type) {
          case 'deposit':
            icon = Icons.add_circle;
            color = Colors.green;
            title = 'Deposit Request';
            break;
          case 'withdrawal':
            icon = Icons.remove_circle;
            color = Colors.red;
            title = 'Withdrawal Request';
            break;
          case 'transaction':
            icon = Icons.swap_horiz;
            color = Colors.blue;
            title = 'Transfer Request';
            break;
          default:
            icon = Icons.help;
            color = Colors.grey;
            title = 'Unknown Request';
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            title: Text(title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$member - \$${amount.toStringAsFixed(2)}'),
                Text(
                  'Submitted: ${date.toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {
              // Navigate to the appropriate tab
              switch (type) {
                case 'deposit':
                  _tabController.animateTo(0);
                  break;
                case 'withdrawal':
                  _tabController.animateTo(2);
                  break;
                case 'transaction':
                  _tabController.animateTo(4);
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _approvePendingTransaction(PendingTransaction transaction) async {
    setState(() => _isLoading = true);
    try {
      // Process the transaction based on type
      final members = StorageService.getMembers();
      final memberIndex = members.indexWhere((m) => m.id == transaction.memberId);
      
      if (memberIndex != -1) {
        final member = members[memberIndex];
        
        switch (transaction.type) {
          case PendingTransactionType.deposit:
            // Add to wallet balance
            members[memberIndex] = member.copyWith(
              walletBalance: member.walletBalance + transaction.amount,
            );
            break;
            
          case PendingTransactionType.transfer:
            // Handle transfer logic
            final toEmail = transaction.metadata?['toEmail'] as String;
            final toMemberIndex = members.indexWhere((m) => m.email.toLowerCase() == toEmail.toLowerCase());
            
            if (toMemberIndex != -1) {
              // Deduct from sender
              members[memberIndex] = member.copyWith(
                walletBalance: member.walletBalance - transaction.amount,
              );
              
              // Add to receiver
              final toMember = members[toMemberIndex];
              members[toMemberIndex] = toMember.copyWith(
                walletBalance: toMember.walletBalance + transaction.amount,
              );
            }
            break;
            
          case PendingTransactionType.withdrawal:
            // Already handled by withdrawal request system
            break;
            
          case PendingTransactionType.investment:
            // Add to investment wallet and create investment record
            final now = DateTime.now();
            final currentInvestments = List<Map<String, dynamic>>.from(member.activeInvestments);
            
            currentInvestments.add({
              'amount': transaction.amount,
              'startDate': now.toIso8601String(),
              'lastReturnDate': now.toIso8601String(),
              'totalReturned': 0.0,
            });
            
            members[memberIndex] = member.copyWith(
              activeInvestments: currentInvestments,
            );
            break;
        }
        
        await StorageService.saveMembers(members);
        
        // Create completed transaction
        final transactions = StorageService.getTransactions();
        transactions.add(Transaction(
          id: transaction.id,
          memberId: transaction.memberId,
          type: _mapPendingTypeToTransactionType(transaction.type),
          amount: transaction.amount,
          currency: transaction.currency,
          paymentMethod: transaction.paymentMethod,
          status: TransactionStatus.completed,
          description: '${transaction.description} - Approved',
          createdAt: transaction.createdAt,
          completedAt: DateTime.now(),
          metadata: transaction.metadata,
        ));
        await StorageService.saveTransactions(transactions);
        
        // Remove from pending
        final pendingTransactions = StorageService.getPendingTransactions();
        pendingTransactions.removeWhere((t) => t.id == transaction.id);
        await StorageService.savePendingTransactions(pendingTransactions);
      }
      
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Approved ${transaction.memberName}\'s ${transaction.type.name} request!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectPendingTransaction(PendingTransaction transaction) async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    setState(() => _isLoading = true);
    try {
      // Update transaction status
      final pendingTransactions = StorageService.getPendingTransactions();
      final transactionIndex = pendingTransactions.indexWhere((t) => t.id == transaction.id);
      
      if (transactionIndex != -1) {
        pendingTransactions[transactionIndex] = transaction.copyWith(
          status: ApprovalStatus.rejected,
          approvalDate: DateTime.now(),
          rejectionReason: reason,
        );
        
        await StorageService.savePendingTransactions(pendingTransactions);
      }
      
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rejected ${transaction.memberName}\'s ${transaction.type.name} request.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting transaction: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  TransactionType _mapPendingTypeToTransactionType(PendingTransactionType type) {
    switch (type) {
      case PendingTransactionType.deposit:
        return TransactionType.deposit;
      case PendingTransactionType.transfer:
        return TransactionType.transfer;
      case PendingTransactionType.withdrawal:
        return TransactionType.withdrawal;
      case PendingTransactionType.investment:
        return TransactionType.investment;
    }
  }

  // Build All Users Tab
  Widget _buildAllUsersTab() {
    if (_allMembers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationService.translate('no_users_found'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allMembers.length,
      itemBuilder: (context, index) {
        final member = _allMembers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: member.isAdmin ? Colors.red : Theme.of(context).colorScheme.primary,
              child: member.profilePicture != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        member.profilePicture!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          member.name[0].toUpperCase(),
                          style: TextStyle(
                            color: member.isAdmin ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      member.name[0].toUpperCase(),
                      style: TextStyle(
                        color: member.isAdmin ? Colors.white : Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    member.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (member.isAdmin) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.email,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${TranslationService.translate('level')} ${member.level}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getRankDisplayName(member.rank),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRankColor(member.rank),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${TranslationService.translate('balance')}: \$${member.walletBalance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleUserAction(member, value),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 18),
                      const SizedBox(width: 8),
                      Text(TranslationService.translate('view_profile')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'view_earnings',
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, size: 18),
                      const SizedBox(width: 8),
                      Text(TranslationService.translate('view_earnings')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit_info',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text(TranslationService.translate('edit_info')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      Icon(
                        member.isActive ? Icons.block : Icons.check_circle,
                        size: 18,
                        color: member.isActive ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        member.isActive
                            ? TranslationService.translate('deactivate')
                            : TranslationService.translate('activate'),
                        style: TextStyle(
                          color: member.isActive ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _showUserProfileDialog(member),
          ),
        );
      },
    );
  }

  // Build Reports Tab
  Widget _buildReportsTab() {
    if (_progressReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              TranslationService.translate('no_reports_available'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _progressReports.length,
      itemBuilder: (context, index) {
        final report = _progressReports[index];
        final timestamp = DateTime.parse(report['timestamp']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getActionIcon(report['action']),
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        report['action'] ?? 'Unknown Action',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _formatTimestamp(timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${TranslationService.translate('user')}: ${report['memberName'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${TranslationService.translate('email')}: ${report['memberEmail'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (report['data'] != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Details: ${report['data'].toString()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper methods for user management
  String _getRankDisplayName(MemberRank rank) {
    switch (rank) {
      case MemberRank.starter:
        return TranslationService.translate('starter');
      case MemberRank.bronze:
        return TranslationService.translate('bronze');
      case MemberRank.silver:
        return TranslationService.translate('silver');
      case MemberRank.legend:
        return TranslationService.translate('legend');
    }
  }

  Color _getRankColor(MemberRank rank) {
    switch (rank) {
      case MemberRank.starter:
        return Colors.grey;
      case MemberRank.bronze:
        return const Color(0xFFCD7F32);
      case MemberRank.silver:
        return const Color(0xFFC0C0C0);
      case MemberRank.legend:
        return const Color(0xFFFFD700);
    }
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'board join approved':
        return Icons.approval;
      case 'level upgrade':
        return Icons.upgrade;
      case 'withdrawal approved':
        return Icons.account_balance_wallet;
      case 'profile updated by admin':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handleUserAction(Member member, String action) async {
    switch (action) {
      case 'view_profile':
        _showUserProfileDialog(member);
        break;
      case 'view_earnings':
        _showUserEarningsDialog(member);
        break;
      case 'edit_info':
        _showEditUserDialog(member);
        break;
      case 'toggle_status':
        await _toggleUserStatus(member);
        break;
    }
  }

  Future<void> _showUserProfileDialog(Member member) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: member.profilePicture != null
                  ? NetworkImage(member.profilePicture!)
                  : null,
              child: member.profilePicture == null
                  ? Text(member.name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name),
                  Text(
                    member.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProfileDetailRow('Phone', member.phoneNumber),
              _buildProfileDetailRow('Referral Code', member.referralCode),
              _buildProfileDetailRow('Level', member.level.toString()),
              _buildProfileDetailRow('Rank', _getRankDisplayName(member.rank)),
              _buildProfileDetailRow('Balance', '\$${member.walletBalance.toStringAsFixed(2)}'),
              _buildProfileDetailRow('Earning Wallet', '\$${member.earningWallet.toStringAsFixed(2)}'),
              _buildProfileDetailRow('Points', member.points.toString()),
              _buildProfileDetailRow('Stars', '${member.stars} ⭐'),
              _buildProfileDetailRow('Status', member.isActive ? 'Active' : 'Inactive'),
              _buildProfileDetailRow('Admin', member.isAdmin ? 'Yes' : 'No'),
              _buildProfileDetailRow('Join Date', member.joinDate.toString().split(' ')[0]),
              _buildProfileDetailRow('Direct Referrals', member.directReferrals.length.toString()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(TranslationService.translate('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showEditUserDialog(member);
            },
            child: Text(TranslationService.translate('edit')),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserEarningsDialog(Member member) async {
    final earningsReport = MLMService.getMemberEarningReport(member.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${member.name} - ${TranslationService.translate('earnings_report')}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEarningsRow('Total Earnings', '\$${earningsReport['totalEarnings']?.toStringAsFixed(2) ?? '0.00'}', Colors.green),
              _buildEarningsRow('Commissions', '\$${earningsReport['commissions']?.toStringAsFixed(2) ?? '0.00'}', Colors.blue),
              _buildEarningsRow('Referral Profits', '\$${earningsReport['referralProfits']?.toStringAsFixed(2) ?? '0.00'}', Colors.orange),
              _buildEarningsRow('Total Deposits', '\$${earningsReport['deposits']?.toStringAsFixed(2) ?? '0.00'}', Colors.purple),
              _buildEarningsRow('Total Withdrawals', '\$${earningsReport['withdrawals']?.toStringAsFixed(2) ?? '0.00'}', Colors.red),
              const Divider(),
              _buildEarningsRow('Net Profit', '\$${earningsReport['netProfit']?.toStringAsFixed(2) ?? '0.00'}', Colors.green, isTotal: true),
              const SizedBox(height: 8),
              Text('Total Transactions: ${earningsReport['transactionCount'] ?? 0}'),
              if (earningsReport['lastTransaction'] != null)
                Text('Last Transaction: ${earningsReport['lastTransaction'].toString().split(' ')[0]}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(TranslationService.translate('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsRow(String label, String value, Color color, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: isTotal ? 16 : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditUserDialog(Member member) async {
    final nameController = TextEditingController(text: member.name);
    final emailController = TextEditingController(text: member.email);
    final phoneController = TextEditingController(text: member.phoneNumber);
    final balanceController = TextEditingController(text: member.walletBalance.toString());
    final earningController = TextEditingController(text: member.earningWallet.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${TranslationService.translate('edit')} ${member.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('email'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('phone'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('wallet_balance'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: earningController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: TranslationService.translate('earning_wallet'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(TranslationService.translate('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final updates = {
                'name': nameController.text,
                'email': emailController.text,
                'phoneNumber': phoneController.text,
                'walletBalance': double.tryParse(balanceController.text) ?? member.walletBalance,
                'earningWallet': double.tryParse(earningController.text) ?? member.earningWallet,
              };
              
              final success = await MLMService.updateMemberInfo(member.id, updates);
              Navigator.of(context).pop();
              
              if (success) {
                _loadRequests();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${TranslationService.translate('user_updated_successfully')}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${TranslationService.translate('failed_to_update_user')}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(TranslationService.translate('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(Member member) async {
    final updates = {'isActive': !member.isActive};
    final success = await MLMService.updateMemberInfo(member.id, updates);
    
    if (success) {
      _loadRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            member.isActive
                ? '${member.name} ${TranslationService.translate('has_been_deactivated')}'
                : '${member.name} ${TranslationService.translate('has_been_activated')}',
          ),
          backgroundColor: member.isActive ? Colors.orange : Colors.green,
        ),
      );
      
      // Send notification to user
      await NotificationService.createNotification(
        memberId: member.id,
        title: member.isActive
            ? TranslationService.translate('account_deactivated')
            : TranslationService.translate('account_activated'),
        message: member.isActive
            ? TranslationService.translate('account_deactivated_message')
            : TranslationService.translate('account_activated_message'),
        type: NotificationType.general,
        data: {'action': member.isActive ? 'deactivated' : 'activated'},
      );
    }
  }
}
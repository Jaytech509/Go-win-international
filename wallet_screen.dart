import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/models/transaction.dart';
import 'package:ascendant_reach/models/pending_transaction.dart';
import 'package:ascendant_reach/services/translation_service.dart';
import 'package:ascendant_reach/services/notification_service.dart';
import 'package:ascendant_reach/widgets/common_app_bar.dart';
import 'package:ascendant_reach/widgets/credit_card_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Member? _currentMember;
  List<Transaction> _transactions = [];

  // Wallet fees
  static const double _depositFee = 0.05; // 5%
  static const double _withdrawalFee = 0.10; // 10%
  static const double _transferFee = 0.025; // 2.5%
  
  // Withdrawal limits
  static const double _minWithdrawal = 5.0; // $5 minimum
  static const double _maxWeeklyWithdrawal = 100.0; // $100 maximum per week
  
  // Board fee
  static const double _boardJoinFee = 1.0; // $1 minimum board fee

  @override
  void initState() {
    super.initState();
    _loadWalletData();
    _processInvestmentReturns();
  }

  void _loadWalletData() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
      if (_currentMember != null) {
        _transactions = StorageService.getTransactions()
            .where((t) => t.memberId == _currentMember!.id)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    });
  }

  void _processInvestmentReturns() {
    if (_currentMember == null) return;

    // Check for matured investments and add daily returns
    bool hasUpdates = false;
    final now = DateTime.now();
    final updatedInvestments = <Map<String, dynamic>>[];
    double totalReturns = 0;

    for (final investment in _currentMember!.activeInvestments) {
      final startDate = DateTime.parse(investment['startDate']);
      final amount = investment['amount'] as double;
      final daysActive = now.difference(startDate).inDays;
      final lastReturnDate = investment['lastReturnDate'] != null 
          ? DateTime.parse(investment['lastReturnDate'])
          : startDate;
      
      if (daysActive < 90) {
        // Calculate daily returns for days since last return
        final daysSinceLastReturn = now.difference(lastReturnDate).inDays;
        if (daysSinceLastReturn > 0) {
          final dailyReturn = amount * 0.015; // 1.5% daily
          totalReturns += dailyReturn * daysSinceLastReturn;
          
          investment['lastReturnDate'] = now.toIso8601String();
          investment['totalReturned'] = (investment['totalReturned'] ?? 0.0) + (dailyReturn * daysSinceLastReturn);
        }
        updatedInvestments.add(investment);
      } else if (daysActive >= 90) {
        // Investment matured, move to completed
        final finalReturn = amount * 0.015; // Final day return
        totalReturns += finalReturn;
        hasUpdates = true;
      }
    }

    if (totalReturns > 0 || hasUpdates) {
      // Update member with returns
      final updatedMember = _currentMember!.copyWith(
        investmentWallet: _currentMember!.investmentWallet + totalReturns,
        activeInvestments: updatedInvestments,
      );
      StorageService.saveCurrentMember(updatedMember);
      setState(() => _currentMember = updatedMember);

      // Create transaction record
      if (totalReturns > 0) {
        final transaction = Transaction(
          id: const Uuid().v4(),
          memberId: _currentMember!.id,
          type: TransactionType.investmentProfit,
          amount: totalReturns,
          currency: 'USD',
          status: TransactionStatus.completed,
          description: 'Daily investment returns (1.5%)',
          createdAt: now,
          completedAt: now,
          metadata: {'type': 'daily_return'},
        );
        
        final transactions = StorageService.getTransactions();
        transactions.add(transaction);
        StorageService.saveTransactions(transactions);
      }
    }
  }

  void _showDepositDialog() {
    showDialog(
      context: context,
      builder: (context) => _DepositDialog(
        onDeposit: _handleDeposit,
        availableWallets: _getAvailableWalletsForDeposit(),
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => _WithdrawDialog(
        maxAmount: _currentMember!.walletBalance,
        onWithdraw: _handleWithdraw,
        availableWallets: _getAvailableWallets(),
      ),
    );
  }

  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (context) => _TransferDialog(
        availableWallets: _getAvailableWalletsForTransfer(),
        fromMemberId: _currentMember!.id,
        onTransfer: _handleTransfer,
      ),
    );
  }

  void _showInvestmentDialog() {
    showDialog(
      context: context,
      builder: (context) => _InvestmentDialog(
        availableWallets: _getAvailableWallets(),
        onInvest: _handleInvestment,
      ),
    );
  }

  Map<String, double> _getAvailableWallets() {
    if (_currentMember == null) return {};
    
    return {
      'Main Balance': _currentMember!.walletBalance,
      'Earning Wallet': _currentMember!.earningWallet,
      'Investment Wallet': _currentMember!.investmentWallet,
      'Wallet Commission Products': _currentMember!.walletCommissionProducts,
    };
  }

  Map<String, double> _getAvailableWalletsForDeposit() {
    if (_currentMember == null) return {};
    
    // Only Main Balance and Investment Wallet allow deposits
    return {
      'Main Balance': _currentMember!.walletBalance,
      'Investment Wallet': _currentMember!.investmentWallet,
    };
  }

  Map<String, double> _getAvailableWalletsForTransfer() {
    if (_currentMember == null) return {};
    
    // Only Main Balance and Investment Wallet allow transfers
    return {
      'Main Balance': _currentMember!.walletBalance,
      'Investment Wallet': _currentMember!.investmentWallet,
    };
  }


  void _handleDeposit(double amount, PaymentMethod method, String fromWallet) async {
    try {
      final netAmount = amount * (1 - _depositFee); // Apply 5% fee
      final feeAmount = amount * _depositFee;
      
      // Create pending deposit transaction requiring admin approval
      final pendingTransactions = StorageService.getPendingTransactions();
      final pendingTransaction = PendingTransaction(
        id: const Uuid().v4(),
        memberId: _currentMember!.id,
        memberName: _currentMember!.name,
        memberEmail: _currentMember!.email,
        type: PendingTransactionType.deposit,
        amount: amount,
        currency: 'USD',
        paymentMethod: method,
        description: 'Deposit via ${method.name} (Net: \$${netAmount.toStringAsFixed(2)}, Fee: \$${feeAmount.toStringAsFixed(2)}) - Pending admin approval',
        createdAt: DateTime.now(),
        status: ApprovalStatus.pending,
        metadata: {'fromWallet': fromWallet, 'netAmount': netAmount, 'feeAmount': feeAmount},
      );
      
      pendingTransactions.add(pendingTransaction);
      await StorageService.savePendingTransactions(pendingTransactions);
      
      // Log user activity
      await StorageService.logUserActivity(_currentMember!.id, 'deposit_request', {
        'amount': amount,
        'netAmount': netAmount,
        'feeAmount': feeAmount,
        'method': method.name,
        'toWallet': fromWallet,
      });
      
      // Send notification to admins about deposit request
      await NotificationService.notifyAdminsOfUserAction(
        _currentMember!.id,
        _currentMember!.name,
        'Deposit Request Submitted',
        {
          'amount': amount,
          'netAmount': netAmount,
          'method': method.name,
          'toWallet': fromWallet,
        },
      );
      
      _loadWalletData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Deposit request submitted! Awaiting admin approval.', 
                style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Amount: \$${amount.toStringAsFixed(2)}'),
              Text('Fee (5%): \$${feeAmount.toStringAsFixed(2)}'),
              Text('Net amount: \$${netAmount.toStringAsFixed(2)}'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting deposit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleWithdraw(double amount, PaymentMethod method, String fromWallet, String accountId, String accountName) async {
    try {
      // Check withdrawal amount limits
      if (amount < _minWithdrawal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationService.translate('minimum_withdrawal')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (amount > _maxWeeklyWithdrawal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(TranslationService.translate('maximum_withdrawal')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Check withdrawal restrictions
      if (!MLMService.canWithdraw(_currentMember!.id)) {
        final message = MLMService.getWithdrawalRestrictionMessage(_currentMember!.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      final feeAmount = amount * _withdrawalFee;
      final netAmount = amount - feeAmount; // Deduct 10% fee
      
      await MLMService.createWithdrawalRequest(
        memberId: _currentMember!.id,
        amount: amount,
        paymentMethod: method.name,
        accountId: accountId,
        accountName: accountName,
      );
      
      // Log user activity
      await StorageService.logUserActivity(_currentMember!.id, 'withdrawal_request', {
        'amount': amount,
        'netAmount': netAmount,
        'feeAmount': feeAmount,
        'method': method.name,
        'fromWallet': fromWallet,
        'accountId': accountId,
        'accountName': accountName,
      });
      
      // Send notification to admins about withdrawal request
      await NotificationService.notifyAdminsOfUserAction(
        _currentMember!.id,
        _currentMember!.name,
        'Withdrawal Request Submitted',
        {
          'amount': amount,
          'netAmount': netAmount,
          'method': method.name,
          'fromWallet': fromWallet,
        },
      );
      
      _loadWalletData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Withdrawal request submitted! Awaiting admin approval.',
                style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Amount: \$${amount.toStringAsFixed(2)}'),
              Text('Fee (10%): \$${feeAmount.toStringAsFixed(2)}'),
              Text('Net amount: \$${netAmount.toStringAsFixed(2)}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting withdrawal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleTransfer(double amount, String fromWallet, String toEmail, String note) async {
    try {
      final feeAmount = amount * _transferFee;
      final netAmount = amount - feeAmount; // Deduct 2.5% fee
      
      // Create pending transfer transaction requiring admin approval
      final pendingTransactions = StorageService.getPendingTransactions();
      final pendingTransaction = PendingTransaction(
        id: const Uuid().v4(),
        memberId: _currentMember!.id,
        memberName: _currentMember!.name,
        memberEmail: _currentMember!.email,
        type: PendingTransactionType.transfer,
        amount: amount,
        currency: 'USD',
        description: 'Transfer to $toEmail: $note (Net: \$${netAmount.toStringAsFixed(2)}, Fee: \$${feeAmount.toStringAsFixed(2)}) - Pending admin approval',
        createdAt: DateTime.now(),
        metadata: {'fromWallet': fromWallet, 'toEmail': toEmail, 'note': note, 'netAmount': netAmount, 'feeAmount': feeAmount},
        status: ApprovalStatus.pending,
      );
      
      pendingTransactions.add(pendingTransaction);
      await StorageService.savePendingTransactions(pendingTransactions);
      
      // Log user activity
      await StorageService.logUserActivity(_currentMember!.id, 'transfer_request', {
        'amount': amount,
        'netAmount': netAmount,
        'feeAmount': feeAmount,
        'fromWallet': fromWallet,
        'toEmail': toEmail,
        'note': note,
      });
      
      // Send notification to admins about transfer request
      await NotificationService.notifyAdminsOfUserAction(
        _currentMember!.id,
        _currentMember!.name,
        'Transfer Request Submitted',
        {
          'amount': amount,
          'netAmount': netAmount,
          'fromWallet': fromWallet,
          'toEmail': toEmail,
        },
      );
      
      _loadWalletData();
      
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Transfer request submitted! Awaiting admin approval.',
                style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Amount: \$${amount.toStringAsFixed(2)}'),
              Text('Fee (2.5%): \$${feeAmount.toStringAsFixed(2)}'),
              Text('Net amount: \$${netAmount.toStringAsFixed(2)}'),
              Text('To: $toEmail'),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transfer request failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleInvestment(double amount, String fromWallet) async {
    try {
      // Create investment record
      final investment = {
        'id': const Uuid().v4(),
        'amount': amount,
        'startDate': DateTime.now().toIso8601String(),
        'fromWallet': fromWallet,
        'totalReturned': 0.0,
        'lastReturnDate': DateTime.now().toIso8601String(),
      };

      // Update member's active investments
      final updatedInvestments = List<Map<String, dynamic>>.from(_currentMember!.activeInvestments);
      updatedInvestments.add(investment);

      // Deduct from selected wallet
      Member updatedMember;
      switch (fromWallet) {
        case 'Main Balance':
          updatedMember = _currentMember!.copyWith(
            walletBalance: _currentMember!.walletBalance - amount,
            activeInvestments: updatedInvestments,
          );
          break;
        case 'Earning Wallet':
          updatedMember = _currentMember!.copyWith(
            earningWallet: _currentMember!.earningWallet - amount,
            activeInvestments: updatedInvestments,
          );
          break;
        case 'Investment Wallet':
          updatedMember = _currentMember!.copyWith(
            investmentWallet: _currentMember!.investmentWallet - amount,
            activeInvestments: updatedInvestments,
          );
          break;
        case 'Wallet Commission Products':
          updatedMember = _currentMember!.copyWith(
            walletCommissionProducts: _currentMember!.walletCommissionProducts - amount,
            activeInvestments: updatedInvestments,
          );
          break;
        default:
          throw Exception('Invalid wallet selection');
      }

      StorageService.saveCurrentMember(updatedMember);
      setState(() => _currentMember = updatedMember);

      // Create transaction record
      final transaction = Transaction(
        id: const Uuid().v4(),
        memberId: _currentMember!.id,
        type: TransactionType.investment,
        amount: amount,
        currency: 'USD',
        status: TransactionStatus.completed,
        description: 'Investment for earnings (1.5% daily for 90 days) from $fromWallet',
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
        metadata: {'fromWallet': fromWallet, 'investmentId': investment['id']},
      );
      
      final transactions = StorageService.getTransactions();
      transactions.add(transaction);
      StorageService.saveTransactions(transactions);
      
      // Log user activity
      await StorageService.logUserActivity(_currentMember!.id, 'investment', {
        'amount': amount,
        'fromWallet': fromWallet,
        'investmentId': investment['id'],
        'expectedTotal': (amount * 2.35),
      });
      
      // Send progress notification to user
      await MLMService.notifyProgressUpdate(
        _currentMember!.id,
        'investment_created',
        {
          'amount': amount,
          'fromWallet': fromWallet,
          'expectedReturns': (amount * 2.35),
        },
      );
      
      _loadWalletData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Investment successful!', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Amount: \$${amount.toStringAsFixed(2)}'),
              Text('Returns: 1.5% daily for 90 days'),
              Text('Expected total: \$${(amount * 2.35).toStringAsFixed(2)}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Investment failed: $e'),
          backgroundColor: Colors.red,
        ),
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

    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: const CommonAppBar(title: 'wallet'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserProfile(formatter),
            _buildWalletBalances(formatter),
            _buildInvestmentSection(formatter),
            _buildWalletActions(),
            _buildTransactionHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                backgroundImage: _currentMember!.profilePicture != null
                    ? NetworkImage(_currentMember!.profilePicture!)
                    : null,
                child: _currentMember!.profilePicture == null
                    ? Text(
                        _currentMember!.name.isNotEmpty ? _currentMember!.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentMember!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      'Level ${_currentMember!.level} ${_currentMember!.rank.name.toUpperCase()}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(_currentMember!.stars, (index) => 
                        Icon(Icons.star, color: Colors.amber, size: 16)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBalances(NumberFormat formatter) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main Balance
          _buildWalletCardWithEarnings(
            icon: Icons.account_balance_wallet,
            title: TranslationService.translate('main_balance'),
            balance: _currentMember!.walletBalance,
            color: Theme.of(context).colorScheme.primary,
            formatter: formatter,
            restrictions: TranslationService.translate('available_friday'),
            earnings: _getMainBalanceEarnings(),
          ),
          const SizedBox(height: 12),
          
          // Earning Wallet
          _buildWalletCardWithEarnings(
            icon: Icons.trending_up,
            title: TranslationService.translate('earning_wallet'),
            balance: _currentMember!.earningWallet,
            color: Colors.green,
            formatter: formatter,
            restrictions: TranslationService.translate('board_completion_required'),
            earnings: _getEarningWalletEarnings(),
          ),
          const SizedBox(height: 12),
          
          // Investment Wallet
          _buildWalletCardWithEarnings(
            icon: Icons.savings,
            title: TranslationService.translate('investment_wallet'),
            balance: _currentMember!.investmentWallet,
            color: Colors.purple,
            formatter: formatter,
            restrictions: TranslationService.translate('available_monthly'),
            earnings: _getInvestmentEarnings(),
          ),
          const SizedBox(height: 12),
          
          // Wallet Commission Products
          _buildWalletCardWithEarnings(
            icon: Icons.credit_card,
            title: TranslationService.translate('wallet_commission_products'),
            balance: _currentMember!.walletCommissionProducts,
            color: Colors.orange,
            formatter: formatter,
            restrictions: TranslationService.translate('commission_only_wallet'),
            earnings: _getCommissionEarnings(),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard({
    required IconData icon,
    required String title,
    required double balance,
    required Color color,
    required NumberFormat formatter,
    String? restrictions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  formatter.format(balance),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (restrictions != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      restrictions,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWalletCardWithEarnings({
    required IconData icon,
    required String title,
    required double balance,
    required Color color,
    required NumberFormat formatter,
    String? restrictions,
    required Map<String, String> earnings,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      formatter.format(balance),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (restrictions != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restrictions,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      TranslationService.translate('earning_opportunities'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...earnings.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: TextStyle(
                            fontSize: 11,
                            color: color.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, String> _getMainBalanceEarnings() {
    return {
      TranslationService.translate('board_referrals'): '100% direct, 75% level 2, 50% level 3+',
      TranslationService.translate('weekly_withdrawals'): 'Available each Friday',
      TranslationService.translate('fees'): '5% deposit, 10% withdrawal, 2.5% transfer',
      TranslationService.translate('minimum_amounts'): 'Min deposit: \$1, Min withdrawal: \$5',
    };
  }
  
  Map<String, String> _getEarningWalletEarnings() {
    return {
      TranslationService.translate('referral_profits'): 'Cumulative team earnings',
      TranslationService.translate('board_bonuses'): 'Level completion rewards',
      TranslationService.translate('withdrawal_condition'): 'Available when board is completed',
      TranslationService.translate('earning_rate'): '10-20% based on team performance',
    };
  }
  
  Map<String, String> _getInvestmentEarnings() {
    return {
      TranslationService.translate('daily_returns'): '1.5% daily for 90 days',
      TranslationService.translate('total_return'): '135% total return on investment',
      TranslationService.translate('monthly_withdrawals'): 'Available each month',
      TranslationService.translate('compound_option'): 'Reinvest for higher returns',
    };
  }
  
  Map<String, String> _getCommissionEarnings() {
    return {
      TranslationService.translate('product_sales'): '10% commission on all product sales',
      TranslationService.translate('referral_sales'): 'Earn from team member sales',
      TranslationService.translate('friday_withdrawals'): 'Available each Friday',
      TranslationService.translate('subscription_required'): '\$10/year for product sharing',
    };
  }
  
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDepositDialog,
                  icon: const Icon(Icons.add),
                  label: Text(TranslationService.translate('deposit')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showWithdrawDialog,
                  icon: const Icon(Icons.remove),
                  label: Text(TranslationService.translate('withdraw')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showTransferDialog,
                  icon: const Icon(Icons.swap_horiz),
                  label: Text(TranslationService.translate('transfer')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showInvestmentDialog,
                  icon: const Icon(Icons.trending_up),
                  label: Text(TranslationService.translate('invest_for_earnings')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOldWalletCard({
    required IconData icon,
    required String title,
    required double balance,
    required Color color,
    required NumberFormat formatter,
    String? restrictions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      formatter.format(balance),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (restrictions != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restrictions,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Earnings info integrated in main card
        ],
      ),
    );
  }

  Widget _buildInvestmentSection(NumberFormat formatter) {
    if (_currentMember!.activeInvestments.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.purple, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Active Investments',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Investment summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: _currentMember!.activeInvestments.map((investment) {
                    final amount = investment['amount'] as double;
                    final startDate = DateTime.parse(investment['startDate']);
                    final daysActive = DateTime.now().difference(startDate).inDays;
                    final totalReturned = investment['totalReturned'] ?? 0.0;
                    final daysRemaining = 90 - daysActive;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Investment: ${formatter.format(amount)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${daysActive}/90 days',
                                style: TextStyle(color: Colors.purple.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Returns so far: ${formatter.format(totalReturned)}'),
                              Text('Days remaining: $daysRemaining'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: daysActive / 90,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallet Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Fee information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text('Transaction Fees', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('• Deposit Fee: 5%', style: const TextStyle(fontSize: 12)),
                Text('• Withdrawal Fee: 10%', style: const TextStyle(fontSize: 12)),
                Text('• Transfer Fee: 2.5%', style: const TextStyle(fontSize: 12)),
                Text('• Investment: No fees, 1.5% daily returns for 90 days', 
                  style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add,
                  label: 'Deposit\n(+5% Fee)',
                  onPressed: _showDepositDialog,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.remove,
                  label: 'Withdraw\n(+10% Fee)',
                  onPressed: _getTotalAvailableBalance() > 0 ? _showWithdrawDialog : null,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Transfer\n(+2.5% Fee)',
                  onPressed: _getTotalAvailableBalance() > 0 ? _showTransferDialog : null,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.trending_up,
                  label: 'Invest\n(1.5% daily)',
                  onPressed: _getTotalAvailableBalance() > 0 ? _showInvestmentDialog : null,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getTotalAvailableBalance() {
    if (_currentMember == null) return 0;
    return _currentMember!.walletBalance + 
           _currentMember!.earningWallet + 
           _currentMember!.investmentWallet + 
           _currentMember!.walletCommissionProducts;
  }
  

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? color : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Transaction History',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_transactions.length} records',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: _transactions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _buildTransactionItem(_transactions[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormatter = DateFormat('MMM dd, HH:mm');
    
    IconData icon;
    Color iconColor;
    String sign;

    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.add_circle;
        iconColor = Colors.green;
        sign = '+';
        break;
      case TransactionType.withdrawal:
        icon = Icons.remove_circle;
        iconColor = Colors.red;
        sign = '-';
        break;
      case TransactionType.investment:
        icon = Icons.trending_up;
        iconColor = Colors.purple;
        sign = '-';
        break;
      case TransactionType.investmentProfit:
        icon = Icons.savings;
        iconColor = Colors.purple;
        sign = '+';
        break;
      case TransactionType.fee:
        icon = Icons.account_balance;
        iconColor = Colors.orange;
        sign = '-';
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        iconColor = Colors.blue;
        sign = transaction.description.contains('sent') ? '-' : '+';
        break;
      case TransactionType.referralProfit:
        icon = Icons.people;
        iconColor = Colors.amber;
        sign = '+';
        break;
      default:
        icon = Icons.receipt;
        iconColor = Colors.grey;
        sign = '+';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormatter.format(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${formatter.format(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }
}

class _DepositDialog extends StatefulWidget {
  final Function(double amount, PaymentMethod method, String fromWallet) onDeposit;
  final Map<String, double> availableWallets;

  const _DepositDialog({
    required this.onDeposit,
    required this.availableWallets,
  });

  @override
  State<_DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<_DepositDialog> {
  final _amountController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.wireBank;
  String _selectedWallet = 'Main Balance';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Deposit Funds'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
                helperText: 'Note: 5% deposit fee will be applied',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: [
                PaymentMethod.wireBank,
                PaymentMethod.stripeLink,
                PaymentMethod.creditCard,
                PaymentMethod.creditLivegood,
                PaymentMethod.cash,
                PaymentMethod.moncash,
                PaymentMethod.natcash,
                PaymentMethod.paypal,
                PaymentMethod.wise,
                PaymentMethod.cryptocurrency,
              ].map((method) {
                String displayName;
                switch (method) {
                  case PaymentMethod.wireBank:
                    displayName = TranslationService.translate('wire_bank');
                    break;
                  case PaymentMethod.stripeLink:
                    displayName = TranslationService.translate('stripe_link');
                    break;
                  case PaymentMethod.creditCard:
                    displayName = TranslationService.translate('credit_card');
                    break;
                  case PaymentMethod.creditLivegood:
                    displayName = TranslationService.translate('credit_livegood');
                    break;
                  case PaymentMethod.cash:
                    displayName = TranslationService.translate('cash');
                    break;
                  case PaymentMethod.paypal:
                    displayName = 'PayPal';
                    break;
                  case PaymentMethod.moncash:
                    displayName = 'MonCash';
                    break;
                  case PaymentMethod.natcash:
                    displayName = 'NatCash';
                    break;
                  case PaymentMethod.wise:
                    displayName = 'Wise';
                    break;
                  case PaymentMethod.cryptocurrency:
                    displayName = 'Cryptocurrency';
                    break;
                  default:
                    displayName = method.name.toUpperCase();
                }
                return DropdownMenuItem(
                  value: method,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedWallet,
              decoration: const InputDecoration(
                labelText: 'Deposit To',
                border: OutlineInputBorder(),
              ),
              items: ['Main Balance', 'Investment Wallet']
                  .map((wallet) => DropdownMenuItem(
                        value: wallet,
                        child: Text(wallet),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedWallet = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null && amount > 0) {
              widget.onDeposit(amount, _selectedMethod, _selectedWallet);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid amount'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Submit Deposit'),
        ),
      ],
    );
  }
}

class _WithdrawDialog extends StatefulWidget {
  final double maxAmount;
  final Function(double amount, PaymentMethod method, String fromWallet, String accountId, String accountName) onWithdraw;
  final Map<String, double> availableWallets;

  const _WithdrawDialog({
    required this.maxAmount,
    required this.onWithdraw,
    required this.availableWallets,
  });

  @override
  State<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends State<_WithdrawDialog> {
  final _amountController = TextEditingController();
  final _accountIdController = TextEditingController();
  final _accountNameController = TextEditingController();
  PaymentMethod _selectedMethod = PaymentMethod.wireBank;
  String _selectedWallet = 'Main Balance';

  @override
  Widget build(BuildContext context) {
    final selectedBalance = widget.availableWallets[_selectedWallet] ?? 0.0;
    
    return AlertDialog(
      title: const Text('Withdraw Funds'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedWallet,
              decoration: const InputDecoration(
                labelText: 'Withdraw From',
                border: OutlineInputBorder(),
              ),
              items: widget.availableWallets.keys
                  .map((wallet) => DropdownMenuItem(
                        value: wallet,
                        child: Text('$wallet (\$${widget.availableWallets[wallet]!.toStringAsFixed(2)})'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedWallet = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
                helperText: 'Max: \$${selectedBalance.toStringAsFixed(2)} - 10% fee will be deducted',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PaymentMethod>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Withdrawal Method',
                border: OutlineInputBorder(),
              ),
              items: [
                PaymentMethod.wireBank,
                PaymentMethod.moncash,
                PaymentMethod.natcash,
                PaymentMethod.paypal,
                PaymentMethod.wise,
                PaymentMethod.cryptocurrency,
              ].map((method) {
                String displayName;
                switch (method) {
                  case PaymentMethod.wireBank:
                    displayName = 'Wire Bank';
                    break;
                  default:
                    displayName = method.name.toUpperCase();
                }
                return DropdownMenuItem(
                  value: method,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountIdController,
              decoration: const InputDecoration(
                labelText: 'Account ID Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_box),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            final accountId = _accountIdController.text.trim();
            final accountName = _accountNameController.text.trim();
            
            if (amount != null && amount > 0 && amount <= selectedBalance && 
                accountId.isNotEmpty && accountName.isNotEmpty) {
              widget.onWithdraw(amount, _selectedMethod, _selectedWallet, accountId, accountName);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields with valid information'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}

class _TransferDialog extends StatefulWidget {
  final Map<String, double> availableWallets;
  final String fromMemberId;
  final Function(double amount, String fromWallet, String toEmail, String note) onTransfer;

  const _TransferDialog({
    required this.availableWallets,
    required this.fromMemberId,
    required this.onTransfer,
  });

  @override
  State<_TransferDialog> createState() => _TransferDialogState();
}

class _TransferDialogState extends State<_TransferDialog> {
  final _amountController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedWallet = 'Main Balance';

  @override
  Widget build(BuildContext context) {
    final selectedBalance = widget.availableWallets[_selectedWallet] ?? 0.0;
    
    return AlertDialog(
      title: const Text('Transfer to User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedWallet,
            decoration: const InputDecoration(
              labelText: 'Transfer From',
              border: OutlineInputBorder(),
            ),
            items: widget.availableWallets.keys
                .map((wallet) => DropdownMenuItem(
                      value: wallet,
                      child: Text('$wallet (\$${widget.availableWallets[wallet]!.toStringAsFixed(2)})'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedWallet = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Recipient Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
              border: const OutlineInputBorder(),
              helperText: 'Max: \$${selectedBalance.toStringAsFixed(2)} - 2.5% fee will be deducted',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (Optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            final email = _emailController.text.trim();
            final note = _noteController.text.trim();
            
            if (amount != null && amount > 0 && amount <= selectedBalance && email.isNotEmpty) {
              widget.onTransfer(amount, _selectedWallet, email, note);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter valid amount and recipient email'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Transfer'),
        ),
      ],
    );
  }
}

class _InvestmentDialog extends StatefulWidget {
  final Map<String, double> availableWallets;
  final Function(double amount, String fromWallet) onInvest;

  const _InvestmentDialog({
    required this.availableWallets,
    required this.onInvest,
  });

  @override
  State<_InvestmentDialog> createState() => _InvestmentDialogState();
}

class _InvestmentDialogState extends State<_InvestmentDialog> {
  final _amountController = TextEditingController();
  String _selectedWallet = 'Main Balance';

  @override
  Widget build(BuildContext context) {
    final selectedBalance = widget.availableWallets[_selectedWallet] ?? 0.0;
    
    return AlertDialog(
      title: const Text('Invest for Earnings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🚀 INVEST FOR EARNINGS', 
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                const SizedBox(height: 8),
                const Text('• Earn 1.5% daily returns for 90 days', style: TextStyle(fontSize: 12)),
                const Text('• Total potential return: 135%', style: TextStyle(fontSize: 12)),
                const Text('• Automatic daily payouts to Investment Wallet', style: TextStyle(fontSize: 12)),
                const Text('• No fees on investment transactions', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedWallet,
            decoration: const InputDecoration(
              labelText: 'Invest From',
              border: OutlineInputBorder(),
            ),
            items: widget.availableWallets.keys
                .map((wallet) => DropdownMenuItem(
                      value: wallet,
                      child: Text('$wallet (\$${widget.availableWallets[wallet]!.toStringAsFixed(2)})'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedWallet = value!),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Investment Amount',
              prefixText: '\$ ',
              border: const OutlineInputBorder(),
              helperText: 'Max: \$${selectedBalance.toStringAsFixed(2)}',
            ),
          ),
          const SizedBox(height: 16),
          if (_amountController.text.isNotEmpty) ...[
            const Divider(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Investment Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Investment: \$${_amountController.text}'),
                  Text('Daily Return: \$${(double.tryParse(_amountController.text) ?? 0 * 0.015).toStringAsFixed(2)}'),
                  Text('Total after 90 days: \$${((double.tryParse(_amountController.text) ?? 0) * 2.35).toStringAsFixed(2)}'),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            
            if (amount != null && amount > 0 && amount <= selectedBalance) {
              widget.onInvest(amount, _selectedWallet);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid investment amount'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text('Start Investment'),
        ),
      ],
    );
  }
}
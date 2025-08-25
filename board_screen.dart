import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/services/translation_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/models/board.dart';
import 'package:ascendant_reach/models/board_join_request.dart';
import 'package:ascendant_reach/widgets/common_app_bar.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  Member? _currentMember;
  MLMBoard? _currentBoard;
  BoardJoinRequest? _pendingRequest;
  bool _isLoading = false;
  final _paymentMethodController = TextEditingController();
  final _imageUploadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBoardData();
  }

  void _loadBoardData() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
      _currentBoard = null;
      _pendingRequest = null;
      
      if (_currentMember?.boardId != null) {
        final boards = StorageService.getBoards();
        _currentBoard = boards.cast<MLMBoard?>().firstWhere(
          (board) => board?.id == _currentMember!.boardId,
          orElse: () => null,
        );
      }
      
      // Check for pending join request
      if (_currentMember != null) {
        final requests = StorageService.getBoardJoinRequests();
        _pendingRequest = requests.cast<BoardJoinRequest?>().firstWhere(
          (r) => r?.memberId == _currentMember!.id && r?.status == ApprovalStatus.pending,
          orElse: () => null,
        );
      }
    });
  }

  Future<void> _showDepositDialog() async {
    showDialog(
      context: context,
      builder: (context) => DepositDialog(
        level: _currentMember!.level,
        onDepositSubmitted: _submitDepositRequest,
      ),
    );
  }

  Future<void> _submitDepositRequest(String paymentMethod, String? paymentProof, double amount, String accountId, String accountName) async {
    if (_currentMember == null) return;

    if (amount < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(TranslationService.translate('minimum_deposit')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await MLMService.createBoardJoinRequest(
        memberId: _currentMember!.id,
        requestedLevel: _currentMember!.level,
        paymentMethod: paymentMethod,
        paymentProof: paymentProof,
        depositAmount: amount,
        accountId: accountId,
        accountName: accountName,
      );
      
      _loadBoardData(); // Refresh data
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deposit submitted! Awaiting admin approval to join board.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting deposit: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinAvailableBoard(MLMBoard board) async {
    if (_currentMember == null) return;

    setState(() => _isLoading = true);
    try {
      final assignedBoard = await MLMService.assignMemberToBoard(_currentMember!.id);
      
      // Update current member with board assignment
      await StorageService.saveCurrentMember(
        _currentMember!.copyWith(boardId: assignedBoard.id)
      );
      
      _loadBoardData(); // Refresh data
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully joined board!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error joining board: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAndJoinNewBoard() async {
    if (_currentMember == null) return;

    setState(() => _isLoading = true);
    try {
      final assignedBoard = await MLMService.assignMemberToBoard(_currentMember!.id);
      
      // Update current member with board assignment
      await StorageService.saveCurrentMember(
        _currentMember!.copyWith(boardId: assignedBoard.id)
      );
      
      _loadBoardData(); // Refresh data
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully created and joined new board!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating board: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
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
        title: Text('Level ${_currentMember!.level} Board'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _buildBodyContent(),
    );
  }

  Widget _buildBodyContent() {
    // Check approval status by jaytechpromo@gmail.com admin
    final boardJoinStatus = _currentMember!.boardJoinStatus;
    
    // Handle different approval statuses
    switch (boardJoinStatus) {
      case ApprovalStatus.pending:
        return _buildPendingApprovalView();
      
      case ApprovalStatus.rejected:
        return _buildRejectedView();
      
      case ApprovalStatus.approved:
        // User is approved by administrator - show pyramidal board with current user as Legend Gold
        return _buildPyramidalBoardView();
      
      default:
        // No approval status yet or needs deposit - check if there's a pending request
        if (_pendingRequest != null) {
          return _buildPendingApprovalView();
        } else {
          return _buildJoinBoardView();
        }
    }
  }

  Widget _buildDepositRequiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Deposit Required',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Minimum amount to join: \$1.00',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'To access the Level ${_currentMember!.level} board, you must:\n• Make a minimum amount of \$1.00\n• Get approval from an administrator',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          if (_currentMember!.depositAmount > 0) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Current Deposit: \$${_currentMember!.depositAmount.toStringAsFixed(2)}'),
                    if (_pendingRequest != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text('Pending Approval', style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _isLoading ? null : _showDepositDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _currentMember!.depositAmount > 0 ? 'Add More Deposit' : 'Make Deposit', 
                    style: const TextStyle(fontSize: 16)
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinBoardView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_module,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Join Level ${_currentMember!.level} Board',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Level ${_currentMember!.level} board fee: \$${BoardJoinRequest.getLevelFee(_currentMember!.level).toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'To join the board, you need to make a payment\nand get approval from an administrator.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _showDepositDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Make Payment', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Awaiting Approval',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment has been submitted.\nWaiting for administrator approval.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Details', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Amount: \$${_pendingRequest!.paymentAmount.toStringAsFixed(2)}'),
                  Text('Method: ${_pendingRequest!.paymentMethod}'),
                  Text('Submitted: ${_pendingRequest!.requestDate.toString().split(' ')[0]}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cancel,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Payment Rejected',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Your payment was rejected by the administrator.\nPlease contact support or try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _showDepositDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Try Again', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPyramidalBoardView() {
    // Get all members for referral display
    final allMembers = StorageService.getMembers();
    
    // Create a list of 14 referral users (excluding current user who is Legend Gold)
    final referralUsers = allMembers.where((m) => m.id != _currentMember!.id).take(14).toList();
    
    // Fill remaining slots with placeholder data if needed
    while (referralUsers.length < 14) {
      referralUsers.add(Member(
        id: 'placeholder-${referralUsers.length}',
        name: 'User ${referralUsers.length + 1}',
        email: 'user${referralUsers.length + 1}@gowin.com',
        phoneNumber: '+1-555-${(referralUsers.length + 200).toString().padLeft(4, '0')}',
        referralCode: 'USR${referralUsers.length + 1}',
        rank: MemberRank.starter,
        level: 1,
        boardPosition: referralUsers.length,
        directReferrals: [],
        points: 50,
        walletBalance: 100.0,
        joinDate: DateTime.now().subtract(Duration(days: 30 + referralUsers.length)),
        isActive: true,
        profilePicture: 'https://picsum.photos/200/200?random=${referralUsers.length + 200}',
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header card
          Card(
            elevation: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFFD700), // Gold
                    const Color(0xFFFFA500), // Orange Gold
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.star,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LEGEND GOLD BOARD',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level ${_currentMember!.level} • 14 Referral Positions + Legend Gold',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Pyramidal Board Structure
          _buildPyramidalStructure(referralUsers),
          
          const SizedBox(height: 24),
          _buildReferralConnectionsCard(referralUsers),
          const SizedBox(height: 20),
          _buildBoardLegend(),
        ],
      ),
    );
  }


  Widget _buildPyramidalStructure(List<Member> referralUsers) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Top: Current User as Legend Gold - Top center
            Text(
              'LEGEND GOLD',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: _buildLegendGoldSlot(_currentMember!),
            ),
            const SizedBox(height: 20),
            
            // Enhanced Connection lines from Legend Gold to Silvers with animated flow
            Container(
              height: 60,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: EnhancedConnectionPainter(
                      color: const Color(0xFFFFD700),
                      level: 1, // Legend Gold to Silvers
                      showDirectReferrals: true,
                    ),
                    size: Size(double.infinity, 60),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildConnectionLabel('Direct to Silver 1', const Color(0xFFFFD700)),
                        _buildConnectionLabel('Direct to Silver 2', const Color(0xFFFFD700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Row 1: 2 Silvers (positions 0-1) - Second level
            Text(
              'SILVER LEVEL',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFFE6E6FA),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUserSlot(referralUsers[0], 0, MemberRank.silver, 'Silver 1'),
                _buildUserSlot(referralUsers[1], 1, MemberRank.silver, 'Silver 2'),
              ],
            ),
            const SizedBox(height: 20),
            
            // Enhanced connection lines from Silvers to Bronze with direct referral indicators
            Container(
              height: 50,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: EnhancedConnectionPainter(
                      color: const Color(0xFFE6E6FA),
                      level: 2, // Silvers to Bronze
                      showDirectReferrals: true,
                    ),
                    size: Size(double.infinity, 50),
                  ),
                  Positioned(
                    top: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildConnectionLabel('Silver 1 → 2 Bronze', const Color(0xFFE6E6FA)),
                        _buildConnectionLabel('Silver 2 → 2 Bronze', const Color(0xFFE6E6FA)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Row 2: 4 Bronze (positions 2-5) - Third level
            Text(
              'BRONZE LEVEL',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFFCD7F32),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildUserSlot(referralUsers[2], 2, MemberRank.bronze, 'Bronze 1'),
                _buildUserSlot(referralUsers[3], 3, MemberRank.bronze, 'Bronze 2'),
                _buildUserSlot(referralUsers[4], 4, MemberRank.bronze, 'Bronze 3'),
                _buildUserSlot(referralUsers[5], 5, MemberRank.bronze, 'Bronze 4'),
              ],
            ),
            const SizedBox(height: 20),
            
            // Enhanced connection lines from Bronze to Starters with direct referral flow
            Container(
              height: 50,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: EnhancedConnectionPainter(
                      color: const Color(0xFFCD7F32),
                      level: 3, // Bronze to Starters
                      showDirectReferrals: true,
                    ),
                    size: Size(double.infinity, 50),
                  ),
                  Positioned(
                    top: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildConnectionLabel('B1→2S', const Color(0xFFCD7F32)),
                        _buildConnectionLabel('B2→2S', const Color(0xFFCD7F32)),
                        _buildConnectionLabel('B3→2S', const Color(0xFFCD7F32)),
                        _buildConnectionLabel('B4→2S', const Color(0xFFCD7F32)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Row 3: 8 Starters (positions 6-13) - Bottom level
            Text(
              'STARTERS LEVEL',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFFDDCC9A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                for (int i = 6; i < 14; i++)
                  _buildUserSlot(referralUsers[i], i, MemberRank.starter, 'Starter ${i - 5}'),
              ],
            ),
            const SizedBox(height: 20),
            
            // Legend Gold is now positioned at the top of the pyramid
          ],
        ),
      ),
    );
  }



  Widget _buildBoardLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Board Structure',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLegendItem(const Color(0xFFFFD700), Icons.star, 'Legend Gold (1)', 'Top position - directly refers and connects to 2 Silvers'),
            _buildLegendItem(const Color(0xFFE6E6FA), Icons.workspace_premium, 'Silver (2)', 'Second level - referred by Legend, each refers 2 Bronze members'),
            _buildLegendItem(const Color(0xFFCD7F32), Icons.emoji_events, 'Bronze (4)', 'Third level - referred by Silver, each refers 2 Starter members'),
            _buildLegendItem(const Color(0xFFDDCC9A), Icons.person, 'Starter (8)', 'Fourth level - entry level referred by Bronze members'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFD700).withValues(alpha: 0.1),
                    Color(0xFFE6E6FA).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFFFD700).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Color(0xFFFFD700), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pyramidal Connection Flow',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '📈 Legend Gold → Silver → Bronze → Starter\\n'
                    '🎯 Each member can refer 2 people directly below them\\n'
                    '💰 Earnings flow upward through the pyramid structure\\n'
                    '🏆 Complete your board to advance to the next level',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your position is highlighted with a border',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetails(Member member) {
    // Get referrer info
    Member? referrer;
    if (member.referredBy != null) {
      final members = StorageService.getMembers();
      referrer = members.cast<Member?>().firstWhere(
        (m) => m?.id == member.referredBy,
        orElse: () => null,
      );
    }
    
    // Get direct referrals
    final members = StorageService.getMembers();
    final directReferrals = members.where((m) => 
      member.directReferrals.contains(m.id)
    ).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getRankIcon(member.rank),
              color: _getRankColor(member.rank),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(member.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Rank', member.rank.name.toUpperCase()),
              _buildDetailItem('Level', member.level.toString()),
              _buildDetailItem('Points', member.points.toString()),
              _buildDetailItem('Join Date', 
                member.joinDate.toString().split(' ')[0]),
              if (referrer != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Referred By',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRankIcon(referrer.rank),
                        color: _getRankColor(referrer.rank),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(referrer.name),
                    ],
                  ),
                ),
              ],
              if (directReferrals.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Direct Referrals (${directReferrals.length})',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...directReferrals.map((ref) => Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRankIcon(ref.rank),
                        color: _getRankColor(ref.rank),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ref.name,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildReferralConnectionsCard(List<Member> referralUsers) {
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
                  Icons.account_tree,
                  color: const Color(0xFFFFD700),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Referral Network Structure',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Legend Gold (Current User) at center
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFD700), const Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: _currentMember!.profilePicture != null
                          ? Image.network(
                              _currentMember!.profilePicture!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  Icon(Icons.person, color: Colors.white, size: 24),
                            )
                          : Icon(Icons.person, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_currentMember!.name} (YOU)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'LEGEND GOLD - Center Position',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
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
            
            const SizedBox(height: 16),
            
            // Show direct referral connections
            Text(
              'Direct Referrals Connected (${referralUsers.length}):',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Grid of referral users with connection indicators
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: referralUsers.length,
              itemBuilder: (context, index) {
                final user = referralUsers[index];
                return _buildReferralUserCard(user, index + 1);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildUserSlot(Member user, int position, MemberRank expectedRank, String title) {
    Color slotColor;
    IconData rankIcon;
    
    switch (expectedRank) {
      case MemberRank.legend:
        slotColor = const Color(0xFFFFD700);
        rankIcon = Icons.star;
        break;
      case MemberRank.silver:
        slotColor = const Color(0xFF4FC3F7); // Light Blue for Silver
        rankIcon = Icons.workspace_premium;
        break;
      case MemberRank.bronze:
        slotColor = const Color(0xFFCD7F32);
        rankIcon = Icons.emoji_events;
        break;
      case MemberRank.starter:
        slotColor = const Color(0xFF66BB6A); // Green for Starter
        rankIcon = Icons.person;
        break;
    }

    return GestureDetector(
      onTap: () => _showMemberDetails(user),
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              slotColor,
              slotColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: slotColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: user.profilePicture != null
                    ? Image.network(
                        user.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            Icon(rankIcon, color: Colors.white, size: 16),
                      )
                    : Icon(rankIcon, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.name.split(' ').first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendGoldSlot(Member user) {
    return GestureDetector(
      onTap: () => _showMemberDetails(user),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFD700),
              const Color(0xFFFFA500),
              const Color(0xFFFF8C00),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: user.profilePicture != null
                    ? Image.network(
                        user.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.star, color: Colors.white, size: 24),
                      )
                    : const Icon(Icons.star, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'YOU',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'LEGEND GOLD',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralUserCard(Member user, int position) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _getRankColor(user.rank), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: user.profilePicture != null
                  ? Image.network(
                      user.profilePicture!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Icon(_getRankIcon(user.rank), color: _getRankColor(user.rank), size: 12),
                    )
                  : Icon(_getRankIcon(user.rank), color: _getRankColor(user.rank), size: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Position $position',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.link,
                  size: 10,
                  color: const Color(0xFFFFD700),
                ),
                const SizedBox(width: 2),
                Text(
                  'Direct',
                  style: TextStyle(
                    fontSize: 8,
                    color: const Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_down,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 2),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(MemberRank rank) {
    switch (rank) {
      case MemberRank.legend:
        return const Color(0xFFFFD700);
      case MemberRank.silver:
        return const Color(0xFFE6E6FA);
      case MemberRank.bronze:
        return const Color(0xFFCD7F32);
      case MemberRank.starter:
        return const Color(0xFFDDCC9A);
    }
  }

  IconData _getRankIcon(MemberRank rank) {
    switch (rank) {
      case MemberRank.legend:
        return Icons.star;
      case MemberRank.silver:
        return Icons.workspace_premium;
      case MemberRank.bronze:
        return Icons.emoji_events;
      case MemberRank.starter:
        return Icons.person;
    }
  }
}

class DepositDialog extends StatefulWidget {
  final int level;
  final Function(String paymentMethod, String? paymentProof, double amount, String accountId, String accountName) onDepositSubmitted;

  const DepositDialog({
    super.key,
    required this.level,
    required this.onDepositSubmitted,
  });

  @override
  State<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<DepositDialog> {
  final _paymentMethodController = TextEditingController();
  final _proofController = TextEditingController();
  final _amountController = TextEditingController();
  final _accountIdController = TextEditingController();
  final _accountNameController = TextEditingController();
  String _selectedMethod = 'Bank Transfer';
  bool _isSubmitting = false;
  File? _proofImage;

  final List<String> _paymentMethods = [
    'Bank Transfer',
    'Cryptocurrency',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _proofImage = File(pickedFile.path);
        _proofController.text = 'Image selected: ${pickedFile.name}';
      });
    }
  }

  Future<void> _submitDeposit() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 1.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount (minimum \$1.00)')),
      );
      return;
    }

    if (_accountIdController.text.isEmpty || _accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide account ID and account name')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      await widget.onDepositSubmitted(
        _selectedMethod,
        _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
        amount,
        _accountIdController.text,
        _accountNameController.text,
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Make Deposit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minimum amount to join: \$1.00',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Amount:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '1.00',
                prefixText: '\$',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Text('Payment Method:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _paymentMethods.map((method) {
                return DropdownMenuItem(value: method, child: Text(method));
              }).toList(),
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            const SizedBox(height: 16),
            Text('Account ID Number:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _accountIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your account ID/number',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            Text('Account Name:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter account holder name',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            Text('Payment Details/Reference (Optional):', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _paymentMethodController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter transaction ID, reference number, etc.',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Text('Payment Proof (Optional):', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proofController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Upload receipt or screenshot',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.attach_file),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your deposit will be reviewed by an administrator before board access is granted.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitDeposit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Submit Deposit'),
        ),
      ],
    );
  }
}

// Enhanced painter for pyramidal connection lines with direct referral visualization
class EnhancedConnectionPainter extends CustomPainter {
  final Color color;
  final int level;
  final bool showDirectReferrals;

  EnhancedConnectionPainter({
    required this.color,
    required this.level,
    this.showDirectReferrals = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (level) {
      case 1: // Legend Gold to Silvers (direct connection)
        final leftSilver = Offset(size.width * 0.25, size.height);
        final rightSilver = Offset(size.width * 0.75, size.height);
        final center = Offset(size.width * 0.5, 0);
        
        // Draw enhanced connection lines with glow effect
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..strokeWidth = 8.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(center, leftSilver, glowPaint);
        canvas.drawLine(center, rightSilver, glowPaint);
        canvas.drawLine(center, leftSilver, paint);
        canvas.drawLine(center, rightSilver, paint);
        
        // Draw directional arrows
        _drawArrow(canvas, center, leftSilver, arrowPaint);
        _drawArrow(canvas, center, rightSilver, arrowPaint);
        
        // Draw enhanced connection dots
        canvas.drawCircle(center, 8, dotPaint);
        canvas.drawCircle(leftSilver, 6, dotPaint);
        canvas.drawCircle(rightSilver, 6, dotPaint);
        
        // Add referral flow indicators
        if (showDirectReferrals) {
          _drawReferralFlow(canvas, center, leftSilver, color);
          _drawReferralFlow(canvas, center, rightSilver, color);
        }
        break;
        
      case 2: // Silvers to Bronze (each Silver connects to 2 Bronze)
        for (int i = 0; i < 4; i++) {
          final bronzePos = Offset(size.width * (0.125 + i * 0.25), size.height);
          final silverPos = Offset(size.width * (0.25 + (i ~/ 2) * 0.5), 0);
          
          // Enhanced connection lines
          final glowPaint = Paint()
            ..color = color.withValues(alpha: 0.3)
            ..strokeWidth = 6.0
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(silverPos, bronzePos, glowPaint);
          canvas.drawLine(silverPos, bronzePos, paint);
          
          // Draw directional arrows
          _drawArrow(canvas, silverPos, bronzePos, arrowPaint);
          
          canvas.drawCircle(bronzePos, 4, dotPaint);
          if (i == 0 || i == 2) canvas.drawCircle(silverPos, 6, dotPaint);
          
          // Add referral flow indicators
          if (showDirectReferrals) {
            _drawReferralFlow(canvas, silverPos, bronzePos, color);
          }
        }
        break;
        
      case 3: // Bronze to Starters (each Bronze connects to 2 Starters)
        for (int i = 0; i < 8; i++) {
          final starterX = size.width * (0.0625 + i * 0.125);
          final starterPos = Offset(starterX, size.height);
          final bronzePos = Offset(size.width * (0.125 + (i ~/ 2) * 0.25), 0);
          
          // Enhanced connection lines
          final glowPaint = Paint()
            ..color = color.withValues(alpha: 0.3)
            ..strokeWidth = 5.0
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(bronzePos, starterPos, glowPaint);
          canvas.drawLine(bronzePos, starterPos, paint);
          
          // Draw directional arrows
          _drawArrow(canvas, bronzePos, starterPos, arrowPaint);
          
          canvas.drawCircle(starterPos, 3, dotPaint);
          if (i % 2 == 0) canvas.drawCircle(bronzePos, 4, dotPaint);
          
          // Add referral flow indicators
          if (showDirectReferrals) {
            _drawReferralFlow(canvas, bronzePos, starterPos, color);
          }
        }
        break;
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final direction = (end - start).direction;
    final arrowLength = 8.0;
    final arrowAngle = 0.5;
    
    final arrowPoint1 = Offset(
      end.dx - arrowLength * math.cos(direction - arrowAngle),
      end.dy - arrowLength * math.sin(direction - arrowAngle),
    );
    
    final arrowPoint2 = Offset(
      end.dx - arrowLength * math.cos(direction + arrowAngle),
      end.dy - arrowLength * math.sin(direction + arrowAngle),
    );
    
    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();
    
    canvas.drawPath(path, paint);
  }

  void _drawReferralFlow(Canvas canvas, Offset start, Offset end, Color color) {
    // Draw animated flow dots along the connection line
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    
    for (int i = 0; i < 3; i++) {
      final position = start + direction * (distance * 0.3 + i * distance * 0.2);
      final flowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(position, 2.0, flowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
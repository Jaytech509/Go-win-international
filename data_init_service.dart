import 'package:uuid/uuid.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/services/mlm_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/models/board.dart';
import 'package:ascendant_reach/models/transaction.dart';
import 'package:ascendant_reach/models/course.dart';
import 'package:ascendant_reach/models/product.dart';

class DataInitService {
  static const _uuid = Uuid();

  static Future<void> initializeSampleData() async {
    try {
      print('🔄 Initializing GO-WIN INTERNATIONAL sample data...');
      
      // Always initialize storage first
      await StorageService.init();
      
      // Check if data already exists
      final existingMembers = StorageService.getMembers();
      if (existingMembers.isNotEmpty) {
        print('✅ Sample data already exists (${existingMembers.length} members)');
        return; // Data already initialized
      }

      // Create sample members
      final sampleMembers = _createSampleMembers();
      await StorageService.saveMembers(sampleMembers);
      print('✅ Created ${sampleMembers.length} sample members');

      // Create sample boards
      final sampleBoards = _createSampleBoards(sampleMembers);
      await StorageService.saveBoards(sampleBoards);
      print('✅ Created ${sampleBoards.length} sample boards');

      // Create sample transactions
      final sampleTransactions = _createSampleTransactions(sampleMembers);
      await StorageService.saveTransactions(sampleTransactions);
      print('✅ Created ${sampleTransactions.length} sample transactions');

      // Create sample courses
      final sampleCourses = _createSampleCourses();
      await StorageService.saveCourses(sampleCourses);
      print('✅ Created ${sampleCourses.length} sample courses');

      // Create sample products
      final sampleProducts = _createSampleProducts();
      await StorageService.saveProducts(sampleProducts);
      print('✅ Created ${sampleProducts.length} sample products');
      
      // Verify data was saved properly
      final verifyMembers = StorageService.getMembers();
      print('✅ Verification: ${verifyMembers.length} members saved successfully');
      
      print('🎆 GO-WIN INTERNATIONAL sample data initialization completed!');
      print('📊 Summary: ${sampleMembers.length} members, ${sampleBoards.length} boards, ${sampleTransactions.length} transactions');
      
    } catch (e) {
      print('❌ Sample data initialization failed: $e');
      throw Exception('Failed to initialize sample data: $e');
    }
  }

  static List<Member> _createSampleMembers() {
    final now = DateTime.now();
    return [
      // Administrator Users
      Member(
        id: 'admin-jaytechpromo',
        name: 'Jay Tech Admin',
        email: 'jaytechpromo@gmail.com',
        phoneNumber: '+1-555-0100',
        referralCode: 'JAYADMIN',
        rank: MemberRank.legend,
        level: 7,
        boardPosition: -1,
        directReferrals: [],
        points: 1000,
        walletBalance: 15000.0,
        joinDate: now.subtract(const Duration(days: 500)),
        isActive: true,
        isAdmin: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 495)),
        profilePicture: 'https://picsum.photos/200/200?random=100',
        earningWallet: 8000.0,
        stars: 7,
      ),
      Member(
        id: 'admin-lubejy09',
        name: 'Lube Admin',
        email: 'lubejy09@gmail.com',
        phoneNumber: '+1-555-0101',
        referralCode: 'LUBEADMIN',
        rank: MemberRank.legend,
        level: 7,
        boardPosition: -1,
        directReferrals: [],
        points: 1000,
        walletBalance: 12000.0,
        joinDate: now.subtract(const Duration(days: 450)),
        isActive: true,
        isAdmin: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 445)),
        profilePicture: 'https://picsum.photos/200/200?random=101',
        earningWallet: 6000.0,
        stars: 7,
      ),
      Member(
        id: 'admin-luberissejames60',
        name: 'Luberisse James',
        email: 'luberissejames60@gmail.com',
        phoneNumber: '+1-555-0102',
        referralCode: 'LUBERISSEADMIN',
        rank: MemberRank.legend,
        level: 7,
        boardPosition: -1,
        directReferrals: [],
        points: 1000,
        walletBalance: 10000.0,
        joinDate: now.subtract(const Duration(days: 400)),
        isActive: true,
        isAdmin: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 395)),
        profilePicture: 'https://picsum.photos/200/200?random=102',
        earningWallet: 5500.0,
        stars: 7,
      ),
      Member(
        id: 'admin-jamesluberisse30',
        name: 'James Luberisse',
        email: 'jamesluberisse30@gmail.com',
        phoneNumber: '+1-555-0103',
        referralCode: 'JAMESADMIN',
        rank: MemberRank.legend,
        level: 7,
        boardPosition: -1,
        directReferrals: [],
        points: 1000,
        walletBalance: 11000.0,
        joinDate: now.subtract(const Duration(days: 420)),
        isActive: true,
        isAdmin: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 415)),
        profilePicture: 'https://picsum.photos/200/200?random=103',
        earningWallet: 5800.0,
        stars: 7,
      ),
      Member(
        id: 'demo-leader-1',
        name: 'John Legend',
        email: 'john.legend@gowin.com',
        phoneNumber: '+1-555-0104',
        referralCode: 'LEGEND01',
        rank: MemberRank.legend,
        level: 5,
        boardPosition: 6,
        boardId: 'board-level-5',
        directReferrals: ['demo-silver-1', 'demo-silver-2'],
        points: 500,
        walletBalance: 2500.0,
        joinDate: now.subtract(const Duration(days: 365)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 360)),
        isAdmin: true,  // Admin user
        profilePicture: 'https://picsum.photos/200/200?random=102',
        earningWallet: 1200.0,
        stars: 5,
      ),
      Member(
        id: 'demo-silver-1',
        name: 'Sarah Silver',
        email: 'sarah.silver@gowin.com',
        phoneNumber: '+1-555-0103',
        referralCode: 'SILVER01',
        referredBy: 'demo-leader-1',
        rank: MemberRank.silver,
        level: 3,
        boardPosition: 0,
        boardId: 'board-level-3',
        directReferrals: ['demo-bronze-1', 'demo-bronze-2'],
        points: 250,
        walletBalance: 1200.0,
        joinDate: now.subtract(const Duration(days: 200)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 195)),
        profilePicture: 'https://picsum.photos/200/200?random=103',
        earningWallet: 450.0,
        stars: 3,
      ),
      Member(
        id: 'demo-silver-2',
        name: 'Mike Silver',
        email: 'mike.silver@gowin.com',
        phoneNumber: '+1-555-0104',
        referralCode: 'SILVER02',
        referredBy: 'demo-leader-1',
        rank: MemberRank.silver,
        level: 3,
        boardPosition: 1,
        boardId: 'board-level-3',
        directReferrals: ['demo-bronze-3', 'demo-bronze-4'],
        points: 300,
        walletBalance: 1500.0,
        joinDate: now.subtract(const Duration(days: 180)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 175)),
        profilePicture: 'https://picsum.photos/200/200?random=104',
        earningWallet: 550.0,
        stars: 3,
      ),
      Member(
        id: 'demo-bronze-1',
        name: 'Anna Bronze',
        email: 'anna.bronze@gowin.com',
        phoneNumber: '+1-555-0105',
        referralCode: 'BRONZE01',
        referredBy: 'demo-silver-1',
        rank: MemberRank.bronze,
        level: 2,
        boardPosition: 2,
        boardId: 'board-level-2',
        directReferrals: ['demo-starter-1', 'demo-starter-2'],
        points: 150,
        walletBalance: 750.0,
        joinDate: now.subtract(const Duration(days: 120)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 115)),
        profilePicture: 'https://picsum.photos/200/200?random=105',
        earningWallet: 125.0,
        stars: 2,
      ),
      Member(
        id: 'demo-bronze-2',
        name: 'David Bronze',
        email: 'david.bronze@gowin.com',
        phoneNumber: '+1-555-0106',
        referralCode: 'BRONZE02',
        referredBy: 'demo-silver-1',
        rank: MemberRank.bronze,
        level: 2,
        boardPosition: 3,
        boardId: 'board-level-2',
        directReferrals: ['demo-starter-3', 'demo-starter-4'],
        points: 180,
        walletBalance: 900.0,
        joinDate: now.subtract(const Duration(days: 100)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 95)),
        profilePicture: 'https://picsum.photos/200/200?random=106',
        earningWallet: 135.0,
        stars: 2,
      ),
      // Additional starter members for better demonstration
      Member(
        id: 'demo-starter-1',
        name: 'Emma Starter',
        email: 'emma.starter@gowin.com',
        phoneNumber: '+1-555-0107',
        referralCode: 'START01',
        referredBy: 'demo-bronze-1',
        rank: MemberRank.starter,
        level: 1,
        boardPosition: 4,
        boardId: 'board-level-1',
        directReferrals: [],
        points: 100,
        walletBalance: 25.0,
        earningWallet: 15.0,
        joinDate: now.subtract(const Duration(days: 60)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 55)),
        profilePicture: 'https://picsum.photos/200/200?random=107',
        stars: 1,
      ),
      Member(
        id: 'demo-starter-2',
        name: 'Ryan Starter',
        email: 'ryan.starter@gowin.com',
        phoneNumber: '+1-555-0108',
        referralCode: 'START02',
        referredBy: 'demo-bronze-2',
        rank: MemberRank.starter,
        level: 1,
        boardPosition: 5,
        boardId: 'board-level-1',
        directReferrals: [],
        points: 120,
        walletBalance: 30.0,
        earningWallet: 20.0,
        joinDate: now.subtract(const Duration(days: 45)),
        isActive: true,
        boardJoinStatus: ApprovalStatus.approved,
        approvalDate: now.subtract(const Duration(days: 40)),
        profilePicture: 'https://picsum.photos/200/200?random=108',
        stars: 1,
      ),
    ];
  }

  static List<MLMBoard> _createSampleBoards(List<Member> members) {
    return [
      MLMBoard(
        id: 'board-level-1',
        level: 1,
        positions: [
          BoardPosition(position: 0, memberId: 'demo-starter-1', memberName: 'Starter One'),
          BoardPosition(position: 1, memberId: 'demo-starter-2', memberName: 'Starter Two'),
          BoardPosition(position: 2, memberId: 'demo-starter-3', memberName: 'Starter Three'),
          BoardPosition(position: 3),
          BoardPosition(position: 4),
          BoardPosition(position: 5),
          BoardPosition(position: 6),
          BoardPosition(position: 7),
          BoardPosition(position: 8),
          BoardPosition(position: 9),
          BoardPosition(position: 10),
          BoardPosition(position: 11),
          BoardPosition(position: 12),
          BoardPosition(position: 13),
        ],
        isComplete: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  static List<Transaction> _createSampleTransactions(List<Member> members) {
    final now = DateTime.now();
    return [
      Transaction(
        id: _uuid.v4(),
        memberId: 'demo-leader-1',
        type: TransactionType.commission,
        amount: 1000.0,
        currency: 'USD',
        status: TransactionStatus.completed,
        description: 'Board completion commission - Level 4',
        createdAt: now.subtract(const Duration(days: 10)),
        completedAt: now.subtract(const Duration(days: 10)),
      ),
      Transaction(
        id: _uuid.v4(),
        memberId: 'demo-silver-1',
        type: TransactionType.referralBonus,
        amount: 100.0,
        currency: 'USD',
        status: TransactionStatus.completed,
        description: 'Referral bonus for new member',
        createdAt: now.subtract(const Duration(days: 5)),
        completedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<Course> _createSampleCourses() {
    return [
      Course(
        id: 'course-1',
        title: 'MLM Fundamentals',
        description: 'Learn the basics of multi-level marketing and network building strategies',
        requiredLevel: 1,
        requiredPoints: 50,
        duration: 45,
        topics: ['MLM Basics', 'Network Building', 'Goal Setting', 'First Steps'],
        imageUrl: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=300&h=200&fit=crop',
        isUnlocked: true,
        progress: 0.0,
      ),
      Course(
        id: 'course-2',
        title: 'Leadership Development',
        description: 'Develop essential leadership skills for managing and motivating your network',
        requiredLevel: 2,
        requiredPoints: 150,
        duration: 60,
        topics: ['Team Leadership', 'Communication', 'Motivation', 'Conflict Resolution'],
        imageUrl: 'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?w=300&h=200&fit=crop',
        isUnlocked: false,
        progress: 0.0,
      ),
    ];
  }

  static List<Product> _createSampleProducts() {
    return [
      Product(
        id: 'product-1',
        name: 'Premium Training Kit',
        description: 'Complete training materials package for new recruits including guides, videos, and certification materials',
        pointsRequired: 50,
        priceInMoney: 25.0,
        category: 'Education',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=200&fit=crop',
        isAvailable: true,
        stock: 25,
        features: ['Training Manual', 'Video Access', 'Certification', 'Support Materials'],
      ),
      Product(
        id: 'product-2',
        name: 'Business Success Book Set',
        description: 'Collection of the most influential business and personal development books',
        pointsRequired: 75,
        priceInMoney: 37.5,
        category: 'Education',
        imageUrl: 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=200&fit=crop',
        isAvailable: true,
        stock: 30,
        features: ['10 Best Sellers', 'Digital Access', 'Study Guide', 'Author Interviews'],
      ),
    ];
  }
}
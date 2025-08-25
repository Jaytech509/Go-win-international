import 'package:flutter/material.dart';
import 'package:ascendant_reach/services/storage_service.dart';
import 'package:ascendant_reach/models/member.dart';
import 'package:ascendant_reach/models/course.dart';
import 'package:ascendant_reach/services/translation_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  Member? _currentMember;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadLearningData();
  }

  void _loadLearningData() {
    setState(() {
      _currentMember = StorageService.getCurrentMember();
      _courses = _getSampleCourses();
    });
  }

  List<Course> _getSampleCourses() {
    if (_currentMember == null) return [];

    return [
      Course(
        id: '1',
        title: 'MLM Fundamentals',
        description: 'Learn the basics of multi-level marketing and network building',
        requiredLevel: 1,
        requiredPoints: 50,
        duration: 45,
        topics: ['MLM Basics', 'Network Building', 'Goal Setting'],
        imageUrl: 'https://picsum.photos/300/200?random=1',
        isUnlocked: _currentMember!.level >= 1 && _currentMember!.points >= 50,
        progress: _currentMember!.level >= 1 ? 0.8 : 0.0,
      ),
      Course(
        id: '2',
        title: 'Leadership Development',
        description: 'Develop essential leadership skills for your network',
        requiredLevel: 2,
        requiredPoints: 150,
        duration: 60,
        topics: ['Team Leadership', 'Communication', 'Motivation'],
        imageUrl: 'https://picsum.photos/300/200?random=2',
        isUnlocked: _currentMember!.level >= 2 && _currentMember!.points >= 150,
        progress: _currentMember!.level >= 2 ? 0.6 : 0.0,
      ),
      Course(
        id: '3',
        title: 'Advanced Recruitment',
        description: 'Master advanced techniques for recruiting and retention',
        requiredLevel: 3,
        requiredPoints: 300,
        duration: 90,
        topics: ['Recruitment Strategies', 'Retention Techniques', 'Team Building'],
        imageUrl: 'https://picsum.photos/300/200?random=3',
        isUnlocked: _currentMember!.level >= 3 && _currentMember!.points >= 300,
        progress: _currentMember!.level >= 3 ? 0.4 : 0.0,
      ),
      Course(
        id: '4',
        title: 'Digital Marketing Mastery',
        description: 'Leverage digital platforms to grow your network',
        requiredLevel: 4,
        requiredPoints: 500,
        duration: 120,
        topics: ['Social Media Marketing', 'Content Creation', 'Online Branding'],
        imageUrl: 'https://picsum.photos/300/200?random=4',
        isUnlocked: _currentMember!.level >= 4 && _currentMember!.points >= 500,
        progress: _currentMember!.level >= 4 ? 0.2 : 0.0,
      ),
      Course(
        id: '5',
        title: 'Financial Planning',
        description: 'Manage your MLM income and plan for the future',
        requiredLevel: 5,
        requiredPoints: 750,
        duration: 75,
        topics: ['Income Management', 'Investment Strategies', 'Tax Planning'],
        imageUrl: 'https://picsum.photos/300/200?random=5',
        isUnlocked: _currentMember!.level >= 5 && _currentMember!.points >= 750,
        progress: _currentMember!.level >= 5 ? 0.1 : 0.0,
      ),
      Course(
        id: 'visa_master',
        title: 'Visa & MasterCard Formation',
        description: 'Learn how to effectively use credit cards for business growth',
        requiredLevel: 3,
        requiredPoints: 350,
        duration: 60,
        topics: ['Card Benefits', 'Cashback Strategies', 'Credit Building', 'International Payments'],
        imageUrl: 'https://picsum.photos/300/200?random=8',
        isUnlocked: _currentMember!.level >= 3 && _currentMember!.points >= 350,
        progress: _currentMember!.level >= 3 ? 0.3 : 0.0,
      ),
      Course(
        id: 'bank_international',
        title: 'Bank Account International Formation',
        description: 'Master international banking for global business operations',
        requiredLevel: 4,
        requiredPoints: 600,
        duration: 90,
        topics: ['International Banking', 'Foreign Exchange', 'Wire Transfers', 'Offshore Accounts'],
        imageUrl: 'https://picsum.photos/300/200?random=9',
        isUnlocked: _currentMember!.level >= 4 && _currentMember!.points >= 600,
        progress: _currentMember!.level >= 4 ? 0.2 : 0.0,
      ),
      Course(
        id: 'social_media',
        title: 'Monetization Social Media Formation',
        description: 'Learn to monetize your social media presence effectively',
        requiredLevel: 2,
        requiredPoints: 200,
        duration: 75,
        topics: ['Content Strategy', 'Influencer Marketing', 'Ad Revenue', 'Sponsored Posts'],
        imageUrl: 'https://picsum.photos/300/200?random=10',
        isUnlocked: _currentMember!.level >= 2 && _currentMember!.points >= 200,
        progress: _currentMember!.level >= 2 ? 0.5 : 0.0,
      ),
      Course(
        id: 'shop_online',
        title: 'Shop Online Formation',
        description: 'Master e-commerce and online retail strategies',
        requiredLevel: 3,
        requiredPoints: 400,
        duration: 80,
        topics: ['E-commerce Setup', 'Online Marketing', 'Payment Processing', 'Customer Service'],
        imageUrl: 'https://picsum.photos/300/200?random=11',
        isUnlocked: _currentMember!.level >= 3 && _currentMember!.points >= 400,
        progress: _currentMember!.level >= 3 ? 0.4 : 0.0,
      ),
      Course(
        id: 'cryptocurrency',
        title: 'Cryptocurrency Formation',
        description: 'Understanding and leveraging cryptocurrency for business',
        requiredLevel: 5,
        requiredPoints: 800,
        duration: 100,
        topics: ['Crypto Basics', 'Trading Strategies', 'DeFi', 'Blockchain Technology'],
        imageUrl: 'https://picsum.photos/300/200?random=12',
        isUnlocked: _currentMember!.level >= 5 && _currentMember!.points >= 800,
        progress: _currentMember!.level >= 5 ? 0.1 : 0.0,
      ),
      Course(
        id: '6',
        title: 'Global Expansion',
        description: 'Scale your network internationally',
        requiredLevel: 6,
        requiredPoints: 1000,
        duration: 100,
        topics: ['International Markets', 'Cultural Awareness', 'Global Strategies'],
        imageUrl: 'https://picsum.photos/300/200?random=6',
        isUnlocked: _currentMember!.level >= 6 && _currentMember!.points >= 1000,
        progress: 0.0,
      ),
      Course(
        id: '7',
        title: 'Master Trainer Program',
        description: 'Become a certified trainer and mentor',
        requiredLevel: 7,
        requiredPoints: 1200,
        duration: 150,
        topics: ['Training Design', 'Mentorship', 'Certification Process'],
        imageUrl: 'https://picsum.photos/300/200?random=7',
        isUnlocked: _currentMember!.level >= 7 && _currentMember!.points >= 1200,
        progress: 0.0,
      ),
    ];
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
        title: Text(TranslationService.translate('learning')),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(child: _buildCourseList()),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    final unlockedCourses = _courses.where((c) => c.isUnlocked).length;
    final completedCourses = _courses.where((c) => c.isCompleted).length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TranslationService.translate('course_progress'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${TranslationService.translate('level')} ${_currentMember!.level} - ${TranslationService.translate('access_by_points_and_levels')}!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildProgressStat(
                    TranslationService.translate('module_unlocked'),
                    '$unlockedCourses/${_courses.length}',
                    unlockedCourses / _courses.length,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProgressStat(
                    TranslationService.translate('course_completed'),
                    '$completedCourses/${_courses.length}',
                    completedCourses / _courses.length,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, double progress, Color color) {
    return Column(
      children: [
        CircularProgressIndicator(
          value: progress,
          backgroundColor: color.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation(color),
          strokeWidth: 6,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCourseList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _courses.length,
      itemBuilder: (context, index) => _buildCourseCard(_courses[index]),
    );
  }

  Widget _buildCourseCard(Course course) {
    final isLocked = !course.isUnlocked;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: isLocked ? null : () => _openCourse(course),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isLocked 
                          ? Colors.grey[300]
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: isLocked
                        ? Icon(
                            Icons.lock,
                            color: Colors.grey[600],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              course.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.school,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                course.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isLocked 
                                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                                      : null,
                                ),
                              ),
                            ),
                            if (isLocked)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      TranslationService.translate('module_locked'),
                                      style: const TextStyle(fontSize: 9, color: Colors.red, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${TranslationService.translate('level')} ${course.requiredLevel}',
                                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                                  ),
                                  Text(
                                    '${course.requiredPoints} ${TranslationService.translate('points').toLowerCase()}',
                                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                                  ),
                                ],
                              )
                            else if (course.isCompleted)
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isLocked 
                                ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: isLocked 
                                  ? Colors.grey[400]
                                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${course.duration} ${TranslationService.translate('minutes')}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isLocked 
                                    ? Colors.grey[400]
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            if (isLocked) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.red.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                TranslationService.translate('insufficient_points'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLocked && course.progress > 0) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${(course.progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: course.progress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: course.topics.map((topic) => Chip(
                  label: Text(
                    topic,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: isLocked 
                      ? Colors.grey[200]
                      : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.6),
                  labelStyle: TextStyle(
                    color: isLocked 
                        ? Colors.grey[600]
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCourse(Course course) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.description),
            const SizedBox(height: 16),
            Text(
              TranslationService.translate('topics_covered'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...course.topics.map((topic) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(topic),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Text(
              '${TranslationService.translate('duration')}: ${course.duration} ${TranslationService.translate('minutes')},',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(TranslationService.translate('close')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Course started! (Demo mode)')),
              );
            },
            child: Text(course.progress > 0 ? TranslationService.translate('continue_course') : TranslationService.translate('start_course')),
          ),
        ],
      ),
    );
  }
}
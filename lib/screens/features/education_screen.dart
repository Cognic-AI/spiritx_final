import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _techniques = [
    {
      'id': '1',
      'title': 'Perfect Cricket Bowling Technique',
      'sport': 'Cricket',
      'level': 'Intermediate',
      'description':
          'Learn the perfect bowling technique for cricket, including grip, run-up, and release.',
      'image': 'cricket_bowling.jpg',
    },
    {
      'id': '2',
      'title': 'Football Free Kick Mastery',
      'sport': 'Football',
      'level': 'Advanced',
      'description':
          'Master the art of taking free kicks in football with proper technique and practice.',
      'image': 'football_freekick.jpg',
    },
    {
      'id': '3',
      'title': 'Swimming Freestyle Technique',
      'sport': 'Swimming',
      'level': 'Beginner',
      'description':
          'Learn the proper freestyle swimming technique for efficiency and speed in the water.',
      'image': 'swimming_freestyle.jpg',
    },
  ];

  final List<Map<String, dynamic>> _science = [
    {
      'id': '1',
      'title': 'The Physics of Cricket Ball Swing',
      'category': 'Physics',
      'description': '1',
    },
    {
      'id': '2',
      'title': 'Muscle Recovery and Growth in Sports',
      'category': 'Biology',
      'description':
          'Learn about the biological processes of muscle recovery and growth after training, and how to optimize these processes.',
    },
    {
      'id': '3',
      'title': 'Nutrition Science for Athletes',
      'category': 'Nutrition',
      'description':
          'Explore the science of nutrition for athletes, including macronutrients, micronutrients, and timing of meals for optimal performance.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Education'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Techniques'),
            Tab(text: 'Science'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTechniquesTab(),
          _buildScienceTab(),
        ],
      ),
    );
  }

  Widget _buildTechniquesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _techniques.length,
      itemBuilder: (context, index) {
        final technique = _techniques[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              _navigateToTechniqueDetail(technique);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Technique image
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(
                    _getSportIcon(technique['sport']),
                    size: 64,
                    color: Colors.grey[600],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sport and level
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              technique['sport'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getLevelColor(technique['level']),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              technique['level'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title
                      Text(
                        technique['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        technique['description'],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Learn more button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _navigateToTechniqueDetail(technique);
                          },
                          child: const Text('Learn More'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScienceTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _science.length,
      itemBuilder: (context, index) {
        final science = _science[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              _navigateToScienceDetail(science);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(science['category']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      science['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    science['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    science['description'],
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Read more button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToScienceDetail(science);
                      },
                      child: const Text('Read Article'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToTechniqueDetail(Map<String, dynamic> technique) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechniqueDetailScreen(technique: technique),
      ),
    );
  }

  void _navigateToScienceDetail(Map<String, dynamic> science) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScienceDetailScreen(science: science),
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'swimming':
        return Icons.pool;
      case 'running':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'physics':
        return Colors.blue;
      case 'biology':
        return Colors.green;
      case 'nutrition':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}

class TechniqueDetailScreen extends StatelessWidget {
  final Map<String, dynamic> technique;

  const TechniqueDetailScreen({
    super.key,
    required this.technique,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(technique['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technique image
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(
                _getSportIcon(technique['sport']),
                size: 64,
                color: Colors.grey[600],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport and level
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          technique['sport'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getLevelColor(technique['level']),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          technique['level'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    technique['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    technique['description'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detailed content (sample)
                  const Text(
                    'Step-by-Step Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildStep(1, 'Preparation',
                      'Start with the proper stance and grip. Make sure your body is aligned correctly.'),
                  _buildStep(2, 'Execution',
                      'Execute the technique with proper form, focusing on the key movements.'),
                  _buildStep(3, 'Follow Through',
                      'Complete the motion with a proper follow-through to maximize effectiveness.'),
                  _buildStep(4, 'Practice',
                      'Repeat the technique regularly to build muscle memory and improve performance.'),

                  const SizedBox(height: 24),

                  // Video section (placeholder)
                  const Text(
                    'Video Tutorial',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Science behind section
                  const Text(
                    'The Science Behind',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Understanding the physics and biomechanics behind this technique can help you master it more effectively. The movement involves specific muscle groups and leverages physical principles to achieve optimal results.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () {
                      // Navigate to science article
                    },
                    child: const Text('Read More About The Science'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'swimming':
        return Icons.pool;
      case 'running':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class ScienceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> science;

  const ScienceDetailScreen({
    Key? key,
    required this.science,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(science['title']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getCategoryColor(science['category']),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                science['category'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              science['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Author and date
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dr. Sports Science • April 15, 2023',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Article content (sample)
            const Text(
              'Introduction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              science['description'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            const Text(
              'This article explores the scientific principles behind sports performance and how understanding these principles can help athletes improve their skills and achieve better results.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Main content sections
            const Text(
              'Key Principles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'The scientific principles that govern sports performance are based on physics, biology, and biomechanics. Understanding these principles allows athletes to optimize their technique and training methods.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Illustration (placeholder)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  _getCategoryIcon(science['category']),
                  size: 64,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Figure 1: Illustration of the scientific principle in action',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Practical Applications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Athletes can apply these scientific principles in their training and competition to improve performance. Here are some practical applications:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            _buildBulletPoint(
                'Adjust technique based on scientific principles'),
            _buildBulletPoint('Optimize training methods for better results'),
            _buildBulletPoint(
                'Use technology to measure and analyze performance'),
            _buildBulletPoint('Apply scientific knowledge to prevent injuries'),

            const SizedBox(height: 24),

            // Conclusion
            const Text(
              'Conclusion',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Understanding the science behind sports can significantly improve performance and help athletes reach their full potential. By applying scientific principles to training and technique, athletes can gain a competitive edge and achieve better results.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // References
            const Text(
              'References',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildReference(
                'Smith, J. (2022). The Science of Sports Performance. Sports Science Journal, 45(2), 112-125.'),
            _buildReference(
                'Johnson, A. & Williams, B. (2021). Biomechanics in Athletic Performance. Sports Medicine, 33(4), 78-92.'),
            _buildReference(
                'Brown, C. (2023). Physics Principles in Sports. International Journal of Sports Science, 12(1), 45-58.'),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildReference(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'physics':
        return Icons.science;
      case 'biology':
        return Icons.biotech;
      case 'nutrition':
        return Icons.restaurant;
      default:
        return Icons.book;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'physics':
        return Colors.blue;
      case 'biology':
        return Colors.green;
      case 'nutrition':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
}

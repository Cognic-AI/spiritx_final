import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/education_model.dart';
import 'package:sri_lanka_sports_app/repositories/education_repository.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EducationRepository _educationRepository = EducationRepository();

  bool _isLoading = true;
  List<EducationModel> _techniques = [];
  List<EducationModel> _scienceArticles = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEducationalContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEducationalContent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load techniques and science articles
      final techniques = await _educationRepository.getTechniques();
      final scienceArticles = await _educationRepository.getScienceArticles();

      setState(() {
        _techniques = techniques;
        _scienceArticles = scienceArticles;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading educational content: $e');
      setState(() {
        _errorMessage = 'Failed to load content. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sports Education'),
        bottom: TabBar(
          unselectedLabelColor: Colors.black,
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Techniques'),
            Tab(text: 'Science'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search dialog
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEducationalContent,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTechniquesTab(),
                    _buildScienceTab(),
                  ],
                ),
    );
  }

  Widget _buildTechniquesTab() {
    if (_techniques.isEmpty) {
      return const Center(
        child: Text('No techniques available'),
      );
    }

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
                if (technique.imageUrl != null)
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Image.network(
                      technique.imageUrl!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(
                            _getSportIcon(technique.sport ?? ''),
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(
                      _getSportIcon(technique.sport ?? ''),
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
                          if (technique.sport != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                technique.sport!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (technique.sport != null) const SizedBox(width: 8),
                          if (technique.level != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getLevelColor(technique.level!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                technique.level!,
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
                        technique.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        technique.description,
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
    if (_scienceArticles.isEmpty) {
      return const Center(
        child: Text('No science articles available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _scienceArticles.length,
      itemBuilder: (context, index) {
        final science = _scienceArticles[index];
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
                  if (science.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(science.category!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        science.category!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    science.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    science.description,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Author and date
                  if (science.author != null || science.publishDate != null)
                    Row(
                      children: [
                        if (science.author != null)
                          Text(
                            science.author!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        if (science.author != null &&
                            science.publishDate != null)
                          Text(
                            ' • ',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        if (science.publishDate != null)
                          Text(
                            _formatDate(science.publishDate!),
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
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

  void _navigateToTechniqueDetail(EducationModel technique) {
    // Track content view
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      _educationRepository.trackContentView(
          technique.id, authService.currentUser!.uid);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TechniqueDetailScreen(technique: technique),
      ),
    );
  }

  void _navigateToScienceDetail(EducationModel science) {
    // Track content view
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.currentUser != null) {
      _educationRepository.trackContentView(
          science.id, authService.currentUser!.uid);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScienceDetailScreen(science: science),
      ),
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Educational Content'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Enter search term',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              Navigator.pop(context);
              if (value.isNotEmpty) {
                _searchEducationalContent(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (searchController.text.isNotEmpty) {
                  _searchEducationalContent(searchController.text);
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchEducationalContent(String query) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final results =
          await _educationRepository.searchEducationalContent(query);

      // Split results into techniques and science articles
      final techniques =
          results.where((item) => item.type == 'technique').toList();
      final scienceArticles =
          results.where((item) => item.type == 'science').toList();

      setState(() {
        _techniques = techniques;
        _scienceArticles = scienceArticles;
        _isLoading = false;
      });

      // Show search results message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${results.length} results for "$query"'),
        ),
      );
    } catch (e) {
      print('Error searching educational content: $e');
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error searching content. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class TechniqueDetailScreen extends StatelessWidget {
  final EducationModel technique;

  const TechniqueDetailScreen({
    super.key,
    required this.technique,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(technique.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Technique image
            if (technique.imageUrl != null)
              Image.network(
                technique.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Icon(
                      _getSportIcon(technique.sport ?? ''),
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  );
                },
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: Icon(
                  _getSportIcon(technique.sport ?? ''),
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
                      if (technique.sport != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            technique.sport!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (technique.sport != null && technique.level != null)
                        const SizedBox(width: 8),
                      if (technique.level != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getLevelColor(technique.level!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            technique.level!,
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
                    technique.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    technique.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detailed content
                  if (technique.content != null)
                    Text(
                      technique.content!,
                      style: const TextStyle(fontSize: 16),
                    ),

                  // Steps
                  if (technique.steps != null &&
                      technique.steps!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Step-by-Step Guide',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...technique.steps!.map((step) => _buildStep(step)),
                  ],

                  // Video
                  if (technique.videoUrl != null) ...[
                    const SizedBox(height: 24),
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
                    const SizedBox(height: 8),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play Video'),
                        onPressed: () {
                          // Play video
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(StepModel step) {
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
                step.number.toString(),
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
                  step.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: const TextStyle(fontSize: 16),
                ),
                if (step.imageUrl != null) ...[
                  const SizedBox(height: 8),
                  Image.network(
                    step.imageUrl!,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported),
                        ),
                      );
                    },
                  ),
                ],
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
  final EducationModel science;

  const ScienceDetailScreen({
    super.key,
    required this.science,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(science.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            if (science.category != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(science.category!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  science.category!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Title
            Text(
              science.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Author and date
            Row(
              children: [
                CircleAvatar(
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
                  science.author != null
                      ? '${science.author} • ${_formatDate(science.publishDate ?? DateTime.now())}'
                      : _formatDate(science.publishDate ?? DateTime.now()),
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Image for science article
            if (science.imageUrl != null)
              Image.network(
                science.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),

            // Content
            if (science.content != null)
              Text(
                science.content!,
                style: const TextStyle(fontSize: 16),
              )
            else
              Text(
                science.description,
                style: const TextStyle(fontSize: 16),
              ),

            // Tags
            if (science.tags != null && science.tags!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: science.tags!.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey[200],
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

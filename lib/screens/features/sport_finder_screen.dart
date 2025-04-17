import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/sport_model.dart';
import 'package:sri_lanka_sports_app/repositories/sport_repository.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';

class SportFinderScreen extends StatefulWidget {
  const SportFinderScreen({super.key});

  @override
  State<SportFinderScreen> createState() => _SportFinderScreenState();
}

class _SportFinderScreenState extends State<SportFinderScreen> {
  final _formKey = GlobalKey<FormState>();
  final SportRepository _sportRepository = SportRepository();

  // Questionnaire responses
  int _height = 170;
  int _weight = 65;
  int _age = 25;
  String _gender = 'Male';
  int _fitnessLevel = 3;
  int _teamPreference = 3;
  int _competitiveness = 3;
  final List<String> _selectedInterests = [];

  bool _isLoading = false;
  List<SportRecommendation>? _recommendedSports;

  final List<String> _interests = [
    'Running',
    'Swimming',
    'Jumping',
    'Throwing',
    'Strength',
    'Endurance',
    'Flexibility',
    'Balance',
    'Hand-eye coordination',
    'Teamwork',
    'Strategy',
    'Contact sports',
    'Outdoor activities',
    'Indoor activities',
  ];

  Future<void> _findSports() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid ?? 'anonymous';

      final recommendations = await _sportRepository.getRecommendations(
        height: _height,
        weight: _weight,
        age: _age,
        gender: _gender,
        fitnessLevel: _fitnessLevel,
        teamPreference: _teamPreference,
        competitiveness: _competitiveness,
        interests: _selectedInterests,
        userId: userId,
      );

      setState(() {
        _recommendedSports = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Sport'),
      ),
      body: SafeArea(
        child: _recommendedSports != null
            ? _buildResultsView()
            : _buildQuestionnaireView(),
      ),
    );
  }

  Widget _buildQuestionnaireView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Let\'s find the perfect sport for you!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Answer these questions to help us recommend sports that match your physical attributes and preferences.',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),

            // Physical attributes
            const Text(
              'Physical Attributes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Height
            Row(
              children: [
                const Text('Height (cm):'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _height.toDouble(),
                    min: 120,
                    max: 220,
                    divisions: 100,
                    label: _height.toString(),
                    onChanged: (value) {
                      setState(() {
                        _height = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    _height.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Weight
            Row(
              children: [
                const Text('Weight (kg):'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _weight.toDouble(),
                    min: 30,
                    max: 150,
                    divisions: 120,
                    label: _weight.toString(),
                    onChanged: (value) {
                      setState(() {
                        _weight = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    _weight.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Age
            Row(
              children: [
                const Text('Age:'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _age.toDouble(),
                    min: 5,
                    max: 80,
                    divisions: 75,
                    label: _age.toString(),
                    onChanged: (value) {
                      setState(() {
                        _age = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    _age.toString(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Gender
            Row(
              children: [
                const Text('Gender:'),
                const SizedBox(width: 16),
                Radio<String>(
                  value: 'Male',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const Text('Male'),
                const SizedBox(width: 16),
                Radio<String>(
                  value: 'Female',
                  groupValue: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const Text('Female'),
              ],
            ),
            const SizedBox(height: 24),

            // Preferences
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Fitness level
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fitness Level:'),
                const SizedBox(height: 8),
                Slider(
                  value: _fitnessLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _fitnessLevel.toString(),
                  onChanged: (value) {
                    setState(() {
                      _fitnessLevel = value.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Beginner'),
                    Text('Advanced'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Team preference
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Team vs Individual:'),
                const SizedBox(height: 8),
                Slider(
                  value: _teamPreference.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _teamPreference.toString(),
                  onChanged: (value) {
                    setState(() {
                      _teamPreference = value.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Individual'),
                    Text('Team'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Competitiveness
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Competitiveness:'),
                const SizedBox(height: 8),
                Slider(
                  value: _competitiveness.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _competitiveness.toString(),
                  onChanged: (value) {
                    setState(() {
                      _competitiveness = value.round();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Recreational'),
                    Text('Competitive'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Interests
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Interests and Skills:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(interest);
                          } else {
                            _selectedInterests.remove(interest);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit button
            CustomButton(
              text: 'Find My Sport',
              isLoading: _isLoading,
              onPressed: _findSports,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor,
          child: Column(
            children: [
              const Text(
                'Your Recommended Sports',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Based on your physical attributes and preferences',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recommendedSports!.length,
            itemBuilder: (context, index) {
              final recommendation = _recommendedSports![index];
              final sport = recommendation.sport;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getSportIcon(sport.name),
                              size: 32,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sport.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${recommendation.matchPercentage}% Match',
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        sport.description,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Key Skills:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: sport.skills.map((skill) {
                          return Chip(
                            label: Text(skill),
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Learn More',
                        onPressed: () {
                          // Navigate to sport details
                          _navigateToSportDetails(sport);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: 'Start Over',
            onPressed: () {
              setState(() {
                _recommendedSports = null;
              });
            },
          ),
        ),
      ],
    );
  }

  void _navigateToSportDetails(SportModel sport) {
    // Navigate to sport details screen
    // This would be implemented in a real app
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SportDetailScreen(sport: sport),
      ),
    );
  }

  IconData _getSportIcon(String sportName) {
    switch (sportName.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'swimming':
        return Icons.pool;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'running':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }
}

// Sport Detail Screen
class SportDetailScreen extends StatelessWidget {
  final SportModel sport;

  const SportDetailScreen({
    super.key,
    required this.sport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sport.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sport image
            if (sport.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  sport.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(
                        _getSportIcon(sport.name),
                        size: 64,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSportIcon(sport.name),
                  size: 64,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 16),

            // Sport name
            Text(
              sport.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              sport.description,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Skills section
            const Text(
              'Key Skills',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Skills list
            ...sport.skills.map((skill) => _buildSkillItem(skill)),

            const SizedBox(height: 24),

            // Attributes section
            if (sport.attributes != null) ...[
              const Text(
                'Attributes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Attributes list
              ...sport.attributes!.entries.map(
                (entry) =>
                    _buildAttributeItem(entry.key, entry.value.toString()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkillItem(String skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            skill,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            '$key: $value',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSportIcon(String sportName) {
    switch (sportName.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'swimming':
        return Icons.pool;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'running':
        return Icons.directions_run;
      default:
        return Icons.sports;
    }
  }
}

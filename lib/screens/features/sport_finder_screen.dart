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
  int _height = 60;  // Make sure it's not null
  int _weight = 65;
  int _age = 25;
  String _gender = 'Male';
  int _fitnessLevel = 3;
  int _teamPreference = 3;
  int _competitiveness = 3;
  final List<String> _selectedInterests = [];

  bool _isLoading = false;
  List<SportRecommendation>? _recommendedSports;

  final List<Map<String, dynamic>> _questions = [
  // Endurance
  {'section': 'Endurance', 'label': 'How long can you jog continuously without rest? (minutes)', 'key': 'jog_duration', 'min': 5, 'max': 120, 'default': 60, 'weight': 0.25},
  {'section': 'Endurance', 'label': 'How many kilometers can you run in one go? (km)', 'key': 'run_distance', 'min': 1, 'max': 25, 'default': 10, 'weight': 0.20},
  {'section': 'Endurance', 'label': 'How long can you sustain moderate cycling? (minutes)', 'key': 'cycling_duration', 'min': 10, 'max': 180, 'default': 60, 'weight': 0.20},
  {'section': 'Endurance', 'label': 'How many laps can you swim without resting? (laps)', 'key': 'swim_laps', 'min': 1, 'max': 40, 'default': 10, 'weight': 0.15},
  {'section': 'Endurance', 'label': 'How quickly do you recover after long cardio? (minutes)', 'key': 'cardio_recovery', 'min': 2, 'max': 30, 'default': 10, 'weight': 0.20},

  // Strength
  {'section': 'Strength', 'label': 'How many push-ups can you do in one minute? (count)', 'key': 'pushups', 'min': 5, 'max': 60, 'default': 30, 'weight': 0.20},
  {'section': 'Strength', 'label': 'What is your deadlift compared to body weight? (ratio ×100)', 'key': 'deadlift_ratio', 'min': 50, 'max': 250, 'default': 125, 'weight': 0.25},
  {'section': 'Strength', 'label': 'How many squats can you do in one minute? (count)', 'key': 'squats', 'min': 10, 'max': 70, 'default': 30, 'weight': 0.20},
  {'section': 'Strength', 'label': 'How much weight can you press overhead with one arm? (kg)', 'key': 'overhead_press', 'min': 5, 'max': 50, 'default': 20, 'weight': 0.15},
  {'section': 'Strength', 'label': 'How long can you hold a plank? (seconds)', 'key': 'plank_hold', 'min': 10, 'max': 300, 'default': 120, 'weight': 0.20},

  // Power
  {'section': 'Power', 'label': 'What is your standing vertical jump? (cm)', 'key': 'vertical_jump', 'min': 10, 'max': 80, 'default': 40, 'weight': 0.30},
  {'section': 'Power', 'label': 'What is your standing long jump? (cm)', 'key': 'long_jump', 'min': 100, 'max': 300, 'default': 180, 'weight': 0.20},
  {'section': 'Power', 'label': 'How fast can you throw a 3kg medicine ball? (m/s)', 'key': 'ball_throw_speed', 'min': 5, 'max': 20, 'default': 10, 'weight': 0.20},
  {'section': 'Power', 'label': 'How many clap push-ups can you do in a row? (count)', 'key': 'clap_pushups', 'min': 1, 'max': 25, 'default': 10, 'weight': 0.15},
  {'section': 'Power', 'label': 'How high can you jump from a squat position? (cm)', 'key': 'squat_jump', 'min': 10, 'max': 60, 'default': 30, 'weight': 0.15},

  // Speed
  {'section': 'Speed', 'label': 'What is your 40m sprint time? (seconds)', 'key': 'sprint_40m', 'min': 4, 'max': 10, 'default': 7, 'weight': 0.30},
  {'section': 'Speed', 'label': 'How fast can you run 100m? (seconds)', 'key': 'sprint_100m', 'min': 10, 'max': 20, 'default': 15, 'weight': 0.25},
  {'section': 'Speed', 'label': 'How fast is your shuttle run (5×10m)? (seconds)', 'key': 'shuttle_run', 'min': 8, 'max': 20, 'default': 14, 'weight': 0.20},
  {'section': 'Speed', 'label': 'How quick are your reaction times? (ms)', 'key': 'reaction_time', 'min': 150, 'max': 400, 'default': 250, 'weight': 0.15},
  {'section': 'Speed', 'label': 'How many cone touches can you do in 20 seconds? (count)', 'key': 'cone_touches', 'min': 5, 'max': 25, 'default': 12, 'weight': 0.10},

  // Agility
  {'section': 'Agility', 'label': 'How quickly can you complete an agility ladder? (seconds)', 'key': 'ladder_time', 'min': 5, 'max': 20, 'default': 10, 'weight': 0.25},
  {'section': 'Agility', 'label': 'How fast can you zig-zag through cones? (seconds)', 'key': 'zigzag_cones', 'min': 6, 'max': 20, 'default': 12, 'weight': 0.25},
  {'section': 'Agility', 'label': 'How many direction changes in 30 seconds? (count)', 'key': 'direction_changes', 'min': 5, 'max': 30, 'default': 15, 'weight': 0.20},
  {'section': 'Agility', 'label': 'How fast can you perform T-test drill? (seconds)', 'key': 't_test_time', 'min': 6, 'max': 14, 'default': 10, 'weight': 0.20},
  {'section': 'Agility', 'label': 'How long to complete a figure-8 drill? (seconds)', 'key': 'figure8_time', 'min': 5, 'max': 20, 'default': 12, 'weight': 0.10},

  // Flexibility
  {'section': 'Flexibility', 'label': 'How far can you reach past your toes? (cm)', 'key': 'toe_reach', 'min': -10, 'max': 30, 'default': 5, 'weight': 0.25},
  {'section': 'Flexibility', 'label': 'What is your shoulder flexibility range? (cm)', 'key': 'shoulder_reach', 'min': 10, 'max': 50, 'default': 30, 'weight': 0.20},
  {'section': 'Flexibility', 'label': 'How far can you spread your legs (split)? (degrees)', 'key': 'leg_split', 'min': 30, 'max': 180, 'default': 90, 'weight': 0.20},
  {'section': 'Flexibility', 'label': 'Can you touch the ground with straight legs? (cm)', 'key': 'forward_bend', 'min': -20, 'max': 20, 'default': 0, 'weight': 0.20},
  {'section': 'Flexibility', 'label': 'How flexible is your spine when bending back? (degrees)', 'key': 'spine_bend', 'min': 10, 'max': 60, 'default': 30, 'weight': 0.15},

  // Nervous System
  {'section': 'Nervous system requirements', 'label': 'What is your average reaction time on a click test? (ms)', 'key': 'click_reaction', 'min': 150, 'max': 350, 'default': 220, 'weight': 0.30},
  {'section': 'Nervous system requirements', 'label': 'How many quick taps can you do in 10 seconds? (count)', 'key': 'taps_10s', 'min': 20, 'max': 80, 'default': 40, 'weight': 0.25},
  {'section': 'Nervous system requirements', 'label': 'How fast can you identify changing colors? (corrects/30s)', 'key': 'color_response', 'min': 5, 'max': 20, 'default': 10, 'weight': 0.20},
  {'section': 'Nervous system requirements', 'label': 'How accurate is your hand-eye coordination? (% correct)', 'key': 'coordination', 'min': 50, 'max': 100, 'default': 75, 'weight': 0.15},
  {'section': 'Nervous system requirements', 'label': 'How fast can you repeat a pattern sequence? (seconds)', 'key': 'pattern_time', 'min': 5, 'max': 25, 'default': 12, 'weight': 0.10},

  // Durability
  {'section': 'Durability', 'label': 'How often do you get injured during training? (times/year)', 'key': 'injuries', 'min': 0, 'max': 10, 'default': 2, 'weight': 0.25},
  {'section': 'Durability', 'label': 'How long does it take you to recover from strain? (days)', 'key': 'strain_recovery', 'min': 1, 'max': 14, 'default': 5, 'weight': 0.25},
  {'section': 'Durability', 'label': 'How often can you train intensely per week? (sessions)', 'key': 'intense_sessions', 'min': 1, 'max': 14, 'default': 5, 'weight': 0.20},
  {'section': 'Durability', 'label': 'How many rest days do you need weekly? (days)', 'key': 'rest_days', 'min': 0, 'max': 7, 'default': 2, 'weight': 0.20},
  {'section': 'Durability', 'label': 'How long can you keep up hard training? (weeks)', 'key': 'training_streak', 'min': 1, 'max': 16, 'default': 8, 'weight': 0.10},

  // Handling
  {'section': 'Handling', 'label': 'How well do you control a ball with your foot? (1–10)', 'key': 'foot_control', 'min': 1, 'max': 10, 'default': 5, 'weight': 0.25},
  {'section': 'Handling', 'label': 'How well do you control a ball with your hands? (1–10)', 'key': 'hand_control', 'min': 1, 'max': 10, 'default': 5, 'weight': 0.25},
  {'section': 'Handling', 'label': 'How many successful catches out of 10? (count)', 'key': 'catch_accuracy', 'min': 0, 'max': 10, 'default': 7, 'weight': 0.20},
  {'section': 'Handling', 'label': 'How accurately can you throw at a target? (% hits)', 'key': 'throw_accuracy', 'min': 0, 'max': 100, 'default': 60, 'weight': 0.20},
  {'section': 'Handling', 'label': 'How well do you control a bat, stick, or racquet? (1–10)', 'key': 'tool_handling', 'min': 1, 'max': 10, 'default': 5, 'weight': 0.10},
];


  // Map for storing dynamic responses
  Map<String, int> _responses = {};

  Future<void> _findSports() async {

    setState(() {
      _isLoading = true;
    });

    double enduranceScore = 0;
    double strengthScore = 0;
    double powerScore = 0;
    double speedScore = 0;
    double agilityScore = 0;
    double flexibilityScore = 0;
    double nervousSystemScore = 0;
    double durabilityScore = 0;
    double handlingScore = 0;
    for (var question in _questions) {
      final response = _responses[question['key']] ?? question['default'];
      final min = question['min'] ?? 0;
      final max = question['max'] ?? 100;
      final weight = question['weight'] ?? 1.0;

      // Min-max normalization
      final normalizedValue = (response - min) / (max - min);
      final weightedValue = normalizedValue * weight;

      switch (question['section']) {
        case 'Endurance':
          enduranceScore += weightedValue;
          break;
        case 'Strength':
          strengthScore += weightedValue;
          break;
        case 'Power':
          powerScore += weightedValue;
          break;
        case 'Speed':
          speedScore += weightedValue;
          break;
        case 'Agility':
          agilityScore += weightedValue;
          break;
        case 'Flexibility':
          flexibilityScore += weightedValue;
          break;
        case 'Nervous system requirements':
          nervousSystemScore += weightedValue;
          break;
        case 'Durability':
          durabilityScore += weightedValue;
          break;
        case 'Handling':
          handlingScore += weightedValue;
          break;
      }
    }
    print('Endurance Score: $enduranceScore');
    print('Strength Score: $strengthScore');
    print('Power Score: $powerScore');
    print('Speed Score: $speedScore');
    print('Agility Score: $agilityScore');
    print('Flexibility Score: $flexibilityScore');
    print('Nervous System Score: $nervousSystemScore');
    print('Durability Score: $durabilityScore');
    print('Handling Score: $handlingScore');
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid ?? 'anonymous';

      final recommendations = await _sportRepository.getRecommendations(
        enduranceScore,
        strengthScore,
        powerScore,
        speedScore,
        agilityScore,
        flexibilityScore,
        nervousSystemScore,
        durabilityScore,
        handlingScore,
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

Widget _buildQuestion(Map<String, dynamic> question, int index) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${question['label']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      final currentValue = _responses[question['key']] ?? question['default'];
                      if (currentValue > (question['min'] ?? 0)) {
                        _responses[question['key']] = currentValue - 1;
                      }
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                ),
                Text(
                  '${_responses[question['key']] ?? question['default']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    setState(() {
                      final currentValue = _responses[question['key']] ?? question['default'];
                      if (currentValue < (question['max'] ?? 100)) {
                        _responses[question['key']] = currentValue + 1;
                      }
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
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
            const SizedBox(height: 16),

            // Loop through all questions, adding dynamic widgets for each
            for (var i = 0; i < _questions.length; i++)
              _buildQuestion(_questions[i], i),

            const SizedBox(height: 16),

            Center(
              child: ElevatedButton(
              onPressed: _findSports,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                ),
                elevation: 6,
              ),
              child: _isLoading
                ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                  )
                : const Text(
                  'Find Sports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
              ),
            ),
            ],
        ),
      ),
    );
  }

  Widget _buildResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Your Recommended Sports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_recommendedSports!.isEmpty)
            const Text('No recommendations available.'),
          for (var sport in _recommendedSports!)
            const SizedBox(height: 16),
        ],
      ),
    );
  }
}

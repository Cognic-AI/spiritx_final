import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/progress_model.dart';
import 'package:sri_lanka_sports_app/repositories/progress_repository.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';

class ProgressQuestionnaireScreen extends StatefulWidget {
  const ProgressQuestionnaireScreen({super.key});

  @override
  State<ProgressQuestionnaireScreen> createState() =>
      _ProgressQuestionnaireScreenState();
}

class _ProgressQuestionnaireScreenState
    extends State<ProgressQuestionnaireScreen> {
  final PageController _pageController = PageController();
  final ProgressRepository _progressRepository = ProgressRepository();
  final TextEditingController _notesController = TextEditingController();

  int _currentPage = 0;
  bool _isSubmitting = false;
  List<QuestionnaireAnswer> _answers = [];

  // Define the questionnaire
  final List<Map<String, dynamic>> _questions = [
    // Physical category
    {
      'question': 'How would you rate your energy level today?',
      'category': 'physical',
      'options': [
        {'text': 'Very low energy', 'score': 1},
        {'text': 'Low energy', 'score': 3},
        {'text': 'Moderate energy', 'score': 5},
        {'text': 'Good energy', 'score': 7},
        {'text': 'Excellent energy', 'score': 10},
      ],
    },
    {
      'question':
          'How would you rate your physical performance during training/practice today?',
      'category': 'physical',
      'options': [
        {'text': 'Very poor', 'score': 1},
        {'text': 'Poor', 'score': 3},
        {'text': 'Average', 'score': 5},
        {'text': 'Good', 'score': 7},
        {'text': 'Excellent', 'score': 10},
      ],
    },
    {
      'question': 'How is your recovery from previous training sessions?',
      'category': 'physical',
      'options': [
        {'text': 'Still very sore/fatigued', 'score': 1},
        {'text': 'Somewhat sore/fatigued', 'score': 3},
        {'text': 'Moderately recovered', 'score': 5},
        {'text': 'Well recovered', 'score': 7},
        {'text': 'Fully recovered', 'score': 10},
      ],
    },

    // Technical category
    {
      'question':
          'How would you rate your technical execution of skills today?',
      'category': 'technical',
      'options': [
        {'text': 'Very poor execution', 'score': 1},
        {'text': 'Poor execution', 'score': 3},
        {'text': 'Average execution', 'score': 5},
        {'text': 'Good execution', 'score': 7},
        {'text': 'Excellent execution', 'score': 10},
      ],
    },
    {
      'question':
          'How well did you apply tactical knowledge during practice/competition?',
      'category': 'technical',
      'options': [
        {'text': 'Very poorly', 'score': 1},
        {'text': 'Poorly', 'score': 3},
        {'text': 'Average', 'score': 5},
        {'text': 'Well', 'score': 7},
        {'text': 'Excellently', 'score': 10},
      ],
    },
    {
      'question':
          'How would you rate your progress in learning new skills/techniques?',
      'category': 'technical',
      'options': [
        {'text': 'No progress', 'score': 1},
        {'text': 'Little progress', 'score': 3},
        {'text': 'Some progress', 'score': 5},
        {'text': 'Good progress', 'score': 7},
        {'text': 'Excellent progress', 'score': 10},
      ],
    },

    // Mental category
    {
      'question': 'How would you rate your focus/concentration today?',
      'category': 'mental',
      'options': [
        {'text': 'Very distracted', 'score': 1},
        {'text': 'Somewhat distracted', 'score': 3},
        {'text': 'Average focus', 'score': 5},
        {'text': 'Good focus', 'score': 7},
        {'text': 'Excellent focus', 'score': 10},
      ],
    },
    {
      'question': 'How would you rate your motivation level today?',
      'category': 'mental',
      'options': [
        {'text': 'Very unmotivated', 'score': 1},
        {'text': 'Somewhat unmotivated', 'score': 3},
        {'text': 'Moderately motivated', 'score': 5},
        {'text': 'Highly motivated', 'score': 7},
        {'text': 'Extremely motivated', 'score': 10},
      ],
    },
    {
      'question':
          'How well did you handle pressure/stress during training or competition?',
      'category': 'mental',
      'options': [
        {'text': 'Very poorly', 'score': 1},
        {'text': 'Poorly', 'score': 3},
        {'text': 'Average', 'score': 5},
        {'text': 'Well', 'score': 7},
        {'text': 'Excellently', 'score': 10},
      ],
    },

    // Nutrition category
    {
      'question': 'How would you rate your nutrition quality today?',
      'category': 'nutrition',
      'options': [
        {'text': 'Very poor', 'score': 1},
        {'text': 'Poor', 'score': 3},
        {'text': 'Average', 'score': 5},
        {'text': 'Good', 'score': 7},
        {'text': 'Excellent', 'score': 10},
      ],
    },
    {
      'question': 'How well did you stay hydrated today?',
      'category': 'nutrition',
      'options': [
        {'text': 'Very dehydrated', 'score': 1},
        {'text': 'Somewhat dehydrated', 'score': 3},
        {'text': 'Adequately hydrated', 'score': 5},
        {'text': 'Well hydrated', 'score': 7},
        {'text': 'Optimally hydrated', 'score': 10},
      ],
    },
    {
      'question':
          'How well did you time your meals around training/competition?',
      'category': 'nutrition',
      'options': [
        {'text': 'Very poorly timed', 'score': 1},
        {'text': 'Poorly timed', 'score': 3},
        {'text': 'Average timing', 'score': 5},
        {'text': 'Well timed', 'score': 7},
        {'text': 'Perfectly timed', 'score': 10},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnswers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeAnswers() {
    _answers = List.generate(_questions.length, (index) {
      return QuestionnaireAnswer(
        question: _questions[index]['question'],
        answer: '',
        score: 0,
        category: _questions[index]['category'],
      );
    });
  }

  void _selectAnswer(int questionIndex, String answer, int score) {
    setState(() {
      _answers[questionIndex] = QuestionnaireAnswer(
        question: _questions[questionIndex]['question'],
        answer: answer,
        score: score,
        category: _questions[questionIndex]['category'],
      );
    });

    // Move to next question after a short delay
    if (questionIndex < _questions.length - 1) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _questions.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitQuestionnaire() async {
    // Check if all questions are answered
    if (_answers.any((answer) => answer.score == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions before submitting'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Calculate category scores
      final physicalAnswers =
          _answers.where((a) => a.category == 'physical').toList();
      final technicalAnswers =
          _answers.where((a) => a.category == 'technical').toList();
      final mentalAnswers =
          _answers.where((a) => a.category == 'mental').toList();
      final nutritionAnswers =
          _answers.where((a) => a.category == 'nutrition').toList();

      final physicalScore = physicalAnswers.isNotEmpty
          ? physicalAnswers.map((a) => a.score).reduce((a, b) => a + b) /
              physicalAnswers.length
          : 0.0;

      final technicalScore = technicalAnswers.isNotEmpty
          ? technicalAnswers.map((a) => a.score).reduce((a, b) => a + b) /
              technicalAnswers.length
          : 0.0;

      final mentalScore = mentalAnswers.isNotEmpty
          ? mentalAnswers.map((a) => a.score).reduce((a, b) => a + b) /
              mentalAnswers.length
          : 0.0;

      final nutritionScore = nutritionAnswers.isNotEmpty
          ? nutritionAnswers.map((a) => a.score).reduce((a, b) => a + b) /
              nutritionAnswers.length
          : 0.0;

      // Calculate overall score (average of all categories)
      final overallScore =
          (physicalScore + technicalScore + mentalScore + nutritionScore) / 4;

      // Create progress entry
      final entry = ProgressEntry(
        id: '', // Will be set by the repository
        userId: userId,
        date: DateTime.now(),
        physicalScore: physicalScore,
        technicalScore: technicalScore,
        mentalScore: mentalScore,
        nutritionScore: nutritionScore,
        overallScore: overallScore,
        notes: _notesController.text,
        answers: _answers,
      );

      // Save to database
      await _progressRepository.addProgressEntry(entry);

      if (!mounted) return;

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress tracked successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error submitting questionnaire: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit questionnaire: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Questionnaire'),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / (_questions.length + 1),
            backgroundColor: Colors.grey[200],
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),

          // Page view for questions
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                // Question pages
                ..._questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return _buildQuestionPage(index, question);
                }),

                // Notes page (final page)
                _buildNotesPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton.icon(
                    onPressed: _previousPage,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox(),
                if (_currentPage < _questions.length)
                  TextButton.icon(
                    onPressed:
                        _answers[_currentPage].score > 0 ? _nextPage : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  )
                else
                  CustomButton(
                    text: 'Submit',
                    isLoading: _isSubmitting,
                    onPressed: _submitQuestionnaire,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index, Map<String, dynamic> question) {
    final options = question['options'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1} of ${_questions.length}',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question['question'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getCategoryColor(question['category']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getCategoryName(question['category']),
              style: TextStyle(
                color: _getCategoryColor(question['category']),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, optionIndex) {
                final option = options[optionIndex];
                final isSelected = _answers[index].answer == option['text'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      _selectAnswer(index, option['text'], option['score']);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option['text'],
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPage() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add any additional notes about your performance, feelings, or circumstances today (optional).',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: 'Enter your notes here...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to submit?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Click the Submit button below to save your progress tracking for today.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'physical':
        return Colors.blue;
      case 'technical':
        return Colors.green;
      case 'mental':
        return Colors.purple;
      case 'nutrition':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'physical':
        return 'Physical';
      case 'technical':
        return 'Technical';
      case 'mental':
        return 'Mental';
      case 'nutrition':
        return 'Nutrition';
      default:
        return 'Other';
    }
  }
}

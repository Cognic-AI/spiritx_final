import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/models/rtp_calculator_model.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';

class RtpCalculatorScreen extends StatefulWidget {
  const RtpCalculatorScreen({super.key});

  @override
  State<RtpCalculatorScreen> createState() => _RtpCalculatorScreenState();
}

class _RtpCalculatorScreenState extends State<RtpCalculatorScreen> {
  int _currentStep = 0;
  final int _totalSteps = 9;

  // Assessment data
  String _injurySeverity = 'Moderate';
  int _daysSinceInjury = 1;
  int _painLevel = 5;
  bool _hasSwelling = true;
  String _rangeOfMotion = 'Limited';
  String _weightBearingStatus = 'Partial';
  bool _hasPreviousInjury = false;
  String _currentActivityLevel = 'Moderate';
  String _injuryType = 'Sprain';

  // Controllers
  final TextEditingController _daysController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _daysController.addListener(() {
      if (_daysController.text.isNotEmpty) {
        setState(() {
          _daysSinceInjury = int.tryParse(_daysController.text) ?? 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _generateResults();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _generateResults() {
    final assessment = AnkleInjuryAssessment(
      injurySeverity: _injurySeverity,
      daysSinceInjury: _daysSinceInjury,
      painLevel: _painLevel,
      hasSwelling: _hasSwelling,
      rangeOfMotion: _rangeOfMotion,
      weightBearingStatus: _weightBearingStatus,
      hasPreviousInjury: _hasPreviousInjury,
      currentActivityLevel: _currentActivityLevel,
      injuryType: _injuryType,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RtpResultsScreen(assessment: assessment),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RTP Calculator - Ankle'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentStep + 1} of $_totalSteps',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${((_currentStep + 1) / _totalSteps * 100).toInt()}%',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / _totalSteps,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            // Question content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildQuestionStep(_currentStep),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    ElevatedButton(
                      onPressed: _previousStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Previous'),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep < _totalSteps - 1
                        ? 'Next'
                        : 'Get Results'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionStep(int step) {
    switch (step) {
      case 0:
        return _buildInjuryTypeQuestion();
      case 1:
        return _buildInjurySeverityQuestion();
      case 2:
        return _buildDaysSinceInjuryQuestion();
      case 3:
        return _buildPainLevelQuestion();
      case 4:
        return _buildSwellingQuestion();
      case 5:
        return _buildRangeOfMotionQuestion();
      case 6:
        return _buildWeightBearingQuestion();
      case 7:
        return _buildPreviousInjuryQuestion();
      case 8:
        return _buildActivityLevelQuestion();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInjuryTypeQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What type of ankle injury do you have?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the type that best describes your injury.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        _buildRadioOption(
            'Sprain',
            'Ligament injury from twisting or rolling the ankle',
            _injuryType, (value) {
          setState(() {
            _injuryType = value!;
          });
        }),
        _buildRadioOption(
            'Strain',
            'Muscle or tendon injury from overstretching',
            _injuryType, (value) {
          setState(() {
            _injuryType = value!;
          });
        }),
        _buildRadioOption(
            'Fracture', 'Suspected or confirmed bone break', _injuryType,
            (value) {
          setState(() {
            _injuryType = value!;
          });
        }),
        _buildRadioOption('Tendonitis', 'Inflammation of a tendon', _injuryType,
            (value) {
          setState(() {
            _injuryType = value!;
          });
        }),
        const SizedBox(height: 16),
        if (_injuryType == 'Fracture')
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical Attention Required',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'If you suspect a fracture, please seek immediate medical attention. This calculator is not a substitute for professional medical advice.',
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInjurySeverityQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you rate the severity of your ankle injury?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the option that best describes your injury.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        _buildRadioOption(
            'Mild',
            'Slight pain and swelling, minimal difficulty walking',
            _injurySeverity, (value) {
          setState(() {
            _injurySeverity = value!;
          });
        }),
        _buildRadioOption(
            'Moderate',
            'Moderate pain and swelling, difficulty walking',
            _injurySeverity, (value) {
          setState(() {
            _injurySeverity = value!;
          });
        }),
        _buildRadioOption(
            'Severe',
            'Intense pain, significant swelling, unable to bear weight',
            _injurySeverity, (value) {
          setState(() {
            _injurySeverity = value!;
          });
        }),
      ],
    );
  }

  Widget _buildDaysSinceInjuryQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How many days has it been since your injury?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter the number of days since your ankle injury occurred.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _daysController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Days',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: const Icon(Icons.calendar_today),
          ),
        ),
      ],
    );
  }

  Widget _buildPainLevelQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your current pain level?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rate your pain on a scale from 0 (no pain) to 10 (worst pain imaginable).',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: _painLevel.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          label: _painLevel.toString(),
          activeColor: AppTheme.primaryColor,
          onChanged: (value) {
            setState(() {
              _painLevel = value.toInt();
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('No Pain (0)'),
            Text(
              '$_painLevel',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const Text('Severe (10)'),
          ],
        ),
      ],
    );
  }

  Widget _buildSwellingQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Do you currently have swelling in your ankle?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Indicate if you have noticeable swelling around your ankle.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hasSwelling = true;
                  });
                },
                child: Card(
                  elevation: _hasSwelling ? 4 : 1,
                  color: _hasSwelling
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _hasSwelling
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: _hasSwelling ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _hasSwelling
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'I have swelling',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hasSwelling = false;
                  });
                },
                child: Card(
                  elevation: !_hasSwelling ? 4 : 1,
                  color: !_hasSwelling
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: !_hasSwelling
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: !_hasSwelling ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: !_hasSwelling
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'No swelling',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRangeOfMotionQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How would you describe your ankle\'s range of motion?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the option that best describes your ability to move your ankle.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        _buildRadioOption('Normal', 'Full range of motion with no limitations',
            _rangeOfMotion, (value) {
          setState(() {
            _rangeOfMotion = value!;
          });
        }),
        _buildRadioOption(
            'Limited',
            'Some restriction in movement, but can move in all directions',
            _rangeOfMotion, (value) {
          setState(() {
            _rangeOfMotion = value!;
          });
        }),
        _buildRadioOption(
            'Severely Limited',
            'Significant restriction, difficulty moving in most directions',
            _rangeOfMotion, (value) {
          setState(() {
            _rangeOfMotion = value!;
          });
        }),
        _buildRadioOption(
            'Unable to Move', 'Cannot move ankle at all', _rangeOfMotion,
            (value) {
          setState(() {
            _rangeOfMotion = value!;
          });
        }),
      ],
    );
  }

  Widget _buildWeightBearingQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your current weight-bearing status?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the option that best describes your ability to put weight on your injured ankle.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        _buildRadioOption(
            'Full',
            'Can bear full weight with minimal or no pain',
            _weightBearingStatus, (value) {
          setState(() {
            _weightBearingStatus = value!;
          });
        }),
        _buildRadioOption(
            'Partial',
            'Can put some weight on the ankle, but with pain',
            _weightBearingStatus, (value) {
          setState(() {
            _weightBearingStatus = value!;
          });
        }),
        _buildRadioOption(
            'Minimal',
            'Can only touch the floor lightly with the injured foot',
            _weightBearingStatus, (value) {
          setState(() {
            _weightBearingStatus = value!;
          });
        }),
        _buildRadioOption(
            'Non-Weight Bearing',
            'Cannot put any weight on the injured ankle',
            _weightBearingStatus, (value) {
          setState(() {
            _weightBearingStatus = value!;
          });
        }),
      ],
    );
  }

  Widget _buildPreviousInjuryQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Have you had a previous ankle injury on the same ankle?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Indicate if you have injured the same ankle before.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hasPreviousInjury = true;
                  });
                },
                child: Card(
                  elevation: _hasPreviousInjury ? 4 : 1,
                  color: _hasPreviousInjury
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: _hasPreviousInjury
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: _hasPreviousInjury ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: _hasPreviousInjury
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'I have injured this ankle before',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hasPreviousInjury = false;
                  });
                },
                child: Card(
                  elevation: !_hasPreviousInjury ? 4 : 1,
                  color: !_hasPreviousInjury
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: !_hasPreviousInjury
                          ? AppTheme.primaryColor
                          : Colors.grey.shade300,
                      width: !_hasPreviousInjury ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: !_hasPreviousInjury
                              ? AppTheme.primaryColor
                              : Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'This is my first ankle injury',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLevelQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What was your activity level before the injury?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the option that best describes your typical physical activity level.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        _buildRadioOption('Sedentary', 'Little to no regular physical activity',
            _currentActivityLevel, (value) {
          setState(() {
            _currentActivityLevel = value!;
          });
        }),
        _buildRadioOption(
            'Light', 'Light activity 1-3 days per week', _currentActivityLevel,
            (value) {
          setState(() {
            _currentActivityLevel = value!;
          });
        }),
        _buildRadioOption('Moderate', 'Moderate activity 3-5 days per week',
            _currentActivityLevel, (value) {
          setState(() {
            _currentActivityLevel = value!;
          });
        }),
        _buildRadioOption(
            'High',
            'Intense activity 5+ days per week or competitive athlete',
            _currentActivityLevel, (value) {
          setState(() {
            _currentActivityLevel = value!;
          });
        }),
      ],
    );
  }

  Widget _buildRadioOption(String title, String subtitle, String groupValue,
      Function(String?) onChanged) {
    return Card(
      elevation: title == groupValue ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: title == groupValue
              ? AppTheme.primaryColor
              : Colors.grey.shade300,
          width: title == groupValue ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        value: title,
        groupValue: groupValue,
        activeColor: AppTheme.primaryColor,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

class RtpResultsScreen extends StatelessWidget {
  final AnkleInjuryAssessment assessment;

  const RtpResultsScreen({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final plan = _generateRehabPlan(assessment);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Recovery Plan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.timer,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estimated Return to Play',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${plan.estimatedDaysToReturn} days',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        plan.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plan.description,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Rehabilitation phases
              const Text(
                'Rehabilitation Protocol',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              // Phase cards
              ...plan.phases
                  .map((phase) => _buildPhaseCard(context, phase))
                  .toList(),

              const SizedBox(height: 24),

              // Precautions
              const Text(
                'Precautions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              ...plan.precautions
                  .map((precaution) => _buildBulletPoint(precaution))
                  .toList(),

              const SizedBox(height: 24),

              // Follow-up recommendations
              const Text(
                'Follow-up Recommendations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              ...plan.followUpRecommendations
                  .map((recommendation) => _buildBulletPoint(recommendation))
                  .toList(),

              const SizedBox(height: 32),

              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disclaimer',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This rehabilitation plan is a general guideline and not a substitute for professional medical advice. Always consult with a healthcare provider before beginning any rehabilitation program.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Save and share buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Save Plan',
                      icon: Icons.save,
                      onPressed: () {
                        // Save plan functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Plan saved successfully'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Share Plan',
                      icon: Icons.share,
                      isOutlined: true,
                      onPressed: () {
                        // Share plan functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing functionality coming soon'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseCard(BuildContext context, RehabPhase phase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          phase.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Duration: ${phase.duration}',
          style: TextStyle(
            color: AppTheme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal: ${phase.goal}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Exercises:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...phase.exercises
                    .map((exercise) => _buildExerciseItem(exercise))
                    .toList(),
                const SizedBox(height: 16),
                const Text(
                  'Progression Criteria:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...phase.criteria
                    .map((criterion) => _buildBulletPoint(criterion))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(RehabExercise exercise) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(exercise.description),
                const SizedBox(height: 4),
                Text(
                  'Frequency: ${exercise.frequency}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  RehabilitationPlan _generateRehabPlan(AnkleInjuryAssessment assessment) {
    // Generate a rehabilitation plan based on the assessment
    int estimatedDays = 0;
    String title = '';
    String description = '';
    List<RehabPhase> phases = [];
    List<String> precautions = [];
    List<String> followUpRecommendations = [];

    // Calculate estimated days based on injury severity and type
    if (assessment.injuryType == 'Sprain') {
      if (assessment.injurySeverity == 'Mild') {
        estimatedDays = 14;
        title = 'Mild Ankle Sprain Recovery Plan';
        description =
            'A comprehensive rehabilitation program for a mild ankle sprain, focusing on restoring mobility, strength, and function.';
      } else if (assessment.injurySeverity == 'Moderate') {
        estimatedDays = 28;
        title = 'Moderate Ankle Sprain Recovery Plan';
        description =
            'A structured rehabilitation program for a moderate ankle sprain, with progressive phases to ensure safe return to activity.';
      } else {
        estimatedDays = 42;
        title = 'Severe Ankle Sprain Recovery Plan';
        description =
            'An intensive rehabilitation program for a severe ankle sprain, requiring careful progression through healing phases.';
      }
    } else if (assessment.injuryType == 'Strain') {
      if (assessment.injurySeverity == 'Mild') {
        estimatedDays = 14;
        title = 'Mild Ankle Strain Recovery Plan';
        description =
            'A targeted rehabilitation program for a mild ankle muscle strain, focusing on muscle healing and strengthening.';
      } else if (assessment.injurySeverity == 'Moderate') {
        estimatedDays = 28;
        title = 'Moderate Ankle Strain Recovery Plan';
        description =
            'A comprehensive rehabilitation program for a moderate ankle muscle strain, with gradual return to full function.';
      } else {
        estimatedDays = 42;
        title = 'Severe Ankle Strain Recovery Plan';
        description =
            'An extensive rehabilitation program for a severe ankle muscle strain, requiring careful progression and monitoring.';
      }
    } else if (assessment.injuryType == 'Tendonitis') {
      estimatedDays = 35;
      title = 'Ankle Tendonitis Recovery Plan';
      description =
          'A specialized rehabilitation program for ankle tendonitis, focusing on reducing inflammation and strengthening the affected tendon.';
    } else {
      estimatedDays = 56;
      title = 'Ankle Fracture Recovery Plan';
      description =
          'A comprehensive rehabilitation program for an ankle fracture, to be followed after medical clearance and removal of immobilization.';
    }

    // Adjust for previous injury
    if (assessment.hasPreviousInjury) {
      estimatedDays = (estimatedDays * 1.2).round();
    }

    // Adjust for activity level
    if (assessment.currentActivityLevel == 'High') {
      estimatedDays = (estimatedDays * 0.9).round();
    } else if (assessment.currentActivityLevel == 'Sedentary') {
      estimatedDays = (estimatedDays * 1.1).round();
    }

    // Create phases based on injury type and severity
    if (assessment.injuryType == 'Sprain' ||
        assessment.injuryType == 'Strain') {
      // Phase 1: Acute Phase
      phases.add(
        RehabPhase(
          name: 'Phase 1: Protection and Pain Control',
          duration: '1-7 days',
          goal: 'Reduce pain, swelling, and protect the injured tissues',
          exercises: [
            RehabExercise(
              name: 'Ankle Alphabet',
              description:
                  'Draw the alphabet with your toes, moving only your ankle.',
              frequency: '2-3 times daily, 1-2 sets',
            ),
            RehabExercise(
              name: 'Gentle Ankle Pumps',
              description:
                  'Slowly move your foot up and down at the ankle joint.',
              frequency: '3-5 times daily, 10-15 repetitions',
            ),
            RehabExercise(
              name: 'Towel Scrunches',
              description:
                  'Place a towel on the floor and scrunch it toward you using your toes.',
              frequency: 'Once daily, 2-3 sets of 10-15 repetitions',
            ),
          ],
          criteria: [
            'Decreased pain and swelling',
            'Ability to bear some weight on the affected ankle',
            'Improved range of motion',
          ],
        ),
      );

      // Phase 2: Subacute Phase
      phases.add(
        RehabPhase(
          name: 'Phase 2: Mobility and Initial Strengthening',
          duration: '1-3 weeks',
          goal: 'Restore range of motion and begin strengthening',
          exercises: [
            RehabExercise(
              name: 'Ankle Eversion/Inversion',
              description:
                  'Turn your foot outward and inward against resistance band.',
              frequency: 'Daily, 3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Calf Raises',
              description: 'Rise up on your toes and slowly lower back down.',
              frequency: 'Daily, 3 sets of 10-15 repetitions',
            ),
            RehabExercise(
              name: 'Single-Leg Balance',
              description:
                  'Stand on the injured leg for 30 seconds, progressing to unstable surfaces.',
              frequency: 'Daily, 3-5 repetitions',
            ),
          ],
          criteria: [
            'Full or near-full range of motion',
            'Minimal pain with daily activities',
            'Ability to stand on the affected leg for 30 seconds',
          ],
        ),
      );

      // Phase 3: Functional Phase
      phases.add(
        RehabPhase(
          name: 'Phase 3: Advanced Strengthening and Function',
          duration: '3-6 weeks',
          goal: 'Improve strength, balance, and prepare for return to activity',
          exercises: [
            RehabExercise(
              name: 'Lateral Band Walks',
              description:
                  'Place a resistance band around your ankles and walk sideways.',
              frequency:
                  '3-4 times weekly, 3 sets of 10-15 steps each direction',
            ),
            RehabExercise(
              name: 'Single-Leg Squat',
              description:
                  'Stand on the injured leg and perform a partial squat.',
              frequency: '3-4 times weekly, 3 sets of 8-12 repetitions',
            ),
            RehabExercise(
              name: 'Box Jumps',
              description:
                  'Jump onto a low box or step and step down carefully.',
              frequency: '2-3 times weekly, 3 sets of 8-10 repetitions',
            ),
          ],
          criteria: [
            'Full strength compared to the uninjured side',
            'No pain with sport-specific movements',
            'Good balance and proprioception',
          ],
        ),
      );

      // Phase 4: Return to Sport
      phases.add(
        RehabPhase(
          name: 'Phase 4: Return to Sport',
          duration: '6+ weeks',
          goal: 'Safe return to full activity and sport participation',
          exercises: [
            RehabExercise(
              name: 'Agility Ladder Drills',
              description:
                  'Perform various footwork patterns through an agility ladder.',
              frequency: '3 times weekly, 3-5 sets of each pattern',
            ),
            RehabExercise(
              name: 'Cutting and Pivoting Drills',
              description:
                  'Practice sport-specific cutting and pivoting movements.',
              frequency: '2-3 times weekly, progressing in intensity',
            ),
            RehabExercise(
              name: 'Plyometric Training',
              description: 'Perform jumping, hopping, and bounding exercises.',
              frequency: '2-3 times weekly, 3 sets of 8-12 repetitions',
            ),
          ],
          criteria: [
            'Full pain-free function',
            'Successful completion of sport-specific drills',
            'Confidence in the injured ankle',
            'Clearance from healthcare provider (if applicable)',
          ],
        ),
      );
    } else if (assessment.injuryType == 'Tendonitis') {
      // Phases for tendonitis
      phases.add(
        RehabPhase(
          name: 'Phase 1: Inflammation Control',
          duration: '1-2 weeks',
          goal: 'Reduce inflammation and pain',
          exercises: [
            RehabExercise(
              name: 'Gentle Ankle Mobility',
              description: 'Move your ankle through pain-free range of motion.',
              frequency: '3-4 times daily, 1-2 minutes',
            ),
            RehabExercise(
              name: 'Isometric Holds',
              description:
                  'Push against an immovable object in various directions.',
              frequency: 'Daily, 3-5 sets of 30-second holds',
            ),
          ],
          criteria: [
            'Decreased pain and inflammation',
            'Improved tolerance to daily activities',
          ],
        ),
      );

      phases.add(
        RehabPhase(
          name: 'Phase 2: Eccentric Strengthening',
          duration: '2-4 weeks',
          goal: 'Begin loading the tendon with eccentric exercises',
          exercises: [
            RehabExercise(
              name: 'Eccentric Heel Drops',
              description:
                  'Rise up on both feet, then slowly lower down on the affected foot.',
              frequency: 'Daily, 3 sets of 15 repetitions',
            ),
            RehabExercise(
              name: 'Resistance Band Exercises',
              description:
                  'Use a resistance band to strengthen the ankle in all directions.',
              frequency: 'Daily, 3 sets of 15 repetitions in each direction',
            ),
          ],
          criteria: [
            'Minimal pain with eccentric loading',
            'Improved strength in the affected tendon',
          ],
        ),
      );

      phases.add(
        RehabPhase(
          name: 'Phase 3: Functional Strengthening',
          duration: '4-6 weeks',
          goal: 'Progress to functional and sport-specific exercises',
          exercises: [
            RehabExercise(
              name: 'Single-Leg Balance',
              description:
                  'Balance on the affected leg, progressing to unstable surfaces.',
              frequency: 'Daily, 3 sets of 30-60 seconds',
            ),
            RehabExercise(
              name: 'Heel Raises with Weight',
              description:
                  'Perform heel raises while holding weights or wearing a backpack.',
              frequency: '3-4 times weekly, 3 sets of 12-15 repetitions',
            ),
          ],
          criteria: [
            'No pain with daily activities',
            'Improved endurance in the affected tendon',
          ],
        ),
      );

      phases.add(
        RehabPhase(
          name: 'Phase 4: Return to Activity',
          duration: '6+ weeks',
          goal: 'Safely return to full activity and prevent recurrence',
          exercises: [
            RehabExercise(
              name: 'Plyometric Training',
              description:
                  'Perform jumping and hopping exercises, progressing in intensity.',
              frequency: '2-3 times weekly, 3 sets of 10-12 repetitions',
            ),
            RehabExercise(
              name: 'Sport-Specific Drills',
              description:
                  'Practice movements specific to your sport or activity.',
              frequency:
                  '2-3 times weekly, progressing in duration and intensity',
            ),
          ],
          criteria: [
            'No pain with sport-specific activities',
            'Full strength and endurance',
            'Confidence in the affected ankle',
          ],
        ),
      );
    } else {
      // Phases for fracture (post-immobilization)
      phases.add(
        RehabPhase(
          name: 'Phase 1: Early Mobilization',
          duration: '1-3 weeks post-immobilization',
          goal: 'Restore basic mobility and reduce stiffness',
          exercises: [
            RehabExercise(
              name: 'Ankle Circles',
              description:
                  'Gently move your ankle in circles, both clockwise and counterclockwise.',
              frequency: '3-5 times daily, 1-2 minutes each direction',
            ),
            RehabExercise(
              name: 'Towel Stretches',
              description:
                  'Use a towel to gently stretch your ankle in dorsiflexion.',
              frequency: '3-4 times daily, 3 sets of 30-second holds',
            ),
          ],
          criteria: [
            'Improved range of motion',
            'Decreased pain and swelling',
            'Ability to bear partial weight (if cleared by doctor)',
          ],
        ),
      );

      phases.add(
        RehabPhase(
          name: 'Phase 2: Progressive Loading',
          duration: '3-6 weeks post-immobilization',
          goal: 'Begin strengthening and weight-bearing activities',
          exercises: [
            RehabExercise(
              name: 'Resistance Band Exercises',
              description:
                  'Use a resistance band to strengthen the ankle in all directions.',
              frequency: 'Daily, 3 sets of 10-15 repetitions in each direction',
            ),
            RehabExercise(
              name: 'Partial Weight-Bearing Exercises',
              description:
                  'Stand with partial weight on the affected leg, progressing to full weight.',
              frequency: 'Daily, 3-5 sets of 30-60 seconds',
            ),
          ],
          criteria: [
            'Ability to bear full weight',
            'Improved strength',
            'Minimal pain with daily activities',
          ],
        ),
      );

      phases.add(
        RehabPhase(
          name: 'Phase 3: Functional Strengthening',
          duration: '6-12 weeks post-immobilization',
          goal: 'Restore normal function and prepare for return to activities',
          exercises: [
            RehabExercise(
              name: 'Single-Leg Balance',
              description:
                  'Balance on the affected leg, progressing to unstable surfaces.',
              frequency: 'Daily, 3 sets of 30-60 seconds',
            ),
            RehabExercise(
              name: 'Step-Ups',
              description: 'Step up onto a step or box with the affected leg.',
              frequency: '3-4 times weekly, 3 sets of 10-15 repetitions',
            ),
          ],
          criteria: [
            'Near-normal strength compared to unaffected side',
            'Good balance and proprioception',
            'Minimal pain with advanced activities',
          ],
        ),
      );

      phases.add(
        RehabPhase(
          name: 'Phase 4: Return to Activity',
          duration: '12+ weeks post-immobilization',
          goal: 'Safe return to full activity and sport participation',
          exercises: [
            RehabExercise(
              name: 'Jogging and Running Progression',
              description:
                  'Begin with short jogging intervals, progressing to continuous running.',
              frequency: '3 times weekly, gradually increasing duration',
            ),
            RehabExercise(
              name: 'Sport-Specific Drills',
              description:
                  'Practice movements specific to your sport or activity.',
              frequency: '2-3 times weekly, progressing in intensity',
            ),
          ],
          criteria: [
            'Full strength and range of motion',
            'No pain with sport-specific activities',
            'Confidence in the affected ankle',
            'Clearance from healthcare provider',
          ],
        ),
      );
    }

    // Add precautions based on injury type
    precautions = [
      'Stop any exercise that causes sharp or increasing pain',
      'Apply ice after activity if swelling or pain increases',
      'Wear supportive footwear during all weight-bearing activities',
      'Progress gradually through each phase, meeting all criteria before advancing',
    ];

    if (assessment.injuryType == 'Fracture') {
      precautions.add(
          'Do not progress to the next phase without clearance from your healthcare provider');
      precautions.add(
          'Use assistive devices (crutches, boot, etc.) as directed by your healthcare provider');
    }

    if (assessment.hasPreviousInjury) {
      precautions.add(
          'Pay extra attention to proper technique during all exercises to prevent re-injury');
    }

    // Add follow-up recommendations
    followUpRecommendations = [
      'Consider wearing an ankle brace during high-risk activities for 3-6 months after injury',
      'Continue maintenance exercises 2-3 times weekly after completing the rehabilitation program',
      'Gradually return to sport-specific training, increasing intensity by no more than 10% per week',
    ];

    if (assessment.injurySeverity == 'Severe' ||
        assessment.injuryType == 'Fracture') {
      followUpRecommendations.add(
          'Schedule follow-up appointments with a healthcare provider to monitor progress');
    }

    return RehabilitationPlan(
      title: title,
      description: description,
      phases: phases,
      estimatedDaysToReturn: estimatedDays,
      precautions: precautions,
      followUpRecommendations: followUpRecommendations,
    );
  }
}

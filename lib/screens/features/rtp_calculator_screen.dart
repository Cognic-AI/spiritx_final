import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/models/rtp_calculator_model.dart';
import 'package:sri_lanka_sports_app/services/rtp_report_service.dart';
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

class RtpResultsScreen extends StatefulWidget {
  final AnkleInjuryAssessment assessment;

  const RtpResultsScreen({super.key, required this.assessment});

  @override
  State<RtpResultsScreen> createState() => _RtpResultsScreenState();
}

class _RtpResultsScreenState extends State<RtpResultsScreen> {
  late final RehabilitationPlan _plan;
  final RtpReportService _rtpReportService = RtpReportService();
  bool _isSaving = false;
  bool _saveSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _plan = _generateRehabPlan(widget.assessment);
  }

  Future<void> _savePlan() async {
    setState(() {
      _isSaving = true;
      _saveSuccess = false;
      _errorMessage = null;
    });

    try {
      final result =
          await _rtpReportService.saveRtpReport(_plan, widget.assessment);

      setState(() {
        _isSaving = false;
        _saveSuccess = result;
        if (!result) {
          _errorMessage = 'Failed to save report. Please try again.';
        }
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to save report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _errorMessage = 'Error: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                '${_plan.estimatedDaysToReturn} days',
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
                        _plan.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _plan.description,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bracing recommendations
              if (_plan.bracingRecommendations.isNotEmpty) ...[
                const Text(
                  'Bracing Recommendations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._plan.bracingRecommendations
                            .map((recommendation) =>
                                _buildBulletPoint(recommendation))
                            .toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

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
              ..._plan.phases
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
              ..._plan.precautions
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
              ..._plan.followUpRecommendations
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
                      text: _isSaving ? 'Saving...' : 'Save Plan',
                      icon: _isSaving ? Icons.hourglass_empty : Icons.save,
                      onPressed: _isSaving ? () {} : _savePlan,
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

              // Success or error message
              if (_saveSuccess || _errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _saveSuccess ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _saveSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _saveSuccess ? Icons.check_circle : Icons.error,
                        color: _saveSuccess ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _saveSuccess
                              ? 'Plan saved successfully to your profile'
                              : _errorMessage ?? 'Failed to save plan',
                          style: TextStyle(
                            color: _saveSuccess
                                ? Colors.green[800]
                                : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                if (phase.bracingGuidance != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Bracing:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(phase.bracingGuidance!),
                ],
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
    List<String> bracingRecommendations = [];

    // Calculate estimated days based on injury severity and type
    if (assessment.injuryType == 'Sprain') {
      if (assessment.injurySeverity == 'Mild') {
        estimatedDays = 70; // ~10 weeks
        title = 'Mild Ankle Sprain Recovery Plan';
        description =
            'A comprehensive rehabilitation program for a mild ankle sprain, following a 4-phase approach to ensure safe return to activity.';
      } else if (assessment.injurySeverity == 'Moderate') {
        estimatedDays = 84; // ~12 weeks
        title = 'Moderate Ankle Sprain Recovery Plan';
        description =
            'A structured rehabilitation program for a moderate ankle sprain, with progressive phases to ensure safe return to activity.';
      } else {
        estimatedDays = 112; // ~16 weeks
        title = 'Severe Ankle Sprain Recovery Plan';
        description =
            'An intensive rehabilitation program for a severe ankle sprain, requiring careful progression through healing phases.';
      }

      // Bracing recommendations for sprains
      bracingRecommendations = [
        'Wear a brace or protective tape during weight-bearing activities',
        'For severe sprains, immobilization is recommended for 10 days',
        'Utilize a lace-up brace for functional activities in later phases',
        'Consider prophylactic bracing for 3-6 months after returning to sport to prevent re-injury'
      ];

      // Create phases based on the protocol
      // Phase 1: Protection and Optimal Loading (1-2 weeks)
      phases.add(
        RehabPhase(
          name: 'Phase I: Protection and Optimal Loading',
          duration: '1-2 weeks',
          goal:
              'Decrease pain, decrease swelling, improve weight bearing, and protect healing structures',
          bracingGuidance:
              'Brace or protective tape should be worn during weight bearing activities. Immobilization is recommended for 10 days for severe ankle sprain.',
          exercises: [
            RehabExercise(
              name: 'Ankle Pumps',
              description:
                  'Slowly move your foot up and down at the ankle joint.',
              frequency: '3-5 times daily, 10-15 repetitions',
            ),
            RehabExercise(
              name: 'Ankle Circles',
              description:
                  'Rotate your ankle in clockwise and counterclockwise directions.',
              frequency: '3-5 times daily, 10 circles in each direction',
            ),
            RehabExercise(
              name: 'Ankle Alphabet',
              description:
                  'Draw the alphabet with your toes, moving only your ankle.',
              frequency: '2-3 times daily, 1-2 sets',
            ),
            RehabExercise(
              name: 'Seated Heel Raises',
              description:
                  'While seated, lift your heels off the ground while keeping toes on the floor.',
              frequency: 'Daily, 2-3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Seated Toe Raises',
              description:
                  'While seated, lift your toes off the ground while keeping heels on the floor.',
              frequency: 'Daily, 2-3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Towel Crunches',
              description:
                  'Place a towel on the floor and scrunch it toward you using your toes.',
              frequency: 'Once daily, 2-3 sets of 10-15 repetitions',
            ),
          ],
          criteria: [
            'Ability to fully weight bear on involved lower extremity',
            'Decreased pain',
            'Minimal swelling',
          ],
        ),
      );

      // Phase 2: Intermediate/Sub-acute (3-6 weeks)
      phases.add(
        RehabPhase(
          name: 'Phase II: Intermediate/Sub-acute',
          duration: '3-6 weeks',
          goal:
              'Decrease pain, normalize gait pattern, improve ankle ROM, improve single leg stance stability, and maintain or improve proximal muscle strength',
          bracingGuidance:
              'Continue to wear brace for weight bearing activities.',
          exercises: [
            RehabExercise(
              name: 'Knee to Wall Dorsiflexion',
              description:
                  'Face a wall with your toes about 4 inches away. Bend your knee to touch the wall while keeping your heel on the ground.',
              frequency: 'Daily, 3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Gastroc Stretch',
              description:
                  'Stand facing a wall with hands on the wall. Place the involved leg behind you with knee straight and heel down. Lean forward until you feel a stretch in your calf.',
              frequency: 'Daily, 3 sets of 30-second holds',
            ),
            RehabExercise(
              name: 'Soleus Stretch',
              description:
                  'Similar to the gastroc stretch, but with the back knee slightly bent.',
              frequency: 'Daily, 3 sets of 30-second holds',
            ),
            RehabExercise(
              name: 'Resisted Ankle Movements',
              description:
                  'Use a resistance band to perform ankle dorsiflexion, plantar flexion, inversion, and eversion.',
              frequency: 'Daily, 3 sets of 10-15 repetitions in each direction',
            ),
            RehabExercise(
              name: 'Double Leg Heel Raises',
              description:
                  'Stand with feet shoulder-width apart and rise up onto your toes.',
              frequency: 'Daily, 3 sets of 15 repetitions',
            ),
            RehabExercise(
              name: 'Single Leg Stance',
              description:
                  'Stand on the injured leg for 30 seconds, progressing to unstable surfaces.',
              frequency: 'Daily, 3-5 repetitions',
            ),
            RehabExercise(
              name: 'Tandem Walking',
              description:
                  'Walk in a straight line placing one foot directly in front of the other.',
              frequency: 'Daily, 3 sets of 10 steps',
            ),
          ],
          criteria: [
            'Non-antalgic gait pattern',
            'Equal single leg stance time and quality bilaterally',
            'Full ankle passive and active range of motion',
            '5/5 ankle strength with manual muscle testing',
          ],
        ),
      );

      // Phase 3: Late/Chronic (7-10 weeks)
      phases.add(
        RehabPhase(
          name: 'Phase III: Late/Chronic',
          duration: '7-10 weeks',
          goal:
              'Optimize strength, optimize balance, initiate plyometric activities, and initiate return to running',
          bracingGuidance:
              'Utilize lace up brace for functional activities as needed.',
          exercises: [
            RehabExercise(
              name: 'Single Leg Heel Raises',
              description:
                  'Stand on the injured leg and rise up onto your toes.',
              frequency: '3-4 times weekly, 3 sets of 15 repetitions',
            ),
            RehabExercise(
              name: 'Single Leg Multidirectional Reach',
              description:
                  'Stand on one leg and reach the other leg in different directions (forward, side, backward).',
              frequency:
                  '3-4 times weekly, 3 sets of 8 reaches in each direction',
            ),
            RehabExercise(
              name: 'Dual Task Balance',
              description:
                  'Stand on one leg while tossing a ball or performing another task.',
              frequency: '3-4 times weekly, 3 sets of 30 seconds',
            ),
            RehabExercise(
              name: 'Double Leg Hopping',
              description:
                  'Hop with both feet together in different patterns (forward/backward, side to side).',
              frequency: '2-3 times weekly, 3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Lateral Bounding',
              description:
                  'Jump sideways from one foot to the other in a controlled manner.',
              frequency: '2-3 times weekly, 3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Agility Ladder Drills',
              description:
                  'Perform various footwork patterns through an agility ladder.',
              frequency: '2-3 times weekly, 3 sets of each pattern',
            ),
          ],
          criteria: [
            'Able to perform 25 single leg heel raises or equal number compared to uninvolved side',
            '80% or better performance on involved lower extremity compared to contralateral side with Star balance / Y-balance excursion test',
            'Appropriate scores on patient reported outcome measure (e.g. Cumberland Ankle Instability Tool or FAAM)',
          ],
        ),
      );

      // Phase 4: Return to Sport (11-16 weeks)
      phases.add(
        RehabPhase(
          name: 'Phase IV: Return to Sport',
          duration: '11-16 weeks',
          goal:
              'Full strength of foot and ankle, improve motor control with higher level activities, and return to normal activities',
          bracingGuidance:
              'Consider prophylactic bracing for high-risk activities.',
          exercises: [
            RehabExercise(
              name: 'Single Leg Agility Drills',
              description:
                  'Perform cutting, pivoting, and direction changes on the injured leg.',
              frequency: '2-3 times weekly, progressing in intensity',
            ),
            RehabExercise(
              name: 'Single Leg Hopping',
              description:
                  'Hop on the injured leg in different patterns (forward/backward, side to side, diagonally).',
              frequency: '2-3 times weekly, 3 sets of 10 repetitions',
            ),
            RehabExercise(
              name: 'Change of Direction Drills',
              description:
                  'Practice sport-specific cutting and pivoting movements.',
              frequency: '2-3 times weekly, progressing in intensity',
            ),
            RehabExercise(
              name: 'Interval Sports Training',
              description:
                  'Gradually return to sport-specific activities, starting with low intensity and short duration.',
              frequency:
                  '2-3 times weekly, gradually increasing intensity and duration',
            ),
            RehabExercise(
              name: 'Return to Running Progression',
              description:
                  'Begin with jogging intervals, progressing to continuous running and then sprinting.',
              frequency:
                  '3 times weekly, gradually increasing distance and speed',
            ),
          ],
          criteria: [
            '90% or better performance on involved lower extremity on Star balance / Y-Balance excursion test',
            '90% or better performance on involved lower extremity on single leg hop for distance, triple hop for distance, 6m timed hop, and/or cross over hop for distance',
            'Appropriate scores on patient reported outcome measure (e.g. Cumberland Ankle Instability Tool or FAAM)',
            'No increase in pain or swelling with plyometric and return to sports activities',
          ],
        ),
      );
    } else if (assessment.injuryType == 'Strain') {
      // Similar structure for strain but with appropriate modifications
      // ...existing strain rehabilitation plan...
      if (assessment.injurySeverity == 'Mild') {
        estimatedDays = 70; // ~10 weeks
        title = 'Mild Ankle Strain Recovery Plan';
        description =
            'A targeted rehabilitation program for a mild ankle muscle strain, focusing on muscle healing and strengthening.';
      } else if (assessment.injurySeverity == 'Moderate') {
        estimatedDays = 84; // ~12 weeks
        title = 'Moderate Ankle Strain Recovery Plan';
        description =
            'A comprehensive rehabilitation program for a moderate ankle muscle strain, with gradual return to full function.';
      } else {
        estimatedDays = 112; // ~16 weeks
        title = 'Severe Ankle Strain Recovery Plan';
        description =
            'An extensive rehabilitation program for a severe ankle muscle strain, requiring careful progression and monitoring.';
      }

      // Use similar phases as sprain but with focus on muscle healing
      // ... existing strain phases ...
    } else if (assessment.injuryType == 'Tendonitis') {
      estimatedDays = 84; // ~12 weeks
      title = 'Ankle Tendonitis Recovery Plan';
      description =
          'A specialized rehabilitation program for ankle tendonitis, focusing on reducing inflammation and strengthening the affected tendon.';

      // ... existing tendonitis phases ...
    } else {
      estimatedDays = 112; // ~16 weeks
      title = 'Ankle Fracture Recovery Plan';
      description =
          'A comprehensive rehabilitation program for an ankle fracture, to be followed after medical clearance and removal of immobilization.';

      // ... existing fracture phases ...
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
      'Consider a follow-up assessment with a physical therapist or sports medicine specialist before full return to sport',
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
      bracingRecommendations: bracingRecommendations,
    );
  }
}

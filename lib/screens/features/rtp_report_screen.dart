import 'package:flutter/material.dart';
import 'package:sri_lanka_sports_app/models/rtp_calculator_model.dart';
import 'package:sri_lanka_sports_app/screens/features/rtp_calculator_screen.dart';
import 'package:sri_lanka_sports_app/services/rtp_report_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';

class RtpReportScreen extends StatefulWidget {
  const RtpReportScreen({Key? key}) : super(key: key);

  @override
  State<RtpReportScreen> createState() => _RtpReportScreenState();
}

class _RtpReportScreenState extends State<RtpReportScreen> {
  final RtpReportService _rtpReportService = RtpReportService();
  Map<String, dynamic>? _report;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLastReport();
  }

  Future<void> _loadLastReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reports = await _rtpReportService.getUserRtpReports();
      if (reports.isNotEmpty) {
        setState(() {
          _report = reports.first;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load RTP report: $e';
      });
      print('Error loading RTP report: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
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
                      onPressed: _loadLastReport,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
            : _report != null
                ? _buildReportView()
                : _buildNoReportView();
  }

  Widget _buildReportView() {
    return
        // SingleChildScrollView(
        //   padding: const EdgeInsets.all(16),
        //   child:
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _report!['title'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _report!['description'],
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Estimated Days to Return: ${_report!['estimatedDaysToReturn']}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          'Precautions: ${_report!['precautions'] ?? 'None'}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          'Follow-Up Recommendations: ${_report!['followUpRecommendations'] ?? 'None'}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(
          'Bracing Recommendations: ${_report!['bracingRecommendations'] ?? 'None'}',
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RtpCalculatorScreen()),
            );
          },
          child: const Text('Create New Report'),
        ),
      ],
      // ),
    );
  }

  Widget _buildNoReportView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No RTP report found. Create a new one to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RtpCalculatorScreen()),
                );
              },
              child: const Text('Create New Report'),
            ),
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

  // ignore: unused_element
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
}

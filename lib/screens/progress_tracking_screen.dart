import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/progress_model.dart';
import 'package:sri_lanka_sports_app/repositories/progress_repository.dart';
import 'package:sri_lanka_sports_app/screens/progress_questionnaire_screen.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';
import 'package:sri_lanka_sports_app/utils/app_theme.dart';
import 'package:sri_lanka_sports_app/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProgressRepository _progressRepository = ProgressRepository();
  bool _isLoading = false;
  List<ProgressEntry> _progressEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgressData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgressData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid;

      if (userId != null) {
        final entries =
            await _progressRepository.getUserProgressEntries(userId);
        setState(() {
          _progressEntries = entries;
        });
      }
    } catch (e) {
      print('Error loading progress data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load progress data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startNewQuestionnaire() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgressQuestionnaireScreen(),
      ),
    ).then((_) => _loadProgressData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildHistoryTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewQuestionnaire,
        icon: const Icon(Icons.add),
        label: const Text('Track Today'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_progressEntries.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate average scores
    final physicalScores =
        _progressEntries.map((e) => e.physicalScore).toList();
    final technicalScores =
        _progressEntries.map((e) => e.technicalScore).toList();
    final mentalScores = _progressEntries.map((e) => e.mentalScore).toList();
    final nutritionScores =
        _progressEntries.map((e) => e.nutritionScore).toList();
    final overallScores = _progressEntries.map((e) => e.overallScore).toList();

    final avgPhysical = physicalScores.isNotEmpty
        ? physicalScores.reduce((a, b) => a + b) / physicalScores.length
        : 0;
    final avgTechnical = technicalScores.isNotEmpty
        ? technicalScores.reduce((a, b) => a + b) / technicalScores.length
        : 0;
    final avgMental = mentalScores.isNotEmpty
        ? mentalScores.reduce((a, b) => a + b) / mentalScores.length
        : 0;
    final avgNutrition = nutritionScores.isNotEmpty
        ? nutritionScores.reduce((a, b) => a + b) / nutritionScores.length
        : 0;
    final avgOverall = overallScores.isNotEmpty
        ? overallScores.reduce((a, b) => a + b) / overallScores.length
        : 0;

    // Get latest entry
    final latestEntry = _progressEntries.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${latestEntry.overallScore.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const Text('Latest Score'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '${avgOverall.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            const Text('Average Score'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Last tracked:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMMM d, yyyy').format(latestEntry.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress chart
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progress Over Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildProgressChart(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category breakdown
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryProgressBar(
                      'Physical', avgPhysical.toDouble(), Colors.blue),
                  const SizedBox(height: 12),
                  _buildCategoryProgressBar(
                      'Technical', avgTechnical.toDouble(), Colors.green),
                  const SizedBox(height: 12),
                  _buildCategoryProgressBar(
                      'Mental', avgMental.toDouble(), Colors.purple),
                  const SizedBox(height: 12),
                  _buildCategoryProgressBar(
                      'Nutrition', avgNutrition.toDouble(), Colors.orange),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 10,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildProgressChart() {
    if (_progressEntries.length < 2) {
      return const Center(
        child: Text('Not enough data to show chart'),
      );
    }

    // Get last 7 entries or all if less than 7
    final entries = _progressEntries.length > 7
        ? _progressEntries.sublist(0, 7).reversed.toList()
        : _progressEntries.reversed.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MM/dd').format(entries[value.toInt()].date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: entries.length - 1.0,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(entries.length, (index) {
              return FlSpot(index.toDouble(), entries[index].overallScore);
            }),
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_progressEntries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _progressEntries.length,
      itemBuilder: (context, index) {
        final entry = _progressEntries[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              _showEntryDetails(entry);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(entry.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Score: ${entry.overallScore.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildScoreChip(
                          'Physical', entry.physicalScore, Colors.blue),
                      const SizedBox(width: 8),
                      _buildScoreChip(
                          'Technical', entry.technicalScore, Colors.green),
                      const SizedBox(width: 8),
                      _buildScoreChip(
                          'Mental', entry.mentalScore, Colors.purple),
                      const SizedBox(width: 8),
                      _buildScoreChip(
                          'Nutrition', entry.nutritionScore, Colors.orange),
                    ],
                  ),
                  if (entry.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      entry.notes,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreChip(String label, double score, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryDetails(ProgressEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(entry.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Overall score
              Center(
                child: Column(
                  children: [
                    Text(
                      entry.overallScore.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const Text(
                      'Overall Score',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category scores
              const Text(
                'Category Scores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategoryProgressBar(
                  'Physical', entry.physicalScore, Colors.blue),
              const SizedBox(height: 12),
              _buildCategoryProgressBar(
                  'Technical', entry.technicalScore, Colors.green),
              const SizedBox(height: 12),
              _buildCategoryProgressBar(
                  'Mental', entry.mentalScore, Colors.purple),
              const SizedBox(height: 12),
              _buildCategoryProgressBar(
                  'Nutrition', entry.nutritionScore, Colors.orange),
              const SizedBox(height: 24),

              // Notes
              if (entry.notes.isNotEmpty) ...[
                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(entry.notes),
                const SizedBox(height: 24),
              ],

              // Answers
              const Text(
                'Questionnaire Answers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entry.answers.length,
                  itemBuilder: (context, index) {
                    final answer = entry.answers[index];
                    return ListTile(
                      title: Text(
                        'Q${index + 1}: ${answer.question}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        'A: ${answer.answer} (Score: ${answer.score})',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Progress Data Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your progress by completing the questionnaire',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Track Today',
            icon: Icons.add,
            onPressed: _startNewQuestionnaire,
          ),
        ],
      ),
    );
  }
}

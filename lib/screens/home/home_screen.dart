import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sri_lanka_sports_app/models/user_model.dart';
import 'package:sri_lanka_sports_app/screens/features/chatbot_screen.dart';
import 'package:sri_lanka_sports_app/screens/features/education_screen.dart';
import 'package:sri_lanka_sports_app/screens/features/equipment_finder_screen.dart';
import 'package:sri_lanka_sports_app/screens/features/health_centers_screen.dart';
import 'package:sri_lanka_sports_app/screens/features/notifications_screen.dart';
import 'package:sri_lanka_sports_app/screens/features/rtp_calculator_screen.dart';
import 'package:sri_lanka_sports_app/screens/features/sport_finder_screen.dart';
import 'package:sri_lanka_sports_app/screens/profile/profile_screen.dart';
import 'package:sri_lanka_sports_app/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _chatPage = "Chat";
  int _currentIndex = 0;
  String sessionId = "";

  void onChatSessionChanged(String newSessionId) {
    setState(() {
      sessionId = newSessionId;
      _chatPage = "Chat";
    });
  }

  void onChatPageChanged(String page) {
    setState(() {
      _chatPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userModel = authService.userModel;
    final isSportsperson = userModel?.role == 'sportsperson';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sri Lanka Sports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.person),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const ProfileScreen()),
          //     );
          //   },
          // ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: _currentIndex == 0
                ? _buildHome(
                    userModel: userModel, isSportsperson: isSportsperson)
                : (_currentIndex == 1
                    ? (_chatPage == "Chat"
                        ? ChatbotScreen(
                            sessionId: sessionId,
                            onChatPageChanged: () =>
                                onChatPageChanged("History"),
                            onSessionSelected: (selectedSessionId) =>
                                onChatSessionChanged(selectedSessionId),
                          )
                        : ChatSessionsScreen(
                            onSessionSelected: (selectedSessionId) {
                              onChatSessionChanged(selectedSessionId);
                              onChatPageChanged("Chat");
                            },
                          ))
                    : ProfileScreen())),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHome({
    required UserModel? userModel,
    required bool isSportsperson,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section with improved spacing
          _buildWelcomeSection(userModel),
          const SizedBox(height: 32),

          // Feature grid with better visual hierarchy
          _buildFeatureGrid(context, isSportsperson: isSportsperson),
          const SizedBox(height: 32),

          // Latest news with section header and view all option
          _buildNewsHeader(),
          const SizedBox(height: 16),
          _buildNewsList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(UserModel? userModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            children: [
              const TextSpan(text: 'Welcome back, '),
              TextSpan(
                text: userModel?.name ?? 'Champion',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: '! 👋'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover and enhance your sports potential',
          style: TextStyle(
            fontSize: 16,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context,
      {required bool isSportsperson}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildFeatureCard(
              context,
              title: 'Find Your Sport',
              icon: Icons.sports_soccer,
              color: Colors.blue.shade400,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SportFinderScreen()),
                );
              },
            ),

            if (isSportsperson)
              _buildFeatureCard(
                context,
                title: 'Health Centers',
                icon: Icons.local_hospital,
                color: Colors.teal.shade400,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HealthCentersScreen()),
                  );
                },
              ),

            // Equipment Finder
            _buildFeatureCard(
              context,
              title: 'Equipment Finder',
              icon: Icons.shopping_bag,
              color: Colors.amber.shade400,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber.shade400, Colors.amber.shade600],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EquipmentFinderScreen()),
                );
              },
            ),

            // Education
            _buildFeatureCard(
              context,
              title: 'Sports Education',
              icon: Icons.school,
              color: Colors.red.shade400,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EducationScreen()),
                );
              },
            ),

            // RTP Calculator
            _buildFeatureCard(
              context,
              title: 'RTP Calculator',
              icon: Icons.calculate,
              color: Colors.purple.shade400,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RtpCalculatorScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    Gradient? gradient,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: gradient,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Latest Sports News',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        // TextButton(
        //   onPressed: () {
        //     // Navigate to all news
        //   },
        //   child: Text(
        //     'View All',
        //     style: TextStyle(
        //       color: Theme.of(context).primaryColor,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildNewsList() {
    final newsItems = [
      {
        'title': 'Sri Lanka Cricket Team Wins Tournament',
        'summary':
            'The Sri Lanka cricket team has won the international tournament after a thrilling match against India.',
        'time': '2 hours ago',
        'category': 'Cricket',
      },
      {
        'title': 'New Athletics Talent Discovered',
        'summary':
            'Young sprinter from Colombo breaks national record for 100m dash.',
        'time': '5 hours ago',
        'category': 'Athletics',
      },
      {
        'title': 'Volleyball League Season Announced',
        'summary':
            'National volleyball league to begin next month with 12 teams competing.',
        'time': '1 day ago',
        'category': 'Volleyball',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: newsItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = newsItems[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Navigate to news detail
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          _getCategoryColor(item['category']!).withOpacity(0.1),
                    ),
                    child: Icon(
                      _getCategoryIcon(item['category']!),
                      size: 30,
                      color: _getCategoryColor(item['category']!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['category']!,
                          style: TextStyle(
                            color: _getCategoryColor(item['category']!),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['time']!,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cricket':
        return Colors.blue.shade600;
      case 'Athletics':
        return Colors.orange.shade600;
      case 'Volleyball':
        return Colors.green.shade600;
      default:
        return Colors.purple.shade600;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cricket':
        return Icons.sports_cricket;
      case 'Athletics':
        return Icons.directions_run;
      case 'Volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports;
    }
  }

//   Widget _buildFeatureCard(
//     BuildContext context, {
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   size: 32,
//                   color: color,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
}

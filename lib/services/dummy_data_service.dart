import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class DummyDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  // Generate and add dummy data to the database
  Future<void> generateDummyData() async {
    try {
      // Get current user ID
      final String userId =
          _auth.currentUser?.uid ?? 'Gu0qjwO6luRjI6nGFbTlRC0l0E83';

      // Add dummy data to each collection
      await _addDummySports();
      await _addDummyHealthCenters();
      await _addDummyEducationalContent();
      await _addDummyNotifications(userId);
      await _addDummyChatSessions(userId);
      await _addDummyEquipment();

      print('Dummy data generation completed successfully');
    } catch (e) {
      print('Error generating dummy data: $e');
      rethrow;
    }
  }

  // Add dummy sports data
  Future<void> _addDummySports() async {
    try {
      final batch = _firestore.batch();
      final sportsCollection = _firestore.collection('sports');

      // Check if collection already has data
      final existingDocs = await sportsCollection.limit(1).get();
      if (existingDocs.docs.isNotEmpty) {
        print('Sports collection already has data. Skipping...');
        return;
      }

      final List<Map<String, dynamic>> sportsData = [
        {
          'name': 'Cricket',
          'description':
              'Cricket is a bat-and-ball game played between two teams of eleven players on a field at the center of which is a 22-yard pitch with a wicket at each end. Sri Lanka has a rich history in cricket, winning the World Cup in 1996.',
          'skills': [
            'Hand-eye coordination',
            'Throwing',
            'Running',
            'Strategy',
            'Teamwork'
          ],
          'imageUrl': 'https://example.com/images/cricket.jpg',
          'attributes': {
            'isTeamSport': true,
            'competitiveLevel': 4,
            'physicalDemand': 3,
          },
        },
        {
          'name': 'Football',
          'description':
              'Football, also known as soccer, is a team sport played with a spherical ball between two teams of 11 players. It is played by approximately 250 million players in over 200 countries, making it the world\'s most popular sport.',
          'skills': ['Running', 'Kicking', 'Strategy', 'Teamwork', 'Endurance'],
          'imageUrl': 'https://example.com/images/football.jpg',
          'attributes': {
            'isTeamSport': true,
            'competitiveLevel': 5,
            'physicalDemand': 5,
          },
        },
        {
          'name': 'Swimming',
          'description':
              'Swimming is an individual or team racing sport that requires the use of one\'s entire body to move through water. The sport takes place in pools or open water.',
          'skills': [
            'Endurance',
            'Flexibility',
            'Strength',
            'Breathing control',
            'Technique'
          ],
          'imageUrl': 'https://example.com/images/swimming.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 3,
            'physicalDemand': 4,
          },
        },
        {
          'name': 'Volleyball',
          'description':
              'Volleyball is a team sport in which two teams of six players are separated by a net. Each team tries to score points by grounding a ball on the other team\'s court.',
          'skills': [
            'Jumping',
            'Hand-eye coordination',
            'Teamwork',
            'Agility',
            'Reflexes'
          ],
          'imageUrl': 'https://example.com/images/volleyball.jpg',
          'attributes': {
            'isTeamSport': true,
            'competitiveLevel': 4,
            'physicalDemand': 4,
          },
        },
        {
          'name': 'Basketball',
          'description':
              'Basketball is a team sport in which two teams, most commonly of five players each, opposing one another on a rectangular court, compete with the primary objective of shooting a basketball through the defender\'s hoop.',
          'skills': [
            'Jumping',
            'Hand-eye coordination',
            'Teamwork',
            'Agility',
            'Speed'
          ],
          'imageUrl': 'https://example.com/images/basketball.jpg',
          'attributes': {
            'isTeamSport': true,
            'competitiveLevel': 4,
            'physicalDemand': 5,
          },
        },
        {
          'name': 'Tennis',
          'description':
              'Tennis is a racket sport that can be played individually against a single opponent (singles) or between two teams of two players each (doubles).',
          'skills': [
            'Hand-eye coordination',
            'Agility',
            'Speed',
            'Endurance',
            'Strategy'
          ],
          'imageUrl': 'https://example.com/images/tennis.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 4,
            'physicalDemand': 4,
          },
        },
        {
          'name': 'Badminton',
          'description':
              'Badminton is a racquet sport played using racquets to hit a shuttlecock across a net. It is often played as a casual outdoor activity in a yard or on a beach.',
          'skills': [
            'Hand-eye coordination',
            'Agility',
            'Speed',
            'Reflexes',
            'Strategy'
          ],
          'imageUrl': 'https://example.com/images/badminton.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 3,
            'physicalDemand': 4,
          },
        },
        {
          'name': 'Rugby',
          'description':
              'Rugby is a contact team sport which originated in England in the first half of the 19th century. One of the two codes of rugby football, it is based on running with the ball in hand.',
          'skills': ['Strength', 'Speed', 'Teamwork', 'Tackling', 'Strategy'],
          'imageUrl': 'https://example.com/images/rugby.jpg',
          'attributes': {
            'isTeamSport': true,
            'competitiveLevel': 5,
            'physicalDemand': 5,
          },
        },
        {
          'name': 'Athletics',
          'description':
              'Athletics is a collection of sporting events that involve competitive running, jumping, throwing, and walking. The most common types of athletics competitions are track and field, road running, cross country running, and race walking.',
          'skills': ['Running', 'Jumping', 'Throwing', 'Endurance', 'Strength'],
          'imageUrl': 'https://example.com/images/athletics.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 4,
            'physicalDemand': 5,
          },
        },
        {
          'name': 'Karate',
          'description':
              'Karate is a martial art developed in the Ryukyu Kingdom. It developed from the indigenous Ryukyuan martial arts under the influence of Kung Fu, particularly Fujian White Crane.',
          'skills': [
            'Discipline',
            'Strength',
            'Flexibility',
            'Balance',
            'Focus'
          ],
          'imageUrl': 'https://example.com/images/karate.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 4,
            'physicalDemand': 4,
          },
        },
        {
          'name': 'Table Tennis',
          'description':
              'Table tennis, also known as ping-pong, is a sport in which two or four players hit a lightweight ball back and forth across a table using small rackets.',
          'skills': [
            'Hand-eye coordination',
            'Reflexes',
            'Agility',
            'Strategy',
            'Focus'
          ],
          'imageUrl': 'https://example.com/images/table_tennis.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 3,
            'physicalDemand': 2,
          },
        },
        {
          'name': 'Cycling',
          'description':
              'Cycling, also called bicycling or biking, is the use of bicycles for transport, recreation, exercise or sport.',
          'skills': [
            'Endurance',
            'Balance',
            'Leg strength',
            'Cardiovascular fitness',
            'Technique'
          ],
          'imageUrl': 'https://example.com/images/cycling.jpg',
          'attributes': {
            'isTeamSport': false,
            'competitiveLevel': 3,
            'physicalDemand': 4,
          },
        },
      ];

      // Add each sport to the batch
      for (var sportData in sportsData) {
        final docRef = sportsCollection.doc();
        batch.set(docRef, sportData);
      }

      // Commit the batch
      await batch.commit();
      print('Added ${sportsData.length} sports to the database');
    } catch (e) {
      print('Error adding dummy sports: $e');
      rethrow;
    }
  }

  // Add dummy health centers data
  Future<void> _addDummyHealthCenters() async {
    try {
      final batch = _firestore.batch();
      final healthCentersCollection = _firestore.collection('health_centers');

      // Check if collection already has data
      final existingDocs = await healthCentersCollection.limit(1).get();
      if (existingDocs.docs.isNotEmpty) {
        print('Health centers collection already has data. Skipping...');
        return;
      }

      final List<Map<String, dynamic>> healthCentersData = [
        {
          'name': 'National Sports Medicine Center',
          'address': '123 Independence Ave, Colombo 07',
          'phone': '+94 11 2456789',
          'services': [
            'Sports injury treatment',
            'Physical therapy',
            'Nutrition counseling',
            'Fitness assessment'
          ],
          'position': {
            'latitude': 6.9157,
            'longitude': 79.8636,
          },
          'imageUrl': 'https://example.com/images/nsmc.jpg',
          'operatingHours': {
            'Monday': '8:00 AM - 6:00 PM',
            'Tuesday': '8:00 AM - 6:00 PM',
            'Wednesday': '8:00 AM - 6:00 PM',
            'Thursday': '8:00 AM - 6:00 PM',
            'Friday': '8:00 AM - 6:00 PM',
            'Saturday': '9:00 AM - 1:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Kandy Sports Health Center',
          'address': '45 Peradeniya Road, Kandy',
          'phone': '+94 81 2234567',
          'services': [
            'Sports injury treatment',
            'Rehabilitation',
            'Fitness training',
            'Nutritional advice'
          ],
          'position': {
            'latitude': 7.2906,
            'longitude': 80.6337,
          },
          'imageUrl': 'https://example.com/images/kshc.jpg',
          'operatingHours': {
            'Monday': '8:30 AM - 5:30 PM',
            'Tuesday': '8:30 AM - 5:30 PM',
            'Wednesday': '8:30 AM - 5:30 PM',
            'Thursday': '8:30 AM - 5:30 PM',
            'Friday': '8:30 AM - 5:30 PM',
            'Saturday': '9:00 AM - 1:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Galle Sports Medical Clinic',
          'address': '78 Lighthouse Street, Galle',
          'phone': '+94 91 2245678',
          'services': [
            'Sports medicine',
            'Physiotherapy',
            'Injury prevention',
            'Performance enhancement'
          ],
          'position': {
            'latitude': 6.0328,
            'longitude': 80.2170,
          },
          'imageUrl': 'https://example.com/images/gsmc.jpg',
          'operatingHours': {
            'Monday': '9:00 AM - 5:00 PM',
            'Tuesday': '9:00 AM - 5:00 PM',
            'Wednesday': '9:00 AM - 5:00 PM',
            'Thursday': '9:00 AM - 5:00 PM',
            'Friday': '9:00 AM - 5:00 PM',
            'Saturday': '9:00 AM - 12:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Jaffna Athletic Health Center',
          'address': '34 Hospital Road, Jaffna',
          'phone': '+94 21 2223456',
          'services': [
            'Sports injury care',
            'Rehabilitation',
            'Nutrition counseling',
            'Fitness assessment'
          ],
          'position': {
            'latitude': 9.6615,
            'longitude': 80.0255,
          },
          'imageUrl': 'https://example.com/images/jahc.jpg',
          'operatingHours': {
            'Monday': '8:00 AM - 4:00 PM',
            'Tuesday': '8:00 AM - 4:00 PM',
            'Wednesday': '8:00 AM - 4:00 PM',
            'Thursday': '8:00 AM - 4:00 PM',
            'Friday': '8:00 AM - 4:00 PM',
            'Saturday': '9:00 AM - 12:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Negombo Sports Clinic',
          'address': '56 Beach Road, Negombo',
          'phone': '+94 31 2234567',
          'services': [
            'Sports medicine',
            'Physical therapy',
            'Massage therapy',
            'Injury prevention'
          ],
          'position': {
            'latitude': 7.2083,
            'longitude': 79.8358,
          },
          'imageUrl': 'https://example.com/images/nsc.jpg',
          'operatingHours': {
            'Monday': '9:00 AM - 6:00 PM',
            'Tuesday': '9:00 AM - 6:00 PM',
            'Wednesday': '9:00 AM - 6:00 PM',
            'Thursday': '9:00 AM - 6:00 PM',
            'Friday': '9:00 AM - 6:00 PM',
            'Saturday': '9:00 AM - 2:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Anuradhapura Sports Health Facility',
          'address': '23 New Town, Anuradhapura',
          'phone': '+94 25 2226789',
          'services': [
            'Sports injury treatment',
            'Rehabilitation',
            'Fitness training',
            'Nutritional advice'
          ],
          'position': {
            'latitude': 8.3114,
            'longitude': 80.4037,
          },
          'imageUrl': 'https://example.com/images/ashf.jpg',
          'operatingHours': {
            'Monday': '8:30 AM - 5:00 PM',
            'Tuesday': '8:30 AM - 5:00 PM',
            'Wednesday': '8:30 AM - 5:00 PM',
            'Thursday': '8:30 AM - 5:00 PM',
            'Friday': '8:30 AM - 5:00 PM',
            'Saturday': '9:00 AM - 12:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Batticaloa Sports Medicine Center',
          'address': '67 Lagoon Road, Batticaloa',
          'phone': '+94 65 2227890',
          'services': [
            'Sports medicine',
            'Physiotherapy',
            'Injury prevention',
            'Performance enhancement'
          ],
          'position': {
            'latitude': 7.7110,
            'longitude': 81.7000,
          },
          'imageUrl': 'https://example.com/images/bsmc.jpg',
          'operatingHours': {
            'Monday': '9:00 AM - 5:00 PM',
            'Tuesday': '9:00 AM - 5:00 PM',
            'Wednesday': '9:00 AM - 5:00 PM',
            'Thursday': '9:00 AM - 5:00 PM',
            'Friday': '9:00 AM - 5:00 PM',
            'Saturday': '9:00 AM - 1:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Ratnapura Athletic Clinic',
          'address': '12 Gem City Road, Ratnapura',
          'phone': '+94 45 2223456',
          'services': [
            'Sports injury care',
            'Rehabilitation',
            'Nutrition counseling',
            'Fitness assessment'
          ],
          'position': {
            'latitude': 6.6837,
            'longitude': 80.4000,
          },
          'imageUrl': 'https://example.com/images/rac.jpg',
          'operatingHours': {
            'Monday': '8:30 AM - 5:30 PM',
            'Tuesday': '8:30 AM - 5:30 PM',
            'Wednesday': '8:30 AM - 5:30 PM',
            'Thursday': '8:30 AM - 5:30 PM',
            'Friday': '8:30 AM - 5:30 PM',
            'Saturday': '9:00 AM - 1:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Matara Sports Health Center',
          'address': '89 Beach Road, Matara',
          'phone': '+94 41 2234567',
          'services': [
            'Sports medicine',
            'Physical therapy',
            'Massage therapy',
            'Injury prevention'
          ],
          'position': {
            'latitude': 5.9549,
            'longitude': 80.5550,
          },
          'imageUrl': 'https://example.com/images/mshc.jpg',
          'operatingHours': {
            'Monday': '8:00 AM - 6:00 PM',
            'Tuesday': '8:00 AM - 6:00 PM',
            'Wednesday': '8:00 AM - 6:00 PM',
            'Thursday': '8:00 AM - 6:00 PM',
            'Friday': '8:00 AM - 6:00 PM',
            'Saturday': '9:00 AM - 2:00 PM',
            'Sunday': 'Closed',
          },
        },
        {
          'name': 'Kurunegala Athletic Facility',
          'address': '45 Clock Tower Road, Kurunegala',
          'phone': '+94 37 2226789',
          'services': [
            'Sports injury treatment',
            'Rehabilitation',
            'Fitness training',
            'Nutritional advice'
          ],
          'position': {
            'latitude': 7.4867,
            'longitude': 80.3647,
          },
          'imageUrl': 'https://example.com/images/kaf.jpg',
          'operatingHours': {
            'Monday': '8:30 AM - 5:00 PM',
            'Tuesday': '8:30 AM - 5:00 PM',
            'Wednesday': '8:30 AM - 5:00 PM',
            'Thursday': '8:30 AM - 5:00 PM',
            'Friday': '8:30 AM - 5:00 PM',
            'Saturday': '9:00 AM - 12:00 PM',
            'Sunday': 'Closed',
          },
        },
      ];

      // Add each health center to the batch
      for (var centerData in healthCentersData) {
        final docRef = healthCentersCollection.doc();
        batch.set(docRef, centerData);
      }

      // Commit the batch
      await batch.commit();
      print('Added ${healthCentersData.length} health centers to the database');
    } catch (e) {
      print('Error adding dummy health centers: $e');
      rethrow;
    }
  }

  // Add dummy educational content
  Future<void> _addDummyEducationalContent() async {
    try {
      final batch = _firestore.batch();
      final educationCollection = _firestore.collection('education');

      // Check if collection already has data
      final existingDocs = await educationCollection.limit(1).get();
      if (existingDocs.docs.isNotEmpty) {
        print('Education collection already has data. Skipping...');
        return;
      }

      // Techniques
      final List<Map<String, dynamic>> techniquesData = [
        {
          'title': 'Perfect Cricket Bowling Technique',
          'description':
              'Learn the perfect bowling technique for cricket, including grip, run-up, and release.',
          'type': 'technique',
          'sport': 'Cricket',
          'level': 'Intermediate',
          'imageUrl': 'https://example.com/images/cricket_bowling.jpg',
          'tags': ['Cricket', 'Bowling', 'Technique', 'Intermediate'],
          'content':
              'Bowling is one of the most important aspects of cricket. A good bowling technique can make you a valuable player on any team. This guide will walk you through the fundamentals of cricket bowling, from grip to follow-through.',
          'steps': [
            {
              'number': 1,
              'title': 'The Grip',
              'description':
                  'Hold the ball with your index and middle fingers on either side of the seam, with your thumb underneath. The seam should be vertical for a fast bowl or angled for spin.',
              'imageUrl': 'https://example.com/images/cricket_grip.jpg',
            },
            {
              'number': 2,
              'title': 'The Run-up',
              'description':
                  'Develop a consistent run-up that builds momentum without causing you to lose control. Start with a walking pace and gradually increase to a comfortable running speed.',
              'imageUrl': 'https://example.com/images/cricket_runup.jpg',
            },
            {
              'number': 3,
              'title': 'The Delivery',
              'description':
                  'As you approach the crease, bring your bowling arm up and over in a windmill motion. Release the ball at the highest point for maximum speed and bounce.',
              'imageUrl': 'https://example.com/images/cricket_delivery.jpg',
            },
            {
              'number': 4,
              'title': 'The Follow-through',
              'description':
                  'Continue your forward momentum after releasing the ball. Your bowling arm should come down across your body, and you should end up in a balanced position.',
              'imageUrl':
                  'https://example.com/images/cricket_followthrough.jpg',
            },
          ],
          'videoUrl': 'https://example.com/videos/cricket_bowling.mp4',
          'author': 'Coach Kumara',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String(),
        },
        {
          'title': 'Football Free Kick Mastery',
          'description':
              'Master the art of taking free kicks in football with proper technique and practice.',
          'type': 'technique',
          'sport': 'Football',
          'level': 'Advanced',
          'imageUrl': 'https://example.com/images/football_freekick.jpg',
          'tags': ['Football', 'Free Kick', 'Technique', 'Advanced'],
          'content':
              'Free kicks are golden opportunities to score in football. With the right technique, you can become your team\'s designated free kick specialist. This guide covers everything from approach to follow-through.',
          'steps': [
            {
              'number': 1,
              'title': 'Positioning',
              'description':
                  'Place the ball carefully and take 3-5 steps back. Position yourself at a slight angle to the ball, depending on whether you want to curve it left or right.',
              'imageUrl': 'https://example.com/images/football_position.jpg',
            },
            {
              'number': 2,
              'title': 'Approach',
              'description':
                  'Take a steady approach to the ball. Your non-kicking foot should be planted beside the ball, pointing toward your target.',
              'imageUrl': 'https://example.com/images/football_approach.jpg',
            },
            {
              'number': 3,
              'title': 'Contact',
              'description':
                  'Strike the ball with the inside or instep of your foot, depending on the type of kick. For a curving shot, hit the ball slightly off-center.',
              'imageUrl': 'https://example.com/images/football_contact.jpg',
            },
            {
              'number': 4,
              'title': 'Follow-through',
              'description':
                  'Follow through in the direction you want the ball to go. Keep your head down and maintain your balance throughout the kick.',
              'imageUrl':
                  'https://example.com/images/football_followthrough.jpg',
            },
          ],
          'videoUrl': 'https://example.com/videos/football_freekick.mp4',
          'author': 'Coach Fernando',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 45))
              .toIso8601String(),
        },
        {
          'title': 'Swimming Freestyle Technique',
          'description':
              'Learn the proper freestyle swimming technique for efficiency and speed in the water.',
          'type': 'technique',
          'sport': 'Swimming',
          'level': 'Beginner',
          'imageUrl': 'https://example.com/images/swimming_freestyle.jpg',
          'tags': ['Swimming', 'Freestyle', 'Technique', 'Beginner'],
          'content':
              'Freestyle is the fastest and most efficient swimming stroke. Mastering proper technique will help you swim faster with less effort. This guide covers body position, arm movement, breathing, and leg kick.',
          'steps': [
            {
              'number': 1,
              'title': 'Body Position',
              'description':
                  'Keep your body horizontal and streamlined in the water. Your head should be in line with your spine, with your face in the water looking down and slightly forward.',
              'imageUrl': 'https://example.com/images/swimming_position.jpg',
            },
            {
              'number': 2,
              'title': 'Arm Movement',
              'description':
                  'Pull with one arm while the other recovers above water. Enter the water with your fingertips first, then pull back in an S-shaped pattern.',
              'imageUrl': 'https://example.com/images/swimming_arms.jpg',
            },
            {
              'number': 3,
              'title': 'Breathing',
              'description':
                  'Turn your head to the side to breathe as one arm recovers. Exhale underwater, then inhale quickly when your mouth clears the surface.',
              'imageUrl': 'https://example.com/images/swimming_breathing.jpg',
            },
            {
              'number': 4,
              'title': 'Leg Kick',
              'description':
                  'Use a flutter kick with straight legs and pointed toes. Kick from your hips, not your knees, with a small amplitude.',
              'imageUrl': 'https://example.com/images/swimming_kick.jpg',
            },
          ],
          'videoUrl': 'https://example.com/videos/swimming_freestyle.mp4',
          'author': 'Coach Perera',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 60))
              .toIso8601String(),
        },
        {
          'title': 'Basketball Jump Shot Technique',
          'description':
              'Perfect your basketball jump shot with proper form and consistent practice.',
          'type': 'technique',
          'sport': 'Basketball',
          'level': 'Intermediate',
          'imageUrl': 'https://example.com/images/basketball_jumpshot.jpg',
          'tags': ['Basketball', 'Jump Shot', 'Technique', 'Intermediate'],
          'content':
              'The jump shot is a fundamental skill in basketball. A consistent jump shot can make you a scoring threat from anywhere on the court. This guide covers stance, grip, release, and follow-through.',
          'steps': [
            {
              'number': 1,
              'title': 'Stance and Grip',
              'description':
                  'Start with your feet shoulder-width apart, knees slightly bent. Hold the ball with your shooting hand under the ball and your guide hand on the side.',
              'imageUrl': 'https://example.com/images/basketball_stance.jpg',
            },
            {
              'number': 2,
              'title': 'The Jump',
              'description':
                  'Bend your knees and explode upward in a straight line. Your jump should be balanced and controlled.',
              'imageUrl': 'https://example.com/images/basketball_jump.jpg',
            },
            {
              'number': 3,
              'title': 'The Release',
              'description':
                  'Release the ball at the peak of your jump. Your shooting arm should extend fully, with the ball rolling off your fingertips.',
              'imageUrl': 'https://example.com/images/basketball_release.jpg',
            },
            {
              'number': 4,
              'title': 'Follow-through',
              'description':
                  'Hold your follow-through with your wrist flexed (like reaching into a cookie jar). Your guide hand should move away from the ball during the release.',
              'imageUrl':
                  'https://example.com/images/basketball_followthrough.jpg',
            },
          ],
          'videoUrl': 'https://example.com/videos/basketball_jumpshot.mp4',
          'author': 'Coach Silva',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 50))
              .toIso8601String(),
        },
        {
          'title': 'Volleyball Spike Technique',
          'description':
              'Learn how to perform a powerful volleyball spike with proper approach and timing.',
          'type': 'technique',
          'sport': 'Volleyball',
          'level': 'Advanced',
          'imageUrl': 'https://example.com/images/volleyball_spike.jpg',
          'tags': ['Volleyball', 'Spike', 'Technique', 'Advanced'],
          'content':
              'The spike is an offensive weapon in volleyball that can score points directly. A good spike combines power, accuracy, and deception. This guide covers approach, timing, arm swing, and landing.',
          'steps': [
            {
              'number': 1,
              'title': 'The Approach',
              'description':
                  'Start with a three or four-step approach. For right-handed players: right, left, right-left (or left, right, left-right for left-handed players).',
              'imageUrl': 'https://example.com/images/volleyball_approach.jpg',
            },
            {
              'number': 2,
              'title': 'The Jump',
              'description':
                  'Plant your feet shoulder-width apart and bend your knees. Swing your arms back, then forward and up as you jump.',
              'imageUrl': 'https://example.com/images/volleyball_jump.jpg',
            },
            {
              'number': 3,
              'title': 'The Arm Swing',
              'description':
                  'Draw your hitting arm back with elbow high. Swing your arm forward and contact the ball at the highest point with an open hand.',
              'imageUrl': 'https://example.com/images/volleyball_swing.jpg',
            },
            {
              'number': 4,
              'title': 'The Landing',
              'description':
                  'Land on both feet with knees bent to absorb the impact. Be ready to transition to the next play immediately.',
              'imageUrl': 'https://example.com/images/volleyball_landing.jpg',
            },
          ],
          'videoUrl': 'https://example.com/videos/volleyball_spike.mp4',
          'author': 'Coach Jayawardena',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 40))
              .toIso8601String(),
        },
      ];

      // Science articles
      final List<Map<String, dynamic>> scienceArticlesData = [
        {
          'title': 'The Physics of Cricket Ball Swing',
          'description':
              'Understand the aerodynamics and physics behind cricket ball swing, including how factors like seam position and air pressure affect movement.',
          'type': 'science',
          'category': 'Physics',
          'imageUrl': 'https://example.com/images/cricket_physics.jpg',
          'tags': ['Cricket', 'Physics', 'Aerodynamics', 'Ball Movement'],
          'content':
              'Cricket ball swing is a fascinating application of fluid dynamics. When a bowler releases the ball with the seam at an angle to the direction of motion, it creates asymmetric air flow around the ball. This difference in air pressure on either side of the ball generates a lateral force, causing the ball to swing in the air.\n\nFactors affecting swing include the condition of the ball (new or old), the position of the seam, the speed of delivery, and atmospheric conditions like humidity and air pressure. Understanding these principles can help bowlers develop more effective techniques for generating swing.',
          'author': 'Dr. Rajapaksa',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 75))
              .toIso8601String(),
        },
        {
          'title': 'Muscle Recovery and Growth in Sports',
          'description':
              'Learn about the biological processes of muscle recovery and growth after training, and how to optimize these processes.',
          'type': 'science',
          'category': 'Biology',
          'imageUrl': 'https://example.com/images/muscle_recovery.jpg',
          'tags': ['Muscle Recovery', 'Biology', 'Training', 'Nutrition'],
          'content':
              'When you exercise, especially with resistance training, you create microscopic tears in your muscle fibers. This damage triggers a repair process that leads to muscle growth and increased strength, a process known as hypertrophy.\n\nThe recovery process involves several phases: inflammation, repair, and remodeling. Proper nutrition, especially protein intake, is crucial during this time. The body needs amino acids to rebuild muscle tissue. Additionally, adequate rest and sleep are essential, as growth hormone is primarily released during deep sleep.\n\nOptimizing recovery involves balancing training intensity with recovery time, consuming sufficient protein and carbohydrates, staying hydrated, and ensuring quality sleep. Active recovery techniques like light exercise and stretching can also enhance the recovery process by increasing blood flow to damaged tissues.',
          'author': 'Dr. Perera',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 90))
              .toIso8601String(),
        },
        {
          'title': 'Nutrition Science for Athletes',
          'description':
              'Explore the science of nutrition for athletes, including macronutrients, micronutrients, and timing of meals for optimal performance.',
          'type': 'science',
          'category': 'Nutrition',
          'imageUrl': 'https://example.com/images/athlete_nutrition.jpg',
          'tags': ['Nutrition', 'Performance', 'Macronutrients', 'Meal Timing'],
          'content':
              'Proper nutrition is a cornerstone of athletic performance. Athletes require a carefully balanced intake of macronutrients (carbohydrates, proteins, and fats) and micronutrients (vitamins and minerals) to fuel their activities and support recovery.\n\nCarbohydrates are the primary energy source for high-intensity exercise. They are stored in muscles and the liver as glycogen, which is rapidly converted to glucose during activity. Protein is essential for muscle repair and growth, while fats provide energy for lower-intensity, longer-duration activities.\n\nMeal timing is also crucial. Pre-workout meals should be rich in carbohydrates and moderate in protein, consumed 2-3 hours before exercise. During prolonged exercise, carbohydrate intake maintains blood glucose levels. Post-workout nutrition should include both carbohydrates and protein within 30-60 minutes after exercise to optimize recovery.\n\nHydration is equally important, as even mild dehydration can significantly impair performance. Athletes should develop individualized hydration strategies based on their sweat rate, exercise duration, and environmental conditions.',
          'author': 'Dr. Fernando',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 60))
              .toIso8601String(),
        },
        {
          'title': 'Biomechanics of Running',
          'description':
              'Understand the biomechanical principles behind efficient running technique and how to prevent common running injuries.',
          'type': 'science',
          'category': 'Biomechanics',
          'imageUrl': 'https://example.com/images/running_biomechanics.jpg',
          'tags': ['Running', 'Biomechanics', 'Injury Prevention', 'Technique'],
          'content':
              'Running is a complex movement involving the coordinated action of multiple muscle groups and joints. Efficient running technique minimizes energy expenditure while reducing the risk of injury.\n\nKey biomechanical factors in running include stride length, cadence (steps per minute), foot strike pattern (forefoot, midfoot, or heel strike), and posture. The optimal combination of these factors varies between individuals based on body structure, flexibility, and strength.\n\nCommon running injuries often result from biomechanical inefficiencies or imbalances. For example, excessive pronation (inward rolling of the foot) can lead to shin splints or knee pain, while overstriding can increase impact forces and stress on joints.\n\nImproving running biomechanics typically involves a combination of technique drills, strength training (particularly core and hip muscles), flexibility work, and gradual adaptation to any changes in running form. Video analysis can be a valuable tool for identifying specific areas for improvement in an individual\'s running mechanics.',
          'author': 'Dr. Dissanayake',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 45))
              .toIso8601String(),
        },
        {
          'title': 'Psychology of Sports Performance',
          'description':
              'Explore the mental aspects of sports performance, including motivation, focus, and strategies for handling pressure.',
          'type': 'science',
          'category': 'Psychology',
          'imageUrl': 'https://example.com/images/sports_psychology.jpg',
          'tags': ['Psychology', 'Mental Training', 'Performance', 'Focus'],
          'content':
              'The psychological component of sports performance is often as important as physical ability. Elite athletes typically possess not only physical talent but also mental skills that allow them to perform consistently under pressure.\n\nKey psychological factors affecting performance include motivation (intrinsic and extrinsic), confidence, focus, emotional control, and resilience. Mental preparation techniques such as goal setting, visualization, positive self-talk, and mindfulness can enhance these factors.\n\nPre-performance routines help athletes establish a consistent mental state before competing. These routines might include visualization, breathing exercises, or specific physical movements that trigger a state of focused readiness.\n\nHandling pressure is a critical skill for competitive athletes. Techniques for managing performance anxiety include reframing nervousness as excitement, focusing on process rather than outcome, and developing acceptance of uncomfortable feelings without letting them affect performance.\n\nMental skills, like physical skills, require consistent practice to develop. Incorporating mental training into regular practice sessions can help athletes build psychological resilience and perform more consistently in competition.',
          'author': 'Dr. Gunawardena',
          'publishDate': DateTime.now()
              .subtract(const Duration(days: 30))
              .toIso8601String(),
        },
      ];

      // Add techniques to the batch
      for (var techniqueData in techniquesData) {
        final docRef = educationCollection.doc();
        batch.set(docRef, techniqueData);
      }

      // Add science articles to the batch
      for (var articleData in scienceArticlesData) {
        final docRef = educationCollection.doc();
        batch.set(docRef, articleData);
      }

      // Commit the batch
      await batch.commit();
      print(
          'Added ${techniquesData.length} techniques and ${scienceArticlesData.length} science articles to the database');
    } catch (e) {
      print('Error adding dummy educational content: $e');
      rethrow;
    }
  }

  // Add dummy notifications
  Future<void> _addDummyNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final notificationsCollection = _firestore.collection('notifications');

      // Check if user already has notifications
      final existingDocs = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        print('User already has notifications. Skipping...');
        return;
      }

      final List<Map<String, dynamic>> notificationsData = [
        {
          'title': 'New Fund Raising Event',
          'message':
              'A new fund raising event for young cricket players has been announced. Check it out!',
          'type': 'fundraising',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': false,
          'imageUrl': 'https://example.com/images/fundraising.jpg',
          'actionUrl': 'https://example.com/events/fundraising',
        },
        {
          'title': 'Upcoming Cricket Match',
          'message':
              'Sri Lanka vs. India cricket match scheduled for next week. Don\'t miss it!',
          'type': 'match',
          'isRead': true,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': true,
          'imageUrl': 'https://example.com/images/cricket_match.jpg',
          'actionUrl': 'https://example.com/matches/sl-vs-india',
        },
        {
          'title': 'New Training Program',
          'message':
              'A new training program for aspiring athletes has been launched at the National Sports Complex.',
          'type': 'training',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': false,
          'imageUrl': 'https://example.com/images/training.jpg',
          'actionUrl': 'https://example.com/training/new-program',
        },
        {
          'title': 'Sports Equipment Donation',
          'message':
              'Sports equipment donation drive for underprivileged athletes. Contribute now!',
          'type': 'donation',
          'isRead': true,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 3))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': true,
          'imageUrl': 'https://example.com/images/donation.jpg',
          'actionUrl': 'https://example.com/donation/equipment',
        },
        {
          'title': 'Sports Science Workshop',
          'message':
              'Attend the upcoming sports science workshop to learn about the latest advancements in sports technology.',
          'type': 'workshop',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 4))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': false,
          'imageUrl': 'https://example.com/images/workshop.jpg',
          'actionUrl': 'https://example.com/workshops/sports-science',
        },
        {
          'title': 'Nutrition Seminar',
          'message':
              'Join our nutrition seminar to learn about optimal diet for athletes.',
          'type': 'workshop',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': false,
          'imageUrl': 'https://example.com/images/nutrition.jpg',
          'actionUrl': 'https://example.com/seminars/nutrition',
        },
        {
          'title': 'Scholarship Opportunity',
          'message':
              'New sports scholarship available for talented young athletes. Apply before the deadline!',
          'type': 'fundraising',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 6))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': true,
          'imageUrl': 'https://example.com/images/scholarship.jpg',
          'actionUrl': 'https://example.com/scholarships/apply',
        },
        {
          'title': 'National Team Selection',
          'message':
              'Trials for the national team selection will be held next month. Register now!',
          'type': 'match',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 7))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': true,
          'imageUrl': 'https://example.com/images/national_team.jpg',
          'actionUrl': 'https://example.com/trials/national-team',
        },
        {
          'title': 'New Health Center',
          'message':
              'A new sports health center has opened in Colombo. Free check-ups available for registered athletes.',
          'type': 'training',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 8))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': false,
          'imageUrl': 'https://example.com/images/health_center.jpg',
          'actionUrl': 'https://example.com/health-centers/new',
        },
        {
          'title': 'App Update Available',
          'message':
              'A new version of the Sri Lanka Sports app is available. Update now for new features!',
          'type': 'system',
          'isRead': false,
          'timestamp': DateTime.now()
              .subtract(const Duration(days: 9))
              .toIso8601String(),
          'userId': userId,
          'isGlobal': true,
          'imageUrl': 'https://example.com/images/app_update.jpg',
          'actionUrl': 'https://example.com/app/update',
        },
      ];

      // Add each notification to the batch
      for (var notificationData in notificationsData) {
        final docRef = notificationsCollection.doc();
        batch.set(docRef, notificationData);
      }

      // Commit the batch
      await batch.commit();
      print('Added ${notificationsData.length} notifications to the database');
    } catch (e) {
      print('Error adding dummy notifications: $e');
      rethrow;
    }
  }

  // Add dummy chat sessions
  Future<void> _addDummyChatSessions(String userId) async {
    try {
      final batch = _firestore.batch();
      final chatSessionsCollection = _firestore.collection('chat_sessions');

      // Check if user already has chat sessions
      final existingDocs = await chatSessionsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (existingDocs.docs.isNotEmpty) {
        print('User already has chat sessions. Skipping...');
        return;
      }

      // Create a chat session with multiple messages
      final String sessionId = _uuid.v4();
      final DateTime now = DateTime.now();

      final List<Map<String, dynamic>> messages = [
        {
          'id': _uuid.v4(),
          'text':
              'Hello! I\'m your Sports Assistant. How can I help you today?',
          'isUser': false,
          'timestamp':
              now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Hi, I\'m interested in improving my cricket batting technique.',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 55))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Great! Batting technique in cricket involves several key elements: stance, grip, backlift, footwork, and follow-through. Which aspect would you like to focus on first?',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 54))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text': 'I think my footwork needs the most improvement.',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 50))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Footwork is crucial in cricket batting. Here are some tips:\n\n1. Always stay balanced and ready to move.\n2. For front foot shots, take a decisive step forward with your front foot towards the pitch of the ball.\n3. For back foot shots, transfer your weight to your back foot quickly.\n4. Practice the quick transfer of weight between feet.\n5. Keep your head still and over the ball when playing shots.\n\nWould you like some specific drills to improve your footwork?',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 48))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text': 'Yes, that would be helpful!',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 45))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Here are three effective drills for improving cricket batting footwork:\n\n1. Shadow Batting: Practice your footwork without a ball. Focus on moving quickly and decisively to imaginary deliveries.\n\n2. Tennis Ball Drill: Have someone bounce tennis balls to you at varying lengths. React with appropriate footwork (front or back) based on the bounce.\n\n3. Cone Drill: Place cones in front and behind your batting position. Based on a coach\'s call, move to touch the appropriate cone and return to batting stance quickly.\n\nPractice these drills for 15-20 minutes daily for best results.',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 43))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Thanks! I\'ll try these drills. What about playing against spin bowling specifically?',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 40))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Playing spin bowling requires specialized footwork techniques:\n\n1. Use your feet to get to the pitch of the ball - either fully forward or back.\n2. Watch the ball from the bowler\'s hand to read the spin.\n3. For attacking shots, commit to coming down the pitch early.\n4. For defensive play, ensure your pad and bat move together to avoid LBW.\n5. Practice using your feet to disrupt the bowler\'s length.\n\nA good drill is to have someone throw balls that spin on a rough surface, forcing you to read the spin and adjust your footwork accordingly.',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 38))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'That\'s really helpful information. I\'ll work on these techniques.',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 35))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Glad I could help! Remember that consistent practice is key to improving your footwork. Start with these drills and gradually increase the difficulty as you improve. Is there anything else you\'d like to know about cricket batting technique?',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(days: 1, hours: 1, minutes: 33))
              .toIso8601String(),
        },
      ];

      // Create the chat session document
      final chatSessionData = {
        'id': sessionId,
        'userId': userId,
        'messages': messages,
        'createdAt':
            now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
        'lastUpdatedAt': now
            .subtract(const Duration(days: 1, hours: 1, minutes: 33))
            .toIso8601String(),
      };

      // Add the chat session to the batch
      batch.set(chatSessionsCollection.doc(sessionId), chatSessionData);

      // Create a second chat session with different topic
      final String sessionId2 = _uuid.v4();

      final List<Map<String, dynamic>> messages2 = [
        {
          'id': _uuid.v4(),
          'text':
              'Hello! I\'m your Sports Assistant. How can I help you today?',
          'isUser': false,
          'timestamp': now.subtract(const Duration(hours: 5)).toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text': 'I need advice on nutrition for marathon training.',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(hours: 4, minutes: 58))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Marathon training requires careful nutrition planning. Here are some key principles:\n\n1. Carbohydrates: Should make up 60-70% of your diet to fuel long runs.\n2. Protein: Aim for 1.2-1.4g per kg of body weight daily for muscle repair.\n3. Hydration: Drink water consistently throughout the day, not just during runs.\n4. Pre-run nutrition: Eat easily digestible carbs 1-3 hours before running.\n5. Post-run recovery: Consume carbs and protein within 30 minutes after running.\n\nWould you like more specific meal suggestions?',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(hours: 4, minutes: 56))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text': 'Yes, some meal ideas would be great!',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(hours: 4, minutes: 53))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'Here are some meal ideas for marathon training:\n\nBreakfast options:\n- Oatmeal with banana, honey, and nuts\n- Whole grain toast with eggs and avocado\n- Smoothie with Greek yogurt, fruits, and nut butter\n\nLunch options:\n- Quinoa bowl with vegetables and grilled chicken\n- Whole grain pasta with lean protein and vegetables\n- Sweet potato with tuna and salad\n\nDinner options:\n- Brown rice with fish and steamed vegetables\n- Lean meat with roasted vegetables and whole grains\n- Bean and vegetable stir-fry with brown rice\n\nSnacks:\n- Greek yogurt with berries\n- Banana with nut butter\n- Trail mix with dried fruits and nuts\n\nRemember to adjust portions based on your training intensity and body weight.',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(hours: 4, minutes: 50))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text': 'What about nutrition during the actual marathon?',
          'isUser': true,
          'timestamp': now
              .subtract(const Duration(hours: 4, minutes: 47))
              .toIso8601String(),
        },
        {
          'id': _uuid.v4(),
          'text':
              'During a marathon, nutrition is critical for performance. Here\'s what you need to know:\n\n1. Carbohydrate intake: Aim for 30-60g of carbs per hour during the race.\n2. Hydration: Drink 400-800ml of fluid per hour, depending on temperature and sweat rate.\n3. Electrolytes: Use sports drinks or electrolyte tablets to replace sodium lost through sweat.\n4. Energy gels/chews: These provide quick carbs; practice with them during training.\n5. Timing: Start fueling early (around 45-60 minutes in) and continue at regular intervals.\n\nMost importantly, never try anything new on race day! Practice your nutrition strategy during long training runs to find what works best for you.',
          'isUser': false,
          'timestamp': now
              .subtract(const Duration(hours: 4, minutes: 45))
              .toIso8601String(),
        },
      ];

      // Create the second chat session document
      final chatSessionData2 = {
        'id': sessionId2,
        'userId': userId,
        'messages': messages2,
        'createdAt': now.subtract(const Duration(hours: 5)).toIso8601String(),
        'lastUpdatedAt': now
            .subtract(const Duration(hours: 4, minutes: 45))
            .toIso8601String(),
      };

      // Add the second chat session to the batch
      batch.set(chatSessionsCollection.doc(sessionId2), chatSessionData2);

      // Commit the batch
      await batch.commit();
      print('Added 2 chat sessions with multiple messages to the database');
    } catch (e) {
      print('Error adding dummy chat sessions: $e');
      rethrow;
    }
  }

  // Add dummy equipment data
  Future<void> _addDummyEquipment() async {
    try {
      final batch = _firestore.batch();
      final equipmentCollection = _firestore.collection('equipment');

      // Check if collection already has data
      final existingDocs = await equipmentCollection.limit(1).get();
      if (existingDocs.docs.isNotEmpty) {
        print('Equipment collection already has data. Skipping...');
        return;
      }

      final List<Map<String, dynamic>> equipmentData = [
        {
          'name': 'Kookaburra Cricket Bat',
          'price': 'Rs. 15,000',
          'store': 'SportsSL.com',
          'rating': 4.5,
          'imageUrl': 'https://example.com/images/cricket_bat.jpg',
          'url': 'https://sportsslcom/cricket-bat',
          'tags': ['Cricket', 'Professional', 'Equipment'],
          'category': 'Cricket',
        },
        {
          'name': 'Adidas Football Shoes',
          'price': 'Rs. 8,500',
          'store': 'SportsEquipment.lk',
          'rating': 4.2,
          'imageUrl': 'https://example.com/images/football_shoes.jpg',
          'url': 'https://sportsequipment.lk/adidas-shoes',
          'tags': ['Football', 'Professional', 'Shoes'],
          'category': 'Football',
        },
        {
          'name': 'Swimming Goggles Pro',
          'price': 'Rs. 3,200',
          'store': 'AquaticsSL.com',
          'rating': 4.7,
          'imageUrl': 'https://example.com/images/goggles.jpg',
          'url': 'https://aquaticsslcom/goggles',
          'tags': ['Swimming', 'Professional', 'Accessories'],
          'category': 'Swimming',
        },
        {
          'name': 'Protein Supplement',
          'price': 'Rs. 5,500',
          'store': 'HealthSL.com',
          'rating': 4.3,
          'imageUrl': 'https://example.com/images/protein.jpg',
          'url': 'https://healthsl.com/protein',
          'tags': ['Nutrition', 'Supplement'],
          'category': 'Nutrition',
        },
        {
          'name': 'Running Shoes',
          'price': 'Rs. 7,200',
          'store': 'SportsEquipment.lk',
          'rating': 4.6,
          'imageUrl': 'https://example.com/images/running_shoes.jpg',
          'url': 'https://sportsequipment.lk/running-shoes',
          'tags': ['Running', 'Shoes'],
          'category': 'Running',
        },
        {
          'name': 'Basketball',
          'price': 'Rs. 4,500',
          'store': 'SportsSL.com',
          'rating': 4.4,
          'imageUrl': 'https://example.com/images/basketball.jpg',
          'url': 'https://sportsslcom/basketball',
          'tags': ['Basketball', 'Equipment'],
          'category': 'Basketball',
        },
        {
          'name': 'Tennis Racket',
          'price': 'Rs. 9,800',
          'store': 'SportsEquipment.lk',
          'rating': 4.8,
          'imageUrl': 'https://example.com/images/tennis_racket.jpg',
          'url': 'https://sportsequipment.lk/tennis-racket',
          'tags': ['Tennis', 'Professional', 'Equipment'],
          'category': 'Tennis',
        },
        {
          'name': 'Volleyball',
          'price': 'Rs. 3,800',
          'store': 'SportsSL.com',
          'rating': 4.3,
          'imageUrl': 'https://example.com/images/volleyball.jpg',
          'url': 'https://sportsslcom/volleyball',
          'tags': ['Volleyball', 'Equipment'],
          'category': 'Volleyball',
        },
        {
          'name': 'Badminton Racket Set',
          'price': 'Rs. 6,500',
          'store': 'SportsEquipment.lk',
          'rating': 4.5,
          'imageUrl': 'https://example.com/images/badminton_set.jpg',
          'url': 'https://sportsequipment.lk/badminton-set',
          'tags': ['Badminton', 'Equipment', 'Set'],
          'category': 'Badminton',
        },
        {
          'name': 'Rugby Ball',
          'price': 'Rs. 4,200',
          'store': 'SportsSL.com',
          'rating': 4.4,
          'imageUrl': 'https://example.com/images/rugby_ball.jpg',
          'url': 'https://sportsslcom/rugby-ball',
          'tags': ['Rugby', 'Equipment'],
          'category': 'Rugby',
        },
        {
          'name': 'Yoga Mat',
          'price': 'Rs. 2,500',
          'store': 'HealthSL.com',
          'rating': 4.7,
          'imageUrl': 'https://example.com/images/yoga_mat.jpg',
          'url': 'https://healthsl.com/yoga-mat',
          'tags': ['Yoga', 'Accessories'],
          'category': 'Yoga',
        },
        {
          'name': 'Cricket Helmet',
          'price': 'Rs. 7,800',
          'store': 'SportsSL.com',
          'rating': 4.6,
          'imageUrl': 'https://example.com/images/cricket_helmet.jpg',
          'url': 'https://sportsslcom/cricket-helmet',
          'tags': ['Cricket', 'Protection', 'Equipment'],
          'category': 'Cricket',
        },
      ];

      // Add each equipment item to the batch
      for (var item in equipmentData) {
        final docRef = equipmentCollection.doc();
        batch.set(docRef, item);
      }

      // Commit the batch
      await batch.commit();
      print('Added ${equipmentData.length} equipment items to the database');
    } catch (e) {
      print('Error adding dummy equipment: $e');
      rethrow;
    }
  }
}

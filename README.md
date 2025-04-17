# Sri Lanka Sports Development Mobile App

A comprehensive mobile application designed to support talented individuals in sports across Sri Lanka. This app connects students and sports enthusiasts with resources, facilities, and knowledge to help them develop their sporting potential.

## 📱 Features

### For All Users

- **Sport Finder**: Get personalized sport recommendations based on your physical attributes and preferences
- **Equipment Finder**: Locate sports equipment and medicine from trusted vendors
- **AI Sports Assistant**: Chat with an AI assistant for sports-related questions and guidance
- **Sports Education**: Access techniques, science, and educational content about various sports
- **Notifications**: Receive updates about events, training programs, and opportunities


### For Sportspersons (Verified)

- **Health Centers Map**: Find sports medicine centers and health facilities on an interactive map
- **Verified Profile**: Get a verified sportsperson status with NIC verification


## 🛠️ Technologies Used

- **Flutter**: Cross-platform UI toolkit for building natively compiled applications
- **Firebase**:

- Authentication for user management
- Firestore for database


- **OpenStreetMap**: Free map integration via flutter_map package
- **Location Services**: For geolocation features
- **AI Integration**: For the sports assistant chatbot


## 📋 Requirements

- Flutter SDK (2.19.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase project setup
- Android SDK / Xcode (for iOS development)


## 🚀 Installation

1. **Clone the repository**

```shellscript
git clone https://github.com/yourusername/sri_lanka_sports_app.git
cd sri_lanka_sports_app
```


2. **Install dependencies**

```shellscript
flutter pub get
```


3. **Firebase Setup**

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download and add the configuration files:

1. `google-services.json` (for Android)
2. `GoogleService-Info.plist` (for iOS)



4. Enable Authentication, and Firestore in Firebase Console



4. **Google Maps Setup (Optional)**

1. If using Google Maps instead of OpenStreetMap, obtain a Google Maps API key
2. Add the key to `android/app/src/main/AndroidManifest.xml` and `ios/Runner/AppDelegate.swift`



5. **Run the app**

```shellscript
flutter run
```




## 📱 Usage

### User Registration

1. Open the app and click "Sign Up" on the login screen
2. Fill in your details and select your role (Student or Sports Person)
3. For Sports Persons, provide your NIC number and take a photo of your NIC for verification
4. Complete the registration process


### Finding Your Sport

1. Navigate to the "Find Your Sport" section
2. Fill in your physical attributes and preferences
3. Get personalized sport recommendations based on your profile


### Locating Health Centers

1. Go to the "Health Centers" section (available for verified sports persons)
2. View health centers on the map
3. Tap on a marker to see details about the center
4. Use the list view to browse all centers


### Using the Sports Assistant

1. Navigate to the "Sports Assistant" section
2. Type your sports-related questions
3. Get instant answers and guidance from the AI assistant


## 📁 Project Structure

```plaintext
lib/
├── main.dart                  # App entry point
├── models/                    # Data models
│   └── user_model.dart        # User data model
├── screens/                   # UI screens
│   ├── auth/                  # Authentication screens
│   ├── features/              # Feature screens
│   ├── home/                  # Home screen
│   └── profile/               # Profile screens
├── services/                  # Services
│   └── auth_service.dart      # Authentication service
├── utils/                     # Utilities
│   └── app_theme.dart         # App theming
└── widgets/                   # Reusable widgets
    ├── custom_button.dart     # Custom button widget
    └── custom_text_field.dart # Custom text field widget
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request


## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Contact

For any inquiries or support, please contact:

- Email: [your.email@example.com](mailto:your.email@example.com)
- Website: [https://example.com](https://example.com)


---

Made with ❤️ for Sri Lankan sports development

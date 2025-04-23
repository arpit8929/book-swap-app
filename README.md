# Book Swap App

A Flutter application that helps people find and swap books with others in their area. The app provides features for listing books, searching, favoriting, and messaging with other users.

## Features

- User authentication (email/password)
- Book listing and management
- Search and filter books
- Favorite books
- Real-time messaging
- User profiles
- Location-based book discovery
- Book condition tracking
- Genre categorization

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Android Studio / VS Code
- Firebase account

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/book_swap.git
   ```

2. Navigate to the project directory:
   ```bash
   cd book_swap
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Set up Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download and add the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
   - Enable Authentication (Email/Password)
   - Create Firestore database
   - Set up security rules for Firestore

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
  ├── constants/
  │   └── theme.dart
  ├── models/
  │   └── book.dart
  ├── providers/
  │   └── app_provider.dart
  ├── screens/
  │   ├── auth/
  │   │   ├── login_screen.dart
  │   │   └── register_screen.dart
  │   ├── home_screen.dart
  │   ├── favorites_screen.dart
  │   ├── messages_screen.dart
  │   └── profile_screen.dart
  ├── services/
  │   ├── auth_service.dart
  │   ├── book_service.dart
  │   └── chat_service.dart
  └── main.dart
```

## Dependencies

- firebase_core: ^2.24.2
- firebase_auth: ^4.15.3
- cloud_firestore: ^4.13.6
- provider: ^6.1.1
- cached_network_image: ^3.3.0
- flutter_svg: ^2.0.9
- google_fonts: ^6.1.0
- image_picker: ^1.0.5
- shared_preferences: ^2.2.2
- flutter_chat_ui: ^1.6.10
- intl: ^0.18.1
- geolocator: ^10.1.0
- google_maps_flutter: ^2.5.0

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- All contributors who help improve this project 
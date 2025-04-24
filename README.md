# Book Swap App

## Overview
Book Swap is a Flutter-based mobile application that facilitates book sharing within local communities. Users can discover, list, and swap books with others in their area, making reading more accessible and sustainable.

## Features

### 1. Authentication
- Email and password-based authentication
- Secure user sessions
- Profile management
- Firebase authentication integration
![WhatsApp Image 2025-04-24 at 08 56 09_75538eff](https://github.com/user-attachments/assets/f9c3ccf7-4d29-4e23-95d7-7c15701168ab)
![WhatsApp Image 2025-04-24 at 08 56 10_2f49abd8](https://github.com/user-attachments/assets/62fe8c89-e2c0-4f4f-a129-4b3d08dcccb2)
![WhatsApp Image 2025-04-24 at 08 56 10_715fcb57](https://github.com/user-attachments/assets/4b19a5d1-3dfa-4942-b39b-5e611ad46a98)


### 2. Book Management
- List books for swapping
- Detailed book information including:
  - Title and author
  - owner
  - Condition
  - Genre categorization
- Search and filter functionality
- Book status tracking
![WhatsApp Image 2025-04-24 at 09 07 54_2c9d5914](https://github.com/user-attachments/assets/3ff2218c-3429-4501-b76c-fc30ad1aa54c)
![WhatsApp Image 2025-04-24 at 09 07 55_872682ee](https://github.com/user-attachments/assets/3d2d057a-7009-42f3-bb6b-3cba04c8d7c8)
![WhatsApp Image 2025-04-24 at 09 07 54_2c0f28b7](https://github.com/user-attachments/assets/03b6b983-af06-4f40-8919-94eddb438144)
![WhatsApp Image 2025-04-24 at 09 07 54_651cf970](https://github.com/user-attachments/assets/18bb6098-87ca-447e-a781-9410725dd1ee)


### 3. Social Features
- Real-time messaging between users
- Location-based book discovery
- Favorite books system
![WhatsApp Image 2025-04-24 at 09 10 31_7b71c65b](https://github.com/user-attachments/assets/f65c480a-d399-430d-8765-ea3e931ae91b)
![WhatsApp Image 2025-04-24 at 09 10 30_81dd1a42](https://github.com/user-attachments/assets/e9440813-5d1e-4ac2-99d3-efa79ec4858f)
![WhatsApp Image 2025-04-24 at 09 10 31_c68a02b2](https://github.com/user-attachments/assets/ebcc24b0-5b63-4991-b5e1-d523b4a10b84)
![WhatsApp Image 2025-04-24 at 09 10 31_deb09e84](https://github.com/user-attachments/assets/df693ea3-2f42-4c53-bd2b-4c4b6a9fed1f)


### 4. User Interface
- Intuitive navigation
- Dark/Light theme support
- Responsive design
- Location services integration
![WhatsApp Image 2025-04-24 at 09 12 35_2826ce1b](https://github.com/user-attachments/assets/72ac9fd2-888d-419d-a58e-68fe58eb5db4)
![WhatsApp Image 2025-04-24 at 09 12 35_5bfd2e67](https://github.com/user-attachments/assets/d7a261a3-18e0-4572-b956-1fffda9bb09f)
![WhatsApp Image 2025-04-24 at 09 12 34_4c508a78](https://github.com/user-attachments/assets/3d9d5ad4-ac18-4898-a96a-7aa410c822fa)


## Technical Stack

### Frontend
- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Provider
- **UI Components**: Material Design

### Backend
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Storage**: Firebase Storage
- **Location Services**: Google Maps

### Dependencies
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  provider: ^6.1.1
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  google_fonts: ^6.1.0
  image_picker: ^1.0.5
  shared_preferences: ^2.2.2
  flutter_chat_ui: ^1.6.10
  intl: ^0.18.1
  geolocator: ^10.1.0
  google_maps_flutter: ^2.5.0
```

## Project Structure
```
lib/
  ├── constants/      # App-wide constants and theme
  │   └── theme.dart
  ├── models/         # Data models
  │   └── book.dart
  ├── providers/      # State management
  │   └── app_provider.dart
  ├── screens/        # UI screens
  │   ├── auth/
  │   │   ├── login_screen.dart
  │   │   └── register_screen.dart
  │   ├── home_screen.dart
  │   ├── favorites_screen.dart
  │   ├── messages_screen.dart
  │   └── profile_screen.dart
  ├── services/       # Business logic
  │   ├── auth_service.dart
  │   ├── book_service.dart
  │   └── chat_service.dart
  └── main.dart
```

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

2. Navigate to project directory:
   ```bash
   cd book_swap
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Configure Firebase:
   - Create a Firebase project
   - Add Android & iOS apps
   - Download configuration files
   - Enable Authentication
   - Set up Firestore
   - Configure security rules

5. Run the app:
   ```bash
   flutter run
   ```

## Contributing
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Flutter team for the framework
- Firebase for backend services

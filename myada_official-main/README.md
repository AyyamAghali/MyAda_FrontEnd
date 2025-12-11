# MyADA Official

MyADA Official - Digital Student/Teacher ID and Campus Resource Management System with NFC support.

## Project Overview

MyADA is a mobile application designed for educational institutions that enables digital student/teacher identification, room management, and attendance tracking. The application leverages NFC technology to allow devices to function as contactless ID cards for campus access.

## Key Features

- **Digital ID Cards**: Replace physical ID cards with smartphone-based identification
- **NFC Emulation**: Contactless entry using Host Card Emulation (HCE) technology
- **Role-Based Access**: Different interfaces and permissions for students and teachers
- **Room Reservation**: View and book available rooms across campus buildings
- **Attendance Tracking**: Monitor room access and attendance logs
- **User Authentication**: Secure login with institutional credentials

## Architecture

MyADA follows a structured architecture combining Provider pattern for state management with GetX for navigation:

### Layers

1. **Presentation Layer**
   - Auth Screens (Login, Onboarding)
   - Home Screens (Student, Teacher)
   - Feature Screens (Room Reservation, My Room)

2. **State Management Layer**
   - Provider for screen-specific state management
   - GetX for navigation and dependency injection

3. **Service Layer**
   - ApiService: HTTP client handling all API communications
   - AuthService: Authentication state management
   - ApduService: NFC/HCE implementation

4. **Core Layer**
   - Models: Data structures (User, Personal Info)
   - Utils: Helper functions and utilities
   - Theme: Application styling

## Business Logic

### NFC Functionality
- HCE implementation enables device to emulate student/teacher ID cards
- UID (unique identifier) is transmitted to card readers via the ApduService
- Service lifecycle is managed automatically during login/logout
- Comprehensive error handling for device compatibility and service activation

### Authentication System
- Secure login process with credential validation
- Role determination (student/teacher) based on group_id from API
- Token-based authentication with persistent sessions
- Automatic NFC service activation upon successful login

### Room Management System
- Building and room data hierarchical structure
- Comprehensive reservation filtering (building, room, date, user)
- Date-based grouping and presentation of reservations
- Real-time availability checking

### Attendance Tracking
- Room-specific attendance logs with user identification
- Date range filtering with calendar integration
- Detailed attendance records with timestamp information
- Pull-to-refresh functionality for real-time updates

## Getting Started

### Prerequisites

- **Flutter SDK**: 2.5.0 or higher [Installation Guide](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with Flutter plugins
- **Android device** with NFC support for HCE functionality (Android 4.4+)
- **iOS device** (Note: NFC card emulation is only supported on Android)

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Kenterum/myada_official.git
   cd myada_official
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint** (if needed)
   - Open `lib/core/network/api_service.dart`
   - Update the `baseUrl` constant with your backend API URL

4. **Important Note for Android Studio users**
   - When opening the project in Android Studio, open it as an Android project rather than a Flutter project to avoid issues with Java code
   - Navigate to the android folder and open it directly if you need to modify native Android code

5. **Run the application**
   ```bash
   flutter run
   ```

### Testing NFC Functionality

NFC functionality requires an Android device with HCE support:

1. Ensure NFC is enabled in your device settings
2. Log in to the application with valid credentials
3. The NFC service will automatically activate
4. Present your device to compatible NFC readers
5. You can manually toggle the NFC service from the ID card screen

## API Integration

The application communicates with a RESTful API with these primary endpoints:

### Authentication
- `POST /login_app`: User login with email/password

### Room Management
- `GET /getAllBuildings`: Retrieve all campus buildings
- `GET /getAllRoomsByBuildingId/{id}`: Get rooms in a specific building
- `GET /getAllReservationLogs`: Get room reservations with filtering options

### Attendance
- `GET /whoEnteredMyRoom`: Retrieve room entry logs with date filtering

## Project Structure

```
lib/
├── core/                         # Core functionality
│   ├── models/                   # Data models
│   │   └── user_model.dart       # User and personal info models
│   ├── network/                  # API communication
│   │   └── api_service.dart      # HTTP client and endpoints
│   ├── services/                 # Business logic services
│   │   ├── apdu_service.dart     # NFC/HCE implementation
│   │   └── auth_service.dart     # Authentication management  
│   └── utils/                    # Utility functions
├── presentation/                 # UI components
│   ├── auth/                     # Authentication screens
│   ├── home/                     # Home screens (student/teacher)
│   └── features/                 # Feature screens
│       ├── my_room_screen/       # Room attendance tracking
│       └── room_reservation_screen/ # Room booking system
├── routes/                       # Navigation routes
├── theme/                        # Styling and theming
└── widgets/                      # Reusable UI components
```

## Troubleshooting

### NFC Issues
- **NFC Not Working**: Ensure NFC is enabled in device settings
- **Compatibility Error**: Verify device supports HCE (Android 4.4+)
- **Service Activation**: Check for error messages in console logs
- **Reader Communication**: Ensure proper placement against NFC reader

### Authentication Issues
- **Login Failures**: Verify correct email/password combination
- **Session Expiration**: Automatic redirection to login screen
- **Role Access**: Contact administrator if assigned incorrect role

### API Connection Issues
- **Network Errors**: Check internet connectivity
- **Server Response**: Application handles and displays server errors
- **HTML Responses**: If you see "Server returned HTML" errors, check API configuration

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

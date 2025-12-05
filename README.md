# ADA University Mobile App

A Flutter application for ADA University providing Lost & Found, Club Management, and IT Support services.

## Features

- **Lost & Found**: Browse, search, and report lost/found items on campus
- **Club Management**: Discover and manage student clubs
- **IT & Technical Support**: Submit and track support tickets

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd myADA_front
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── lost_item.dart
│   ├── club.dart
│   └── user_role.dart
├── screens/                  # Screen widgets
│   ├── master_home_page.dart
│   ├── lost_found/
│   ├── clubs/
│   └── support/
├── widgets/                   # Reusable widgets
│   ├── status_bar.dart
│   ├── responsive_container.dart
│   └── item_card.dart
└── utils/                     # Utilities
    ├── constants.dart
    └── responsive.dart
```

## Responsive Design

The app is built with responsive design principles:
- Mobile-first approach (max-width: 430px)
- Tablet support (600px - 1200px)
- Desktop support (1200px+)
- Adaptive layouts using `ResponsiveContainer` widget

## Dependencies

- `cached_network_image`: For efficient image loading
- `intl`: For date/time formatting
- `image_picker`: For image selection
- `url_launcher`: For opening external links

## Building

### Android
```bash
flutter build apk
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

## License

This project is for ADA University internal use.

# MyAda_FrontEnd
# MyAda_FrontEnd

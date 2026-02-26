# Philosophers Cleaners App

A Flutter application with authentication and main screen functionality.

## Features

- **Splash Screen**: Beautiful animated splash screen that checks for existing authentication
- **Registration**: Complete registration form with all required fields
- **Login**: Secure login with email and password
- **Main Screen**: List view with data fetched from API
- **Secure Storage**: Tokens stored securely using flutter_secure_storage
- **API Integration**: Ready to connect with FastAPI backend

## Setup

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-api-url:8000';
```

3. Run the app:
```bash
flutter run
```

## API Endpoints

The app expects the following FastAPI endpoints:

- `POST /auth/register` - User registration
- `POST /auth/login` - User login (returns access_token and token_type)
- `POST /api/orders` - Submit laundry order with:
  - `service_id`, `service_name`, `clothes_type`, `quantity`, `size`
  - `drop_box_id` (from QR scan), `client_email`

## Registration Fields

- first_name (required)
- last_name (required)
- email (required)
- number (optional)
- address (optional)
- user_role (required: admin, user, or cleaner)
- password (required)

## Login Response

The login endpoint should return:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

The access token is automatically stored securely and used for all subsequent authenticated requests.

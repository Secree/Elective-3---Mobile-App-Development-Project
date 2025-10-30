# Flight Reserve App

This is a Flutter project that lets users search and reserve flights in the Philippines.

## Features

✅ **Flight Search** - Browse real-time flight schedules for Philippine airports
✅ **User Authentication** - Secure login and signup with Firebase
✅ **Flight Reservations** - Book and manage your flight reservations
✅ **Philippine Airlines Focus** - Support for major Philippine airports including:
  - MNL (Manila - Ninoy Aquino International)
  - CEB (Cebu - Mactan-Cebu International)
  - DVO (Davao - Francisco Bangoy International)
  - CRK (Clark International Airport)
  - ILO (Iloilo International Airport)
  - And more!

## Prerequisites
- Install the Flutter SDK and ensure `flutter` is on your PATH.
- An Android device, iOS simulator, or web browser for testing.

## Quick start (PowerShell on Windows):

```powershell
# Navigate to project root
cd "c:\Users\Pc\OneDrive\Documents\GitHub\Elective-3---Mobile-App-Development-Project"

# Get dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome

# Or run on an Android device/emulator
flutter run -d android
```

## How to Use

1. **Login/Sign Up** - Create an account or login to access flight search
2. **Search Flights** - Click "Search Flights" on the home page
3. **Browse Flights** - View available flights between Philippine airports
4. **Filter Results** - Search by departure and arrival airports (e.g., MNL, CEB, DVO)
5. **View Details** - Tap any flight to see detailed information
6. **Book Flight** - Click "Book This Flight" to make a reservation

## API Integration (Optional)

The app currently uses mock flight data. To integrate with real flight data:

1. Sign up for a free API key at [AviationStack](https://aviationstack.com/)
2. Open `lib/services/flight_service.dart`
3. Uncomment the import statements and API constants at the top
4. Replace `YOUR_API_KEY_HERE` with your actual API key
5. Uncomment the real API call in the `searchFlights` method

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── models/
│   └── flight.dart           # Flight data model
├── services/
│   └── flight_service.dart   # Flight API service
├── screens/
│   ├── home_page.dart        # Landing page
│   ├── flight_search_page.dart # Flight search interface
│   ├── login_page.dart       # User login
│   ├── signup_page.dart      # User registration
│   ├── reserve_page.dart     # Make reservations
│   └── flight_details_page.dart # Reservation details
└── db/
    ├── user_db.dart          # User database
    └── reservation_db.dart   # Reservation database
```

## Technologies Used

- **Flutter** - Cross-platform UI framework
- **Firebase** - Authentication and Firestore database
- **Google Fonts** - Typography (Urbanist font family)
- **HTTP** - API integration for flight data

## Currently in Progress

- Enhanced flight filtering options
- Payment integration
- Booking confirmation emails
- Multi-language support

---

If you don't have Flutter installed yet, download it from https://flutter.dev and follow the setup instructions.


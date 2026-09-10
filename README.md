# 🍳 Complete Recipe App (Flutter + Firebase + Provider)

A full-featured, production-ready Recipe Application built with Flutter, Firebase Authentication (including Google Sign-In and Guest mode), Cloud Firestore, and Provider state management. Replicates the exact UI/UX and interaction patterns from the complete recipe tutorial video by **WTF Code**.

---

## ✨ Features

- 🔐 **Authentication & Google Sign-In**:
  - Sign in with Google account or explore instantly in Guest Mode.
  - User session persistence and secure Sign Out flow.
- 🏠 **Explore & Categories (Home Screen)**:
  - Header greeting: *"What are you cooking today?"*.
  - Live Recipe Search Bar with instant query filtering.
  - Promotional explore banner with chef illustration.
  - Dynamic category pills (`App-Category`: Breakfast, Lunch, Dinner, Salads, Dessert, etc.) with active selection indicator.
  - "Quick & Easy" horizontal scrolling carousel with detailed recipe cards.
- 📖 **Dynamic Recipe Details & Servings Scaler**:
  - Full-width hero image header with curved overlay sheet and drag handle.
  - Badges for Calories (`Iconsax.flash_1`), Cook Time (`Iconsax.clock`), and Ratings (`Iconsax.star1`).
  - **Dynamic Servings Calculator**: Tap `+` or `-` to scale the serving size. All ingredient quantities automatically recalculate in real-time!
  - 3-column ingredient breakdown with food thumbnails, ingredient names, and scaled gram measurements.
  - Bottom docked action bar: "Start Cooking" and circular bookmark heart button.
- ❤️ **Personalized Favorites**:
  - Real-time Firestore sync (`userFavorite` / user-scoped).
  - Tap the heart on any card or detail screen to instantly add/remove.
  - List of favorites with recipe stats and delete buttons.
- 📅 **Meal Planner**:
  - Day-by-day scheduler (Monday to Sunday) with planned meals for Breakfast, Lunch, and Dinner.
  - Calorie totals and quick check-off actions.
- ⚙️ **Profile & Settings**:
  - Displays user avatar, display name, email, and Google/Guest badge.
  - Notification toggles, measurement unit options, and Sign Out confirmation modal.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart SDK >= 3.4.4)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`ChangeNotifierProvider`, `MultiProvider`)
- **Backend / Database**: [Cloud Firestore](https://pub.dev/packages/cloud_firestore)
- **Authentication**: [Firebase Auth](https://pub.dev/packages/firebase_auth) & [Google Sign In](https://pub.dev/packages/google_sign_in)
- **Icons**: [Iconsax](https://pub.dev/packages/iconsax) & Cupertino Icons

---

## 📁 Project Structure

```
lib/
├── main.dart                      # Application entry point & MultiProvider configuration
├── Utils/
│   └── constants.dart             # App color constants (kbackgroundColor, kprimaryColor, kBannerColor)
├── models/
│   ├── recipe_model.dart          # Recipe model with Firestore deserialization
│   └── category_model.dart        # Category model for filter pills
├── Provider/
│   ├── auth_provider.dart         # Google Sign-In & Auth state manager
│   ├── favorite_provider.dart     # Firestore-backed favorites manager
│   └── quantity.dart              # Servings counter & ingredient scaling provider
├── services/
│   └── mock_data_service.dart     # Recipe catalog & automatic Firestore seeder
├── Views/
│   ├── auth_gate.dart             # Dynamic router between Login & Main App
│   ├── login_screen.dart          # Branded Google & Guest sign-in page
│   ├── app_main_screen.dart       # Main shell with 4-tab BottomNavigationBar
│   ├── my_app_home_screen.dart    # Home page with banner, search, & categories
│   ├── recipe_detail_screen.dart  # Recipe details & dynamic servings calculator
│   ├── favorite_screen.dart       # Bookmarked recipes list
│   ├── meal_plan_screen.dart      # Day-by-day meal schedule
│   ├── profile_screen.dart        # Profile details & settings
│   └── view_all_items.dart        # 2-column GridView of all recipes
└── Widget/
    ├── banner.dart                # Promotional explore banner
    ├── food_items_display.dart    # Recipe card with heart favorite button
    ├── my_icon_button.dart        # 50x50 rounded square icon button
    └── quantity_increment_decrement.dart # Servings (+ / -) stepper
```

---

## 🚀 Getting Started

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- An Android/iOS device, emulator, or Chrome browser.

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/<your-username>/<your-repo-name>.git
cd recipe_app2

# Install packages
flutter pub get
```

### 3. Firebase Configuration (Optional for real cloud data)
The app runs out-of-the-box with built-in mock data and guest mode. To connect your live Firebase project:
1. Create a project on [Firebase Console](https://console.firebase.google.com).
2. Enable **Authentication** (Google & Anonymous providers).
3. Enable **Cloud Firestore** (in test mode or configure security rules).
4. Run FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Or place your `google-services.json` inside `android/app/`.

### 4. Running the App
```bash
flutter run
```

### 5. Running Automated Tests
```bash
flutter test
```

# Premium UrbanFix Flutter Template 🎨✨

Welcome to your new premium Flutter boilerplate! This template was automatically extracted from the UrbanFix application, giving you instant access to:
- A sophisticated earth-tone color palette & typography system
- Pre-configured ShadcnUI components
- Custom 200ms iOS-style navigation slide animations
- Beautiful, responsive screen skeletons (Auth, Home, Profile)

## 🚀 Getting Started

To use this template for your next application, follow these simple steps:

### 1. Integrate into your new app
If you already have a new Flutter project created (e.g., `my_new_app`), simply copy the entire `lib/` folder from this template and replace the `lib/` folder in your new project. Do the same for the dependencies in `pubspec.yaml` (especially `shadcn_ui`, `go_router`, and `google_fonts`).

If you are starting fresh, you can just use this folder! Open the `premium_flutter_template` folder in VS Code or Android Studio.

### 2. Install Packages
Run the following command to download all necessary UI packages:
```bash
flutter pub get
```

### 3. Build & Run
Test the boilerplate to see the premium skeletons in action:
```bash
flutter run
```

---

## 📁 What's Inside?

### The Theme (`lib/config/shadcn_theme.dart`)
This is the heart of the premium look. It configures the colors, typography (`GoogleFonts.poppins`), border radii, and shadows for the entire Shadcn app wrapper.

### Routing & Animations (`lib/config/routes.dart`)
We use `go_router` combined with a custom `CustomSlideTransition` to enable fast, beautiful screen transitions. The shell route includes the bottom navigation bar skeleton.

### Screen Skeletons (`lib/screens/`)
All screens have had their backend logic (Supabase, Maps) stripped entirely, leaving you with pure, beautiful UI code.
- **Auth**: Premium gradient login and registration forms.
- **Home**: A dashboard skeleton featuring stats cards and a gradient map placeholder.
- **Profile**: A stunning layout showing user statistics, badges, and an activity timeline placeholder.

### Reusable Widgets (`lib/widgets/`)
Includes the custom `.glassmorphism` container, custom buttons, and loaders we built for UrbanFix.

---

## 🛠️ Next Steps for Your App

1.  **Backend Hookup:** Replace the dummy variables (like `_mockName` in the Profile screen) and static delays with your real backend calls (Firebase, Supabase, your own API).
2.  **Add Your Screens:** Look at how `routes.dart` is structured and add new paths (`GoRoute`) as you build more screens.
3.  **Customize the Theme:** Want a different primary color? Just change `primaryColor` in `shadcn_theme.dart` and the entire app will update perfectly!

Enjoy building your next premium app! 🚀

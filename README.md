# GYMIO - Premium Fitness Marketplace

GYMIO is a modern, premium mobile application prototype built with Flutter. It serves as a marketplace connecting fitness enthusiasts with nearby gyms, allowing them to browse gym profiles, purchase supplements and gear, discover exclusive offers, and manage their fitness journey in one unified experience.

## ✨ Features

- **Modern Premium UI/UX:** Apple-level simplicity combined with fintech-style reliability. Uses a curated color palette, smooth micro-interactions, and a cohesive design system.
- **Robust State Management:** Powered by Riverpod for clean, reactive, and scalable state management.
- **Advanced Navigation:** Utilizes GoRouter with shell routes for persistent bottom navigation, separate consumer and gym-owner flows, and deep-link ready structures.
- **Consumer App Flow:**
  - Discover nearby gyms based on location.
  - Browse gym-specific product catalogs (supplements, apparel, gear).
  - Add to cart and seamless local checkout simulation.
  - Track order status with a visual timeline.
- **Gym Owner Dashboard (Mock):**
  - Dedicated portal for gym owners to manage inventory and view revenue stats.
  - **AI Product Magic ✨:** Mock feature showcasing how gym owners could upload an image of a product and use AI to automatically generate titles, descriptions, and tags.

## 🛠 Tech Stack

- **Framework:** Flutter (v3.24+)
- **Language:** Dart
- **State Management:** Riverpod (`flutter_riverpod`)
- **Routing:** GoRouter (`go_router`)
- **Animations:** Lottie (`lottie`), built-in Flutter implicit/explicit animations.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.24 or higher recommended)
- Dart SDK
- iOS Simulator or Android Emulator

### Installation & Running

1. **Clone the repository (or navigate to the project root):**
   ```bash
   cd SGYM
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

*(Note: The app is configured with completely local mock data and state for this prototype phase. It requires no backend, Firebase, or external API keys to run successfully from the first launch.)*

## 🔮 Future Integration Paths (Production Readiness)

While this is currently a local UI/UX prototype, the architecture is specifically designed for straightforward backend integration:

### 1. Data Layer & Backend (Firebase / Supabase / Custom REST API)
- The mock data currently lives in `lib/data/mock/mock_data.dart`.
- The state logic is housed in Riverpod `StateNotifier`s inside `lib/core/providers/providers.dart`.
- **To upgrade:** Create concrete repository classes (e.g., `AuthRepository`, `GymRepository`, `ProductRepository`) that communicate with your backend. Inject these repositories into the existing Riverpod providers, replacing the mock `Future.delayed` logic with real network calls.

### 2. Authentication
- Currently uses a mock authentication simulation with simulated loading states.
- **To upgrade:** Connect the `authProvider` to Firebase Authentication or your own auth server. The `GoRouter` redirect logic is already set up to listen to the `authProvider` and will seamlessly adapt to real auth state changes.

### 3. Payments Processing
- The checkout flow is simulated.
- **To upgrade:** Integrate Stripe, Paymob, or Apple/Google Pay SDKs in the `CheckoutScreen`. The cart subtotal, discount, and total calculations are already reactive and separated from the UI.

### 4. AI Image Feature Implementation
- The `AiImageScreen` showcases a mock AI generation feature for gym owners.
- **To upgrade:** Connect this to Google Cloud Vision API or the Gemini API (Vertex AI). When a gym owner snaps a photo, upload it to cloud storage, pass the URI to the AI model with a prompt like *"Analyze this fitness product and return a JSON with a catchy title, description, and category"*, and parse the response into the text fields.

## 📱 Design System

- **Colors:** Defined in `AppColors` (`lib/core/theme/app_colors.dart`). Features a primary Deep Indigo (`#252440`) and vibrant accents like Neon Cyan (`#00F2FE`) and Electric Coral (`#FF4B4B`).
- **Typography:** Uses Google Fonts (Outfit & Plus Jakarta Sans) for a clean, modern tech feel.
- **Components:** Reusable, stateless widgets are located in `lib/shared/widgets/` ensuring consistency across all screens (e.g., `AppButton`, `AppTextField`, `GymioLogo`, `DiscountBadge`).

## 📄 License
This project is proprietary.

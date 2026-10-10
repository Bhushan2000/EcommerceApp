# Aura Market — Flutter E-Commerce Application with Firebase

A full-featured, modern Flutter E-Commerce application with **Firebase Authentication**, **Cloud Firestore**, state management using **Provider**, and Material 3 design.

The app is built to run **immediately out-of-the-box in Demo Mode** (with mock data, active cart, and local checkout) and **seamlessly synchronizes with live Firebase** once you connect your Firebase project!

---

## 🌟 Key Features

### 🛒 Product Catalog & Discovery
- **Category Browsing**: Filter by categories (Electronics, Fashion, Home & Living, Beauty, Sports & Fitness, Jewelry).
- **Product Details**: Image gallery preview, expandable product descriptions, variant selectors (Color & Size), and real-time stock indicators.
- **Search & Advanced Filters**: Live instant search across titles, descriptions, and tags. Filter by price slider and sort by Featured, Price (Low to High / High to Low), or Customer Ratings.
- **Ratings & Reviews**: Real customer review timeline with the ability to submit interactive star ratings and comments.
- **Promotions & Flash Sales**: Promotional carousel banner with automated auto-scroll and flash sale showcase.

### 🛍️ Cart, Wishlist & Checkout
- **Cart Management**: Add to cart with color and size selection, quantity stepper, swipe/delete controls, and clear cart confirmation.
- **Coupons & Promo Codes**: Working promo engine with discount calculation (e.g. `SAVE20` for 20% off, `AURA50` for 50% off, `WELCOME10` for 10% off).
- **Tax & Free Shipping**: Automated tax computation (8%) and free shipping threshold ($100+).
- **Wishlist & Favorites**: Persistent bookmarking with live badge counters in bottom navigation.
- **Multi-step Checkout**: Delivery address pre-filling, payment method selection (Credit/Debit Card, Apple/Google Pay, Cash on Delivery), and instant order placement.

### 🔐 Firebase Authentication & Cloud Firestore
- **Authentication**:
  - Email & Password Sign In and Registration with validation.
  - Guest / Anonymous Shopper Mode.
  - Password Reset Email workflow.
  - Profile Management (display name, phone number, multi-field shipping address).
- **Cloud Firestore**:
  - `products`: Catalog items, pricing, inventory stock, ratings, and reviews array.
  - `categories`: Dynamic category list with icons and image banners.
  - `orders`: Persistent customer orders with item snapshots, timestamp, status, and shipping information.
  - `users`: User profiles and delivery address books.
- **1-Click Firestore Data Seeding**: Built-in in-app feature in the Profile tab to seed all sample products and categories directly to Cloud Firestore.

### 🎨 Design & Experience
- **Material 3 Design**: Clean typography (Google Fonts *Plus Jakarta Sans*), rounded elevation cards, and fluid micro-interactions.
- **Light & Dark Theme**: Full theme switching support with persistent state.
- **Resilient Offline / Demo Mode**: If Firebase credentials are not yet configured, the app gracefully runs with seed data so you can test every screen, order flow, and calculation without build failures.

---

## 📁 Project Architecture

```
lib/
├── firebase_options.dart              # FlutterFire configuration template
├── main.dart                          # App initialization, Providers setup & theme routing
├── models/
│   ├── category_model.dart            # Category data structure & icon mapper
│   ├── product_model.dart             # Product data structure with discount & stock helpers
│   ├── cart_item_model.dart           # Cart item with quantity & variant options
│   ├── order_model.dart               # Order schema with OrderStatus enum & receipt breakdowns
│   ├── user_model.dart                # User profile & shipping address model
│   └── review_model.dart              # Product reviews & rating model
├── services/
│   ├── firebase_service.dart          # Safe Firebase initialization with demo mode fallback
│   ├── auth_service.dart              # FirebaseAuth API wrapper (with mock auth fallback)
│   ├── firestore_service.dart         # Cloud Firestore CRUD & 1-tap data seeding
│   ├── mock_data_service.dart         # Catalog dataset with high-resolution imagery
│   └── storage_service.dart           # SharedPreferences cache for wishlist & theme
├── providers/
│   ├── auth_provider.dart             # Session state, login, register, guest & profile
│   ├── product_provider.dart          # Catalog querying, filtering, search & reviews
│   ├── cart_provider.dart             # Cart items, promo codes, taxes & order totals
│   ├── wishlist_provider.dart         # Saved items state & disk persistence
│   ├── order_provider.dart            # Order creation & order history loader
│   └── theme_provider.dart            # Light / Dark theme controller
├── screens/
│   ├── home/
│   │   ├── main_navigation.dart       # Bottom Navigation Bar with dynamic badges
│   │   └── home_screen.dart           # Banners, flash sales, categories & product grid
│   ├── catalog/
│   │   ├── product_details_screen.dart # Image gallery, variants, reviews modal & add to cart
│   │   ├── category_products_screen.dart # Specific category product grid
│   │   └── search_screen.dart         # Search bar, filter bottom sheet & sort options
│   ├── cart/
│   │   ├── cart_screen.dart           # Cart item list, promo code input & bill summary
│   │   └── checkout_screen.dart       # Shipping form, payment options & order confirmation
│   ├── orders/
│   │   ├── order_history_screen.dart  # Placed orders list with status indicators
│   │   └── order_details_screen.dart  # Detailed receipt, delivery info & item cards
│   ├── wishlist/
│   │   └── wishlist_screen.dart       # Saved products grid
│   ├── auth/
│   │   ├── login_screen.dart          # Email signin, guest signin & validations
│   │   ├── register_screen.dart       # User registration form & terms checkbox
│   │   └── forgot_password_screen.dart# Password reset request screen
│   └── profile/
│       ├── profile_screen.dart        # Profile overview, dark theme switch & menu items
│       ├── edit_profile_screen.dart   # Shipping address & name editing
│       └── firebase_config_info_screen.dart # Live Firebase status & 1-tap Firestore seeder
├── widgets/
│   ├── product_card.dart              # Responsive product tile with image cache & discount tag
│   ├── banner_carousel.dart           # Auto-playing promotional slider with indicators
│   ├── category_chip.dart             # Pill-shaped animated category toggle
│   ├── custom_button.dart             # Primary / outline button with loading spinner
│   ├── custom_text_field.dart         # Styled input field with password visibility toggle
│   └── empty_state_view.dart          # Reusable placeholder for empty cart, search & orders
└── utils/
    ├── app_theme.dart                 # Material 3 light & dark theme styling
    ├── constants.dart                 # Colors, tax rates, promo codes & constants
    └── formatters.dart                # Currency ($) and date-time formatters
```

---

## 🚀 Running the App Immediately

You can run the app right now in Chrome, Windows, or an Android/iOS emulator:

```bash
# Run on your default device or browser
flutter run

# Or specifically on Chrome
flutter run -d chrome
```

The app will start in **Local / Demo Mode**, allowing you to browse products, test adding items to the cart, apply discount codes like `SAVE20`, and place test orders immediately!

---

## 🔥 Connecting Your Live Firebase Project

To connect this app to your own Firebase project:

### Step 1: Install Firebase Tools & FlutterFire CLI
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### Step 2: Log In to Firebase
```bash
firebase login
```

### Step 3: Run FlutterFire Configure
In the root of this project, execute:
```bash
flutterfire configure
```
Follow the interactive prompts to select or create your Firebase project and select the target platforms (Android, iOS, Web). This will automatically generate your live `lib/firebase_options.dart` and native configuration files (`google-services.json` and `GoogleService-Info.plist`).

### Step 4: Enable Firebase Services in the Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. **Authentication**: Enable **Email/Password** and **Anonymous** sign-in providers.
3. **Cloud Firestore**: Click **Create Database** (start in Test Mode for development).

### Step 5: Seed Your Firestore Catalog in 1 Click!
Launch the app, navigate to **Profile** > **Firebase & Cloud Firestore**, and tap **"Seed Initial Catalog"**. All categories and products will be automatically uploaded into your Cloud Firestore database!

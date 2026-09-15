# Product Catalog App

## Tech Stack
- **Flutter** (UI framework)
- **Dart** (programming language)
- **HTTP** package (REST API requests)
- **DummyJSON API** (data source)
- **Material Design** (UI components)

---

## Architecture

The app follows a lightweight layered architecture to separate responsibilities:

### Data / API Layer
- Handles communication with DummyJSON API
- Converts JSON responses into Dart objects
- Located in `lib/api/product_api.dart`
- Provides methods for:
  - Fetching products
  - Fetching individual product details
  - Searching products

### Model Layer
- Located in `lib/model/product_model.dart`
- Defines the `Product` class with:
  - ID, Title, Description, Price, Rating, Thumbnail, Images
- Includes `Product.fromJson()` factory for JSON parsing

### UI / Presentation Layer
- Responsible for displaying products and handling user interaction
- Main components:
  - `ProductListPage` — product listing, search, pagination, refresh, and state handling
  - `ProductDetailPage` — detailed product view
  - Reusable widgets: product cards, search bar widgets

---

## Getting Started

### Prerequisites
Ensure you have:
- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Emulator or physical device with internet access

### Clone the Repository
```bash
git clone https://github.com/Kelv04/product_catalog_app
cd product_catalog_app
```

### Install Dependencies
```bash
flutter pub get
```

### Run the Application
```bash
flutter run
```

---

## Features Implemented
- Product list with pagination
- Product detail screen with images, description, price, rating
- Search with debounce (500ms)
- Loading, error, empty, and success states
- Pull-to-refresh
- Image placeholders and error handling

---

## Known Limitations / TODOs
- Add unit tests (api, search, pagination logic)
- Back to top button

---

## AI Assistance
AI tools (Microsoft Copilot) were used minimally for guidance, research and some UI design suggestion.  
All architectural decisions, code structure, and logic were implemented and reviewed by me.  

---


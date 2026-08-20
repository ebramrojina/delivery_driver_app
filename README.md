# Delivery Driver App (Flutter) — MVP

## Setup

```bash
flutter pub get
flutter run
```

## Point it at your backend

Edit `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5000/api';
```

- Android emulator → keep `10.0.2.2` (maps to your host machine's `localhost`)
- iOS simulator → use `http://localhost:5000/api`
- Physical device → use your machine's LAN IP, e.g. `http://192.168.1.x:5000/api`
- Production → your deployed backend URL

## How it works

1. **Login** (`login_screen.dart`) — calls `POST /api/auth/login`. Rejects login if the account's role isn't `driver` (this app is driver-only). On success, saves the JWT + user via `StorageService` (SharedPreferences) so the session survives app restarts.
2. **Orders List** (`orders_list_screen.dart`) — calls `GET /api/orders/driver/:driverId` on load and pull-to-refresh. Sorted so active orders (assigned → picked up → out for delivery) surface before delivered ones.
3. **Order Details** (`order_details_screen.dart`) — fetches the single order, shows both addresses (with an "open in Google Maps" button using saved lat/lng), a timeline of every status timestamp, and **one** action button — whichever status comes next for that order (Picked Up → Out for Delivery → Delivered). This matches the server's status-flow enforcement, so drivers can't get out of sync with the backend.

## Why it's structured this way (for adding real-time later)

- **`OrderProvider`** is the single source of truth for the order list. It exposes `applyServerUpdate(order)` — when you add Socket.IO, just listen for an `order:statusUpdated` event anywhere in the app and call that method. Every screen watching `OrderProvider` updates automatically; no screen code changes.
- **Services** (`auth_service.dart`, `order_service.dart`) only know about HTTP — swapping in a socket client later doesn't touch them.
- **`api_config.dart`** is the only place with hardcoded URLs — add a `socketUrl` constant there when the time comes.

## Testing without the Customer/Admin apps

Since Admin is deferred to Postman for now:
1. Register a customer and a driver via `POST /api/auth/register`
2. Log in as admin (or use Postman with an admin token) to `POST /api/orders` as the customer, then `PUT /api/orders/:id/assign` with the driver's id
3. Log into this app as that driver — the order should appear in the list

## Known limitation

This code hasn't been run through `flutter analyze` or compiled — this sandbox doesn't have Flutter/Dart installed and `pub.dev` isn't reachable from here. I've manually reviewed it and checked bracket/paren balance, but please run `flutter pub get && flutter analyze` on your machine as a first step and let me know if anything surfaces.

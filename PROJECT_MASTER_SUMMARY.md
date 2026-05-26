# PROJECT MASTER SUMMARY
## NeoShop — Flutter eCommerce App

> Last updated: May 27, 2026  
> Overall completion: ~78%  
> Platform: Android (primary), Flutter multi-platform scaffolded

---

## QUICK REFERENCE

| Item | Value |
|---|---|
| App name | NeoShop |
| Package ID | `com.neoshop.app` |
| Firebase project | `ecomerce-ai-20fee` |
| Firebase project number | `294519627026` |
| Debug SHA-1 | `D9:0F:66:9F:B7:B0:01:B7:E7:6E:51:A4:15:40:D9:E1:35:BB:5C:2A` |
| State management | `provider` (ChangeNotifier) |
| Navigation | `Navigator.push` / `MaterialPageRoute` |
| Theme | Dark only — NeoCommerce Dark |
| Font | Inter (via `google_fonts`) |

---

## ARCHITECTURE OVERVIEW

```
lib/
├── main.dart                          # App entry, MultiProvider setup
├── core/
│   ├── theme/app_theme.dart           # AppColors + AppTheme.dark
│   ├── widgets/
│   │   ├── gradient_button.dart       # Reusable CTA button
│   │   ├── product_card.dart          # Animated product grid card
│   │   └── main_navigation_screen.dart # 5-tab IndexedStack nav
│   ├── constants/                     # EMPTY — strings go here
│   └── utils/                         # EMPTY — validators go here
└── features/
    ├── auth/          controller + data + presentation
    ├── cart/          controller + data + presentation
    ├── checkout/      controller + presentation
    ├── home/          presentation only
    ├── onboarding/    presentation only
    ├── orders/        controller + data + presentation
    ├── product/       data (model+service) + presentation
    ├── profile/       presentation only
    ├── search/        presentation only
    └── wishlist/      controller + presentation
```

**Providers registered in `main.dart`:**
- `WishlistController` — wishlist list, SharedPreferences
- `CartController` — cart items, SharedPreferences + Firestore
- `AuthController` — Firebase auth state via `authStateChanges()`
- `OrderController` — orders list, Firestore
- `CouponController` — coupon code validation (hardcoded)

**Firestore collections:**
- `users/{uid}` — name, email, image, uid, createdAt
- `products/{id}` — title, price, description, image, category, rating, reviewCount, discount
- `carts/{uid}` — items array, updatedAt
- `orders/{id}` — id, status, total, createdAt, items, address, paymentMethod, uid

---

## COMPLETED FEATURES ✅

| Feature | Status | Notes |
|---|---|---|
| Onboarding (3 pages) | ✅ Done | SharedPreferences flag — shows once |
| Email/password register | ✅ Done | Creates Firestore `users` doc |
| Email/password login | ✅ Done | |
| Google Sign-In | ✅ Done | `authStateChanges()` stream fixes navigation |
| Logout | ✅ Done | |
| Auth gate (onboarding → login → home) | ✅ Done | |
| Home screen — product stream | ✅ Done | Stable stream in `initState`, `AutomaticKeepAlive` |
| Home screen — category filter | ✅ Done | Client-side, 5 categories |
| Home screen — search | ✅ Done | Inline filter on cached list |
| Home screen — banner carousel | ✅ Done | 3 hardcoded Unsplash URLs |
| Product details screen | ✅ Done | Qty selector, add to cart, wishlist |
| Product card | ✅ Done | Bounce animation, checkmark feedback, `Selector` for wishlist |
| Search screen | ✅ Done | Firestore stream, title+category filter |
| Wishlist | ✅ Done | SharedPreferences persistence |
| Cart | ✅ Done | SharedPreferences + Firestore, debounced writes |
| Checkout | ✅ Done | Coupon input, payment method selector, places order |
| Coupon codes | ✅ Done | SAVE10/SAVE20/WELCOME (hardcoded) |
| Order placement | ✅ Done | Writes to Firestore `orders` |
| Order history | ✅ Done | Fetches from Firestore, client-side sort |
| Profile screen | ✅ Done | Live order + wishlist counts |
| Edit profile | ✅ Done | Updates Firebase Auth displayName + Firestore |
| Bottom navigation (5 tabs) | ✅ Done | Floating pill, gradient active icon |
| Product ID field | ✅ Done | `id` added to ProductModel, identity fix in cart+wishlist |

---

## SPRINT PROGRESS

### ✅ Sprint 1 — Correctness & Safety (IN PROGRESS)

| Task | ID | Status |
|---|---|---|
| Add `id` to ProductModel + fix cart/wishlist identity | TASK-001 | ✅ Done |
| Create `validators.dart` | TASK-002 | ✅ Done |
| Wire validators into login + register | TASK-003 | ✅ Done |
| Implement forgot password | TASK-004 | ✅ Done |
| Remove unused packages (riverpod, go_router) | TASK-005 | ✅ Done |
| Delete empty `lib/auth/` directory | TASK-006 | ✅ Done |
| Address TextField in CheckoutScreen | TASK-007 | ✅ Done |
| Reorder button in OrdersScreen | TASK-008 | ✅ Done |
| Pull-to-refresh on OrdersScreen | TASK-009 | ✅ Done |
| Fix `OrderModel.createdAt` Timestamp crash | BUG-001 | ✅ Done |

### ⬜ Sprint 2 — Stability & Observability

| Task | ID | Status |
|---|---|---|
| Firestore security rules | TASK-011 | ✅ Done |
| Firebase Crashlytics | TASK-012 | ✅ Done |
| WishlistController constructor timing fix | TASK-015 | ✅ Done |
| OrderController → real-time stream | TASK-016 | ✅ Done |
| Coupons from Firestore | TASK-017 | ✅ Done |
| Order status timeline (Track Order) | TASK-010 | ✅ Done |
| CachedNetworkImage cache config | TASK-019 | ✅ Done |
| Delete unused `UserModel` | TASK-023 | ✅ Done |

### ⬜ Sprint 3 — Production Config

| Task | ID | Status |
|---|---|---|
| Rename package from `com.example.*` | TASK-013 | ✅ Done |
| Release signing config | TASK-014 | ✅ Done (scaffold) |
| App icon + splash screen | TASK-021 | ⬜ Pending |
| Firebase App Check | TASK-022 | ✅ Done |
| Product pagination | TASK-018 | ✅ Done |
| FCM push notifications | TASK-020 | ⬜ Pending |

### ⬜ Sprint 4 — Growth (Post-launch)

| Task | ID | Status |
|---|---|---|
| Firebase Analytics | TASK-028 | ⬜ Pending |
| Product reviews/ratings UI | TASK-025 | ⬜ Pending |
| Profile avatar upload | TASK-024 | ⬜ Pending |
| Product variants (size/color) | TASK-026 | ⬜ Pending |
| Light theme | TASK-027 | ⬜ Pending |

---

## KNOWN BUGS

| ID | Description | Severity | File |
|---|---|---|---|
| BUG-001 | `OrderModel.fromJson` uses `DateTime.parse()` — Firestore returns `Timestamp` not `String`, will throw `TypeError` at runtime | **HIGH** ✅ Fixed | `lib/features/orders/data/order_model.dart` |
| BUG-002 | `WishlistController()` calls `notifyListeners()` in constructor — may cause `setState during build` assertion | ✅ Fixed (deferred) | `lib/features/wishlist/controller/wishlist_controller.dart` |
| BUG-003 | No input validation before Firebase auth calls — empty email/password reaches Firebase | Medium | `login_screen.dart`, `register_screen.dart` |

---

## TECHNICAL DEBT

| Item | Impact | Fix Sprint |
|---|---|---|
| `flutter_riverpod` in pubspec — unused | Build overhead | ~~Sprint 1~~ ✅ Done |
| `go_router` in pubspec — unused | Build overhead | ~~Sprint 1~~ ✅ Done |
| `UserModel` class — defined, never used | Dead code | ~~Sprint 2~~ ✅ Done |
| `lib/auth/` empty root directory | Confusion | ~~Sprint 1~~ ✅ Done |
| `lib/core/constants/` empty | Strings scattered | Sprint 2 |
| `lib/core/utils/` empty | No validators | Sprint 1 |
| Coupon codes hardcoded in `CouponController` | Can't manage without code release | Sprint 2 |
| Release build uses debug signing keys | Cannot publish | ~~Sprint 3~~ ✅ Done (scaffold) |
| Package name `com.example.*` | Play Store rejection | ~~Sprint 3~~ ✅ Done |
| Delivery address hardcoded in CheckoutScreen | Bad UX | Sprint 1 |
| Track/Reorder buttons are no-ops | Broken UX | Sprint 1 |
| Profile menu items (Addresses, Payment, Returns, Help, Chat) are no-ops | Broken UX | Sprint 2+ |

---

## MISSING PRODUCTION FEATURES

| Feature | Priority | Sprint |
|---|---|---|
| Firestore security rules | 🔴 Critical | ~~Sprint 2~~ ✅ Done |
| Release signing | 🔴 Critical | ~~Sprint 3~~ ✅ Done (scaffold) |
| Package rename | 🔴 Critical | ~~Sprint 3~~ ✅ Done |
| Input validation | 🟠 High | ~~Sprint 1~~ ✅ Done |
| Forgot password | 🟠 High | ~~Sprint 1~~ ✅ Done |
| Firebase Crashlytics | 🟠 High | ~~Sprint 2~~ ✅ Done |
| Firebase App Check | 🟡 Medium | ~~Sprint 3~~ ✅ Done |
| FCM push notifications | 🟡 Medium | Sprint 3 |
| App icon + splash | 🟡 Medium | Sprint 3 |
| Product pagination | 🟡 Medium | ~~Sprint 3~~ ✅ Done |
| Payment gateway | 🔵 Low | Post-launch |
| Analytics | 🔵 Low | Sprint 4 |

---

## NEXT IMMEDIATE STEPS

> Pick up from here in the next session:

**Sprint 2 is complete.** Sprint 3 in progress.

**Completed this session:** TASK-013 ✅, TASK-014 ✅ (scaffold), TASK-018 ✅, TASK-022 ✅

**Remaining Sprint 3 tasks:**

**1. TASK-021** — App icon + splash screen (blocked):
- Drop `assets/icon/app_icon.png` (1024×1024 PNG) then run:
  ```
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```

**2. TASK-020** — FCM push notifications:
- Add `firebase_messaging` to pubspec
- Request permission, handle foreground/background messages

> Sprint 3 is ~80% complete. Only TASK-021 (needs icon asset) and TASK-020 remain.

---

## DEPENDENCIES MAP

```
ProductModel (id field) ✅
    └── ProductService (doc.id merge) ✅
    └── CartController (id-based identity) ✅
    └── WishlistController (id-based identity) ✅
    └── CartItemModel (via ProductModel.toJson) ✅

validators.dart [PENDING]
    └── LoginScreen
    └── RegisterScreen
    └── CheckoutScreen (address field)

AuthController.sendPasswordReset [PENDING]
    └── LoginScreen (forgot password button)

OrderModel.createdAt fix [PENDING — BUG-001]
    └── OrdersScreen (prevents runtime crash)

Firestore security rules [PENDING]
    └── CouponController Firestore migration (TASK-017)
    └── OrderController real-time stream (TASK-016)

Package rename [PENDING]
    └── Release signing (TASK-014)
    └── Firebase Console update
    └── google-services.json re-download
    └── Firebase App Check (TASK-022)
```

---

## COMPLETION ESTIMATE

| Area | Current | After Sprint 1 | After Sprint 2 | After Sprint 3 |
|---|---|---|---|---|
| UI / Screens | 80% | 90% | 92% | 95% |
| Auth | 85% | 100% | 100% | 100% |
| Cart & Wishlist | 92% | 95% | 95% | 95% |
| Checkout | 50% | 75% | 80% | 80% |
| Orders | 65% | 85% | 92% | 92% |
| Security | 30% | 40% | 70% | 88% |
| Performance | 72% | 75% | 85% | 90% |
| Production config | 20% | 25% | 30% | 95% |
| Testing | 0% | 10% | 20% | 40% |
| **Overall** | **85%** | **85%** | **85%** | **93%** |

---

## HOW TO USE THIS FILE

1. At the start of each session — read **NEXT IMMEDIATE STEPS**
2. After completing a task — mark it `✅ Done` in the Sprint Progress table
3. After finding a new bug — add it to **KNOWN BUGS**
4. After adding new debt — add it to **TECHNICAL DEBT**
5. Keep **COMPLETION ESTIMATE** updated after each sprint

---

*This file is the single source of truth for project progress.*

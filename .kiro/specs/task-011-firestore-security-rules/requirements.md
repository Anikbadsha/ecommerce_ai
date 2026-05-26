# Requirements Document

## Introduction

NeoShop is a Flutter eCommerce application backed by Firebase/Firestore. Currently, no `firestore.rules` file exists, meaning all Firestore collections are open by default — a production security blocker. This feature defines and enforces security rules for all five Firestore collections used by the app (`users`, `products`, `carts`, `orders`, `coupons`), ensuring that only authenticated users can access data, and that each user can only access data they own or are permitted to read.

---

## Glossary

- **Security_Rules**: The Firestore security rules engine that evaluates `allow`/`deny` decisions for every read and write request.
- **Auth_Context**: The `request.auth` object provided by Firebase Authentication, containing the authenticated user's `uid`.
- **Owner**: The authenticated user whose `request.auth.uid` matches the document's path segment or stored `uid` field.
- **Client**: The Flutter mobile application running on a user's device.
- **Admin**: A privileged operator who manages data via the Firebase Console or Firebase Admin SDK, not through the Flutter client.
- **CartController**: The Flutter provider class that reads and writes to `carts/{uid}`.
- **OrderController**: The Flutter provider class that creates and queries `orders/{id}` filtered by the `uid` field.
- **CouponController**: The Flutter provider class that reads `coupons/{code}`.
- **ProductService**: The Flutter service class that streams documents from the `products` collection.
- **AuthController**: The Flutter provider class that writes to `users/{uid}` on registration and Google sign-in.
- **Firebase_CLI**: The Firebase command-line tool (`firebase`) used to deploy rules and other Firebase project resources.

---

## Requirements

### Requirement 1: Global Deny-by-Default

**User Story:** As a security engineer, I want all Firestore collections to deny access by default, so that no collection is accidentally left open as the app grows.

#### Acceptance Criteria

1. THE Security_Rules SHALL deny all read and write access to every collection unless an explicit `allow` rule grants access.
2. IF a request is made without a valid Auth_Context, THEN THE Security_Rules SHALL deny the request for every collection.

---

### Requirement 2: User Profile Access Control

**User Story:** As a registered user, I want only my own profile document to be readable and writable by me, so that other users cannot view or modify my personal data.

#### Acceptance Criteria

1. WHEN an authenticated user requests read access to `users/{uid}`, THE Security_Rules SHALL allow the request only if `request.auth.uid` equals the document path `uid`.
2. WHEN an authenticated user requests write access to `users/{uid}`, THE Security_Rules SHALL allow the request only if `request.auth.uid` equals the document path `uid`.
3. IF an authenticated user requests access to `users/{uid}` where `request.auth.uid` does not equal the document path `uid`, THEN THE Security_Rules SHALL deny the request.
4. IF a request to `users/{uid}` is made without a valid Auth_Context, THEN THE Security_Rules SHALL deny the request.

---

### Requirement 3: Product Catalogue Read-Only Access

**User Story:** As a shopper, I want to browse and search products after signing in, so that the product catalogue is available to all authenticated users while remaining protected from client-side modification.

#### Acceptance Criteria

1. WHEN an authenticated user requests read access to any document in the `products` collection, THE Security_Rules SHALL allow the request.
2. WHEN any client requests write access to any document in the `products` collection, THE Security_Rules SHALL deny the request.
3. IF a request to the `products` collection is made without a valid Auth_Context, THEN THE Security_Rules SHALL deny the request.

---

### Requirement 4: Cart Ownership Enforcement

**User Story:** As a shopper, I want only my own cart to be readable and writable by me, so that no other user can view or tamper with my cart contents.

#### Acceptance Criteria

1. WHEN an authenticated user requests read access to `carts/{uid}`, THE Security_Rules SHALL allow the request only if `request.auth.uid` equals the document path `uid`.
2. WHEN an authenticated user requests write access to `carts/{uid}`, THE Security_Rules SHALL allow the request only if `request.auth.uid` equals the document path `uid`.
3. IF an authenticated user requests access to `carts/{uid}` where `request.auth.uid` does not equal the document path `uid`, THEN THE Security_Rules SHALL deny the request.
4. IF a request to `carts/{uid}` is made without a valid Auth_Context, THEN THE Security_Rules SHALL deny the request.

---

### Requirement 5: Order Access and Immutability

**User Story:** As a shopper, I want to place orders and view my own order history, so that my orders are private and cannot be altered or deleted from the client after placement.

#### Acceptance Criteria

1. WHEN an authenticated user requests read access to `orders/{id}`, THE Security_Rules SHALL allow the request only if `request.auth.uid` equals the `uid` field stored in the order document (`resource.data.uid`).
2. WHEN an authenticated user requests create access to `orders/{id}`, THE Security_Rules SHALL allow the request only if `request.auth.uid` equals the `uid` field in the incoming document (`request.resource.data.uid`).
3. WHEN any client requests update access to `orders/{id}`, THE Security_Rules SHALL deny the request.
4. WHEN any client requests delete access to `orders/{id}`, THE Security_Rules SHALL deny the request.
5. IF a request to `orders/{id}` is made without a valid Auth_Context, THEN THE Security_Rules SHALL deny the request.
6. WHEN an authenticated user queries the `orders` collection with a `where('uid', isEqualTo: request.auth.uid)` filter, THE Security_Rules SHALL allow the query to execute.

---

### Requirement 6: Coupon Read-Only Access

**User Story:** As a shopper, I want to validate coupon codes at checkout, so that coupon data is readable by authenticated users but cannot be created or modified from the client.

#### Acceptance Criteria

1. WHEN an authenticated user requests read access to any document in the `coupons` collection, THE Security_Rules SHALL allow the request.
2. WHEN any client requests write access to any document in the `coupons` collection, THE Security_Rules SHALL deny the request.
3. IF a request to the `coupons` collection is made without a valid Auth_Context, THEN THE Security_Rules SHALL deny the request.

---

### Requirement 7: Rules File and Project Configuration

**User Story:** As a developer, I want the security rules and Firebase configuration files to exist at the project root, so that the rules can be deployed via the Firebase CLI and are tracked in version control.

#### Acceptance Criteria

1. THE Security_Rules SHALL be defined in a file named `firestore.rules` located at the project root directory.
2. THE project root SHALL contain a `firebase.json` file with a `"firestore"` key whose `"rules"` value points to `"firestore.rules"`.
3. WHEN the Firebase CLI command `firebase deploy --only firestore:rules` is executed from the project root with a valid `firebase.json` present, THE Security_Rules SHALL be deployed to the Firebase project without errors.
4. IF the Firebase CLI command `firebase deploy --only firestore:rules` is executed and `firebase.json` is absent or malformed, THEN THE Firebase_CLI SHALL fail with an error and THE Security_Rules SHALL not be deployed.

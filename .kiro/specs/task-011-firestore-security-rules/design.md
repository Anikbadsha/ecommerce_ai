# Design: Firestore Security Rules (TASK-011)

## Overview

Write and deploy Firestore security rules that enforce authenticated access and ownership for all collections used by NeoShop. Currently the project has no `firestore.rules` file — all collections are open by default, which is a production blocker.

---

## Collections & Access Patterns

Derived from reading the actual controllers:

| Collection | Who reads | Who writes |
|---|---|---|
| `users/{uid}` | Owner only | Owner only (register, edit profile, Google sign-in) |
| `products/{id}` | Any authenticated user | Nobody from client (admin-only via console) |
| `carts/{uid}` | Owner only | Owner only (CartController) |
| `orders/{id}` | Owner only (filtered by `uid` field) | Owner only (placeOrder) |
| `coupons/{code}` | Any authenticated user | Nobody from client (admin-only) |

---

## Rule Design

### Global principle
- Deny everything by default (`allow read, write: if false`)
- Grant only what each collection needs
- All access requires `request.auth != null` (no unauthenticated reads)

### `users/{uid}`
```
allow read, write: if request.auth.uid == uid;
```
- Owner can read and update their own profile doc
- No other user can read another user's data

### `products/{id}`
```
allow read: if request.auth != null;
allow write: if false;
```
- Any signed-in user can read products (needed for home screen stream and search)
- No client writes — products are managed via Firebase Console

### `carts/{uid}`
```
allow read, write: if request.auth.uid == uid;
```
- Owner can read and write their own cart doc
- `CartController` uses `carts/{uid}` as the document path

### `orders/{id}`
```
allow read: if request.auth != null && request.auth.uid == resource.data.uid;
allow create: if request.auth != null && request.auth.uid == request.resource.data.uid;
allow update, delete: if false;
```
- Read: only the order owner (checked against the `uid` field stored in the doc)
- Create: only if the `uid` in the new doc matches the authenticated user
- Update/delete: blocked from client — order status changes are admin-only
- Note: `OrderController` queries `orders` with `.where('uid', isEqualTo: _uid)` — the read rule must allow this query. Firestore requires the field used in a `where` clause to be readable, so the `resource.data.uid == request.auth.uid` check covers this correctly.

### `coupons/{code}`
```
allow read: if request.auth != null;
allow write: if false;
```
- Any signed-in user can read a coupon doc to validate it
- No client writes — coupons are managed via Firebase Console

---

## File Location

The rules file lives at the project root as `firestore.rules` and is referenced in `firebase.json`.

```
ecommerce_ai/
├── firestore.rules       ← new
├── firebase.json         ← new (or update if exists)
└── ...
```

---

## Deployment

Rules are deployed via Firebase CLI:
```
firebase deploy --only firestore:rules
```

The `firebase.json` must point to the rules file:
```json
{
  "firestore": {
    "rules": "firestore.rules"
  }
}
```

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Unauthenticated Requests Are Always Denied

For any Firestore collection path and any request type (read or write), if the request carries no valid `request.auth` context, the Security_Rules SHALL deny the request.

**Validates: Requirements 1.2, 2.4, 3.3, 4.4, 5.5, 6.3**

---

### Property 2: User Profile Ownership Enforcement

For any document path `users/{uid}` and any authenticated user, the Security_Rules SHALL allow read and write access if and only if `request.auth.uid` equals the path segment `uid`. For any two distinct uids, one user's authenticated session SHALL NOT grant access to the other user's profile document.

**Validates: Requirements 2.1, 2.2, 2.3**

---

### Property 3: Products Are Read-Only for Authenticated Clients

For any authenticated user and any document in the `products` collection, the Security_Rules SHALL allow read access and SHALL deny all write access (create, update, delete).

**Validates: Requirements 3.1, 3.2**

---

### Property 4: Cart Ownership Enforcement

For any document path `carts/{uid}` and any authenticated user, the Security_Rules SHALL allow read and write access if and only if `request.auth.uid` equals the path segment `uid`. For any two distinct uids, one user's authenticated session SHALL NOT grant access to the other user's cart document.

**Validates: Requirements 4.1, 4.2, 4.3**

---

### Property 5: Order Read Access Restricted to Order Owner

For any order document in the `orders` collection and any authenticated user, the Security_Rules SHALL allow read access if and only if `request.auth.uid` equals the `uid` field stored in the order document (`resource.data.uid`).

**Validates: Requirements 5.1**

---

### Property 6: Order Creation Requires Matching UID

For any create request to `orders/{id}`, the Security_Rules SHALL allow the operation if and only if `request.auth.uid` equals the `uid` field in the incoming document (`request.resource.data.uid`). A create request where these values differ SHALL be denied.

**Validates: Requirements 5.2**

---

### Property 7: Orders Are Immutable After Creation

For any order document in the `orders` collection and any authenticated user, the Security_Rules SHALL deny all update and delete requests, regardless of whether the requesting user is the order owner.

**Validates: Requirements 5.3, 5.4**

---

### Property 8: Coupons Are Read-Only for Authenticated Clients

For any authenticated user and any document in the `coupons` collection, the Security_Rules SHALL allow read access and SHALL deny all write access (create, update, delete).

**Validates: Requirements 6.1, 6.2**

---

## What This Does NOT Cover

- **App Check** (TASK-022) — prevents non-app clients from hitting Firestore at all; complements these rules
- **Admin writes** — product/coupon/order-status management is done via Firebase Console or a separate admin SDK, not the Flutter client
- **Rate limiting** — not possible in Firestore rules; handled at App Check / quota level

---

## Testing

Rules should be validated with the Firebase Rules Playground in the Firebase Console before deploying:

1. Unauthenticated read of `products` → **denied**
2. Authenticated read of `products/any-id` → **allowed**
3. Authenticated read of `carts/{own-uid}` → **allowed**
4. Authenticated read of `carts/{other-uid}` → **denied**
5. Authenticated read of `orders/{id}` where `uid == auth.uid` → **allowed**
6. Authenticated read of `orders/{id}` where `uid != auth.uid` → **denied**
7. Authenticated create of `orders/{id}` with `uid == auth.uid` → **allowed**
8. Authenticated update of `orders/{id}` → **denied**
9. Authenticated read of `coupons/SAVE10` → **allowed**
10. Authenticated write to `coupons/SAVE10` → **denied**

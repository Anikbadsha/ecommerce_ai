# Release Signing Setup (TASK-014)

The release signing config reads credentials from `android/local.properties`.
This file is gitignored — never commit keystore credentials.

## Step 1 — Generate a keystore (one-time)

```bash
keytool -genkey -v \
  -keystore android/neoshop-release.jks \
  -storetype JKS \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias neoshop \
  -dname "CN=NeoShop, OU=Mobile, O=NeoShop, L=City, S=State, C=US"
```

Keep `neoshop-release.jks` out of version control — add to `.gitignore`:
```
android/neoshop-release.jks
```

## Step 2 — Add credentials to local.properties

Append to `android/local.properties`:
```
KEYSTORE_PATH=neoshop-release.jks
KEYSTORE_PASSWORD=your_store_password
KEY_ALIAS=neoshop
KEY_PASSWORD=your_key_password
```

## Step 3 — Update Firebase Console

After renaming the package to `com.neoshop.app`:
1. Go to Firebase Console → Project Settings → Your apps
2. Add a new Android app with package name `com.neoshop.app`
3. Download the new `google-services.json`
4. Replace `android/app/google-services.json` with the new file
5. Add the release SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore android/neoshop-release.jks -alias neoshop
   ```

## Step 4 — Build release APK / AAB

```bash
# APK
flutter build apk --release

# App Bundle (required for Play Store)
flutter build appbundle --release
```

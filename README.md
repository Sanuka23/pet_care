# Pet Care App

![Flutter CI](https://github.com/Sanuka23/pet_care/actions/workflows/flutter-ci.yml/badge.svg)
![Flutter APK Distribution](https://github.com/Sanuka23/pet_care/actions/workflows/flutter-cd.yml/badge.svg)

A comprehensive pet care management application built with Flutter.

## Features

- Pet profile management
- Vaccination tracking
- Appointment scheduling
- Feeding management
- Activity tracking
- Playdate organizing
- Reminders

## CI/CD Pipeline

This project uses GitHub Actions for Continuous Integration and APK Distribution:

- **Flutter CI**: Runs on every push to master and pull request. Performs code formatting checks, static analysis, runs tests, and builds debug and release APKs as artifacts.

- **APK Distribution**: Builds, signs, and distributes APKs. Can be triggered manually or automatically when releases are created.

- **Build APK on Demand**: Allows building debug or release APKs for any branch on demand, with optional GitHub release creation.

## Development Setup

1. **Clone the repository**
   ```
   git clone https://github.com/Sanuka23/pet_care.git
   cd pet_care
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Run the app**
   ```
   flutter run
   ```

## Build and Release

### Build Debug APK

```
flutter build apk --debug
```

### Build Release APK

```
flutter build apk --release
```

### Build via GitHub Actions

To build APKs without setting up a local development environment:

1. Go to the Actions tab in the GitHub repository
2. Select "Build APK on Demand" workflow
3. Click "Run workflow"
4. Select the branch and build type
5. Once complete, download the APK artifact

## Required Secrets for CI/CD

For the APK Distribution workflow to function properly, add these secrets to your GitHub repository:

- `SIGNING_KEY`: Base64 encoded signing key
- `KEY_ALIAS`: Key alias for the signing key
- `KEY_STORE_PASSWORD`: Password for the keystore
- `KEY_PASSWORD`: Password for the key
- `SERVICE_ACCOUNT_JSON`: Google Play service account JSON for publishing

## Generate Signing Key

Generate a keystore for signing your app:

```
keytool -genkey -v -keystore pet_care.keystore -alias pet_care -keyalg RSA -keysize 2048 -validity 10000
```

To convert keystore to base64 for GitHub secrets:

```
base64 pet_care.keystore | pbcopy
```

This will copy the base64 encoded keystore to your clipboard for pasting into GitHub secrets.

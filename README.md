# Pet Care App

![Flutter CI](https://github.com/Sanuka23/pet_care/actions/workflows/flutter-ci.yml/badge.svg)
![Deploy to GitHub Pages](https://github.com/Sanuka23/pet_care/actions/workflows/web-deploy.yml/badge.svg)

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

This project uses GitHub Actions for Continuous Integration and Deployment:

- **Flutter CI**: Runs on every push to master and pull request. Performs code formatting checks, static analysis, and runs tests.
- **Flutter CD**: Triggers when a new release is created. Builds, signs, and uploads the Android app bundle to Google Play internal track.
- **Web Deploy**: Deploys the web version of the app to GitHub Pages when pushing to master.

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

### Android

```
flutter build apk --release
```

### Web

```
flutter build web --release
```

## Required Secrets for CI/CD

For the CD workflow to function properly, add these secrets to your GitHub repository:

- `SIGNING_KEY`: Base64 encoded signing key
- `KEY_ALIAS`: Key alias for the signing key
- `KEY_STORE_PASSWORD`: Password for the keystore
- `KEY_PASSWORD`: Password for the key
- `SERVICE_ACCOUNT_JSON`: Google Play service account JSON for publishing

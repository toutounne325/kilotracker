# ============================================================================
# Protection légale pour le trading, propriété exclusive de Pirate Pips ™.
# AVERTISSEMENT LÉGAL & DISCLAIMER : Ce script de compilation automatisée est
# la propriété exclusive de Pirate Pips ™. Les outils logiciels fournis le sont
# à titre purement technologique et indicatif et ne constituent aucun conseil
# en investissement ou fiscal. Le trading comporte un risque élevé de perte.
# ============================================================================

name: Build Pirate Pips KiloTracker APK

on:
  push:
    branches: [ "main", "master" ]
  workflow_dispatch:

jobs:
  build-android-apk:
    runs-on: ubuntu-latest

    steps:
      - name: 1. Recuperation du depot GitHub
        uses: actions/checkout@v4

      - name: 2. Configuration de Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: 3. Installation du SDK Flutter Stable
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: 4. Generation du projet Android et injection du code Pirate Pips
        run: |
          flutter create --platforms=android --org com.piratepips kilotracker_app
          cp main.dart kilotracker_app/lib/main.dart
          cd kilotracker_app
          flutter pub add shared_preferences http
          sed -i 's/<application/<uses-permission android:name="android.permission.INTERNET"\/>\n    <application/g' android/app/src/main/AndroidManifest.xml
          sed -i 's/android:label="[^"]*"/android:label="Pirate Pips KiloTracker"/g' android/app/src/main/AndroidManifest.xml

      - name: 5. Compilation du fichier APK Release
        working-directory: kilotracker_app
        run: flutter build apk --release

      - name: 6. Publication de l'APK pret au telechargement
        uses: actions/upload-artifact@v4
        with:
          name: PiratePips-KiloTracker-APK
          path: kilotracker_app/build/app/outputs/flutter-apk/app-release.apk

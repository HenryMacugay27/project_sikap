📱 project_leap

A new Flutter project.

🚀 Getting Started

This project serves as the starting point for a Flutter application.

📚 Helpful Resources for Flutter Beginners:

Lab: Write your first Flutter app: https://docs.flutter.dev/get-started/codelab

Cookbook: Useful Flutter samples: https://docs.flutter.dev/cookbook

Flutter documentation: https://docs.flutter.dev/
: Includes tutorials, API reference, and best practices for mobile development.

🛠️ Setup Instructions
1. Install Git

Download and install Git from: https://git-scm.com/downloads

2. Clone the SIKAP Project (Optional Reference)
git clone https://github.com/HenryMacugay27/project_sikap.git

3. Setup for Android App Development
✅ Required Tools & Downloads:

Flutter CLI:
Install Flutter

Java Development Kit (JDK) 17:
Download JDK 17

Node.js (v22.14.0):
Download Node.js

Firebase Project:
Connect your Flutter app to Firebase:
Firebase Console – Android App Settings

⚙️ Environment Variables
Add the following paths to your system environment variables:
Path:
C:\src\flutter\bin  
C:\Program Files\Java\jdk-17\bin  
C:\Users\PC\AppData\Roaming\npm

JAVA_HOME:
C:\Program Files\Java\jdk-17

📦 Building the APK
Step-by-step:

Clean the build:

flutter clean


Get project dependencies:

flutter pub get


You may see outdated packages. To inspect:

flutter pub outdated


Upgrade all packages to the latest major versions:

flutter pub upgrade --major-versions


Run the app (create the APK):

flutter run


This will build and run the application on a connected Android device or emulator. For release builds:

flutter build apk --release

✅ Notes

Make sure your Android emulator is running or a device is connected via USB (with USB debugging enabled).

Ensure your Firebase project is correctly configured, and the google-services.json file is placed under android/app/.

Let me know if you'd like this in another format or need any additional adjustments!





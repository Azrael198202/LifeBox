# lifebox

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Localization

flutter clean
flutter pub get
flutter gen-l10n


# api

## python install

1. create the virtual environment
python3 -m venv .venv

2. start the environment (windows powershell)
.\.venv\Scripts\Activate.ps1

3.vscode ctrl + shift + P > Python: Select Interpreter > Python (.venv)

4. FastApi's requirement install
pip install fastapi uvicorn[standard] pydantic httpx python-dateutil

confirm pip list

5. create the FastAPI's prject

lifebox_api/
 ├─ app/
 │   ├─ __init__.py
 │   ├─ main.py
 │   ├─ schemas.py
 │   ├─ prompts.py
 │   └─ ollama_client.py
 └─ .venv/

 ## ollama model

 1. ollama list
 2. ollama pull qwen2.5:7b-instruct

 ## start
 uvicorn app.main:app --reload
 Uvicorn running on http://127.0.0.1:8000


 ## icon

pubspec.yaml
 dev_dependencies:
  flutter_launcher_icons: ^0.13.1
  flutter_native_splash: ^2.4.0

 flutter_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"

flutter_native_splash:
  color: "#FFFFFF"
  image: assets/icon/white.png

  android: true
  ios: true

flutter pub get
flutter pub run flutter_launcher_icons




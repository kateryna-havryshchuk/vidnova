# vidnova_frontend

## Real device testing (Android)

If your API runs on the dev PC (port 5080), you must point the app to the PC's
LAN IP and allow cleartext HTTP during development.

1) Find the PC IP on the same Wi-Fi (example: 192.168.1.50)
2) Ensure the backend listens on all interfaces (0.0.0.0:5080)
3) Run the app with API base URL override:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:5080
```

Alternative (USB):

```bash
adb reverse tcp:5080 tcp:5080
```

Then you can use http://localhost:5080 on the device.

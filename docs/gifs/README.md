# Demo GIFs

The GIFs used in the main README. They were recorded on an Android emulator
running the debug build against `tools/mock_server`.

| File | What it should show |
|------|---------------------|
| `hero.gif` | The full flow: edit the server config, pull to refresh, send the app to the background, the home screen shows the new name and icon |
| `combinations.gif` | The same name with different icons, then the same icon with different names |
| `server-switch.gif` | `tools/mock_server/config.json` edited side by side with the app switching |
| `add-brand.gif` | Adding a new key in the catalog files and the new brand appearing |

Keep each GIF **5–10 seconds** and **under 5 MB**.

## Re-recording

**Android** (device or emulator):

```sh
adb shell screenrecord /sdcard/demo.mp4   # Ctrl+C to stop
adb pull /sdcard/demo.mp4
```

**iOS Simulator:**

```sh
xcrun simctl io booted recordVideo demo.mp4   # Ctrl+C to stop
```

## Converting to GIF

```sh
ffmpeg -i demo.mp4 -vf "fps=15,scale=360:-1:flags=lanczos" -loop 0 out.gif
```

If the file is over 5 MB, lower `fps` to 10 or `scale` to 300, or trim with `-ss <start> -t <seconds>`.

# SimpleAudioRecord

Sample code demonstrating audio recording features for iOS using SwiftUI.

## Overview

This is a **sample code project** providing minimal audio recording functionality. This repository demonstrates basic implementation patterns and is not intended for production use.

## Features

- Real-time audio recording with visual level monitoring
- Saves only the **most recent recording** (previous recordings are automatically deleted)
- **WAV format only** (PCM Int16, 44.1kHz)
- Support for various audio input devices (iPhone microphone, AirPods, Bluetooth devices)
- Simple playback of recorded audio
- SwiftUI-based user interface

## Technologies

Built with SwiftUI and AVFoundation framework for iOS. Utilizes AVAudioEngine for real-time audio processing, AVAudioSession for device management, and AVAudioPlayer for playback. Implements @Observable macros for state management with comprehensive error handling and thread-safe audio queue processing.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Limitations

- **Only supports WAV format** (.wav files with PCM Int16 encoding)
- **Saves only the last recording** (no recording history)
- **Minimal support** - basic functionality only
- Temporary file storage (files are deleted when app is terminated)

## Screenshot
<img width="375" height="815" alt="SimpleAudioRecord" src="https://github.com/user-attachments/assets/0a05b782-2922-47c7-ad2a-7407d4382f5b" />

## Installation

1. Clone this repository
```bash
git clone https://github.com/notoroid/SimpleAudioRecord.git
```

2. Open `SimpleAudioRecord.xcodeproj` in Xcode

3. Build and run on your device or simulator

## Usage

1. Grant microphone permission when prompted
2. Tap the record button to start recording
3. Tap again to stop recording
4. Use the play button to listen to your recording

## License

MIT License - See [LICENSE](LICENSE) file for details

## Author

Kaname Noto ([@notoroid](https://github.com/notoroid))

## Notes

This is sample code for learning purposes. For production applications, consider implementing:
- Multiple recording format support (AAC, MP3, etc.)
- Recording history management
- Persistent storage
- Advanced audio processing features
- Comprehensive error handling and recovery

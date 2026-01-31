//
//  SimpleAudioRecordApp.swift
//  SimpleAudioRecord
//
//  Created by 能登 要 on 2026/01/31.
//

import SwiftUI

@main
struct SimpleAudioRecordApp: App {
    let audioLevelManager = AudioLevelManager()
    let simpleAudioPlayer = SimpleAudioPlayer()
    var body: some Scene {
        WindowGroup {
            ContentView(audioLevelManager: audioLevelManager, simpleAudioPlayer: simpleAudioPlayer)
        }
    }
}

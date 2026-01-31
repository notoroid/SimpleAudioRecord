//
//  ContentView.swift
//  SimpleAudioRecord
//
//  Created by 能登 要 on 2026/01/27.
//

import SwiftUI
import Combine
import AVKit

struct ContentView: View {
    let audioLevelManager: AudioLevelManager
    let simpleAudioPlayer: SimpleAudioPlayer
    
    /// Audio levels for the 14 bars (0.0 - 1.0)
    @State private var audioLevels: [Float] = Array(repeating: 0.0, count: 14)

    /// Timer for demo animation
    @State private var animationTimer: Timer?

    let graphGain: Float = 2
    private func startAudioLevelAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                // Simulate audio levels with smooth random movement
                for i in 0..<14 {
                    let currentLevel = audioLevelManager.audioLevel * graphGain
                    
                    let change = Float.random(in: -0.2...0.2)
                    audioLevels[i] = max(0.1, min(1.0, currentLevel + change))
                }
            }
        }
    }

    private func stopAudioLevelAnimation() {
        for i in 0..<14 {
            audioLevels[i] = 0
        }

        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    var body: some View {
        VStack {
            SelectMicButtonView(title: "入力先変更", style: .plain, interaction: audioLevelManager.inputPickerInteraction) {
                audioLevelManager.inputPickerInteraction.present()
            }
            .frame(width: 100, height: 20)
            .padding()
            
            Button {
                if audioLevelManager.isRecording {
                    audioLevelManager.stopRecording()
                    stopAudioLevelAnimation()
                } else {
                    audioLevelManager.startRecording()
                    startAudioLevelAnimation()
                }
            } label: {
                if audioLevelManager.isRecording {
                    Text("停止")
                } else {
                    Text("録音")
                }
            }
            .padding(.vertical)
            
            Rectangle()
                .frame(width: 59, height: 59)
                .standardAudioLevelVisualizerModifier(levels: audioLevels)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical)
            
            Text("audioLevel=\(audioLevelManager.audioLevel)")
                .padding(.vertical)

            Button {
                if simpleAudioPlayer.isPlayingSound {
                    simpleAudioPlayer.stopSound()
                } else {
                    simpleAudioPlayer.playSound()
                }
            } label: {
                if simpleAudioPlayer.isPlayingSound {
                    Text("停止")
                } else {
                    Text("再生")
                }
            }
            .padding(.vertical)
            
            
        }
    }
}

#Preview {
    ContentView(audioLevelManager: AudioLevelManager(), simpleAudioPlayer: SimpleAudioPlayer())
}

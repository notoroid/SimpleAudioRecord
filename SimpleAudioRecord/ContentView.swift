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
    
    @State var audioLevel: Float = 0.0
    
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
                } else {
                    audioLevelManager.startRecording()
                }
            } label: {
                if audioLevelManager.isRecording {
                    Text("停止")
                } else {
                    Text("録音")
                }
            }
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

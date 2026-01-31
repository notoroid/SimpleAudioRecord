//
//  SimpleAudioPlayer.swift
//  SimpleAudioRecord
//
//  Created by 能登 要 on 2026/01/31.
//

import Foundation
import AVFoundation
import Observation

protocol SimpleAudioPlayerProtocol {
    func playSound()
    func stopSound()
    var isPlayingSound: Bool { get }
}

@Observable
class SimpleAudioPlayer: NSObject, SimpleAudioPlayerProtocol {
    
    @ObservationIgnored private var audioPlayer: AVAudioPlayer?
    @ObservationIgnored private let queue = DispatchQueue.global(qos: .userInteractive)
    
    var isPlayingSound: Bool = false
    
    override init() {
        super.init()
    }
    
    func playSound() {
        queue.async { [weak self] in
            self?.playSoundInternal()
        }
    }
    
    func stopSound() {
        queue.async { [weak self] in
            self?.stopSoundInternal()
        }
    }
    
    private func playSoundInternal() {
        // temp directoryのsimple.mp4のパスを取得
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("simple.wav")
        
        // ファイルが存在するかチェック
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("ファイルが存在しません: \(fileURL.path)")
            return
        }
        
        do {
            // AVAudioSessionの設定
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
            
            // AVAudioPlayerの初期化
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            
            // 再生開始
            let success = audioPlayer?.play() ?? false
            
            DispatchQueue.main.async {
                self.isPlayingSound = success
            }
            
            if success {
                print("再生開始: \(fileURL.path)")
            } else {
                print("再生開始に失敗しました")
            }
            
        } catch {
            print("再生エラー: \(error)")
            DispatchQueue.main.async {
                self.isPlayingSound = false
            }
        }
    }
    
    private func stopSoundInternal() {
        guard let player = audioPlayer, player.isPlaying else {
            return
        }
        
        player.stop()
        
        DispatchQueue.main.async {
            self.isPlayingSound = false
        }
        
        print("再生停止")
    }
}

// MARK: - AVAudioPlayerDelegate
extension SimpleAudioPlayer: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlayingSound = false
        }
        
        if flag {
            print("再生完了")
        } else {
            print("再生が正常に完了しませんでした")
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            self.isPlayingSound = false
        }
        
        if let error = error {
            print("デコードエラー: \(error)")
        }
    }
}

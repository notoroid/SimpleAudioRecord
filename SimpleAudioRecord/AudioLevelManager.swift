//
//  AudioLevelManager.swift
//  SimpleAudioRecord
//
//  Created by 能登 要 on 2026/01/27.
//

import Foundation
import AVFoundation
import Observation
import Combine
import AVKit

protocol AudioLevelManagerProtocl {
    var isRecording: Bool { get }
    var recordingError: Error? { get }
    var audioLevel: Float { get }
//    var audioLvelPublisher: AnyPublisher<Float, Never> { get }
    
    func startRecording()
    func stopRecording()
}

class InputPickerDelegateAdaptor: NSObject, AVInputPickerInteraction.Delegate {
    
}
    
@Observable
class AudioLevelManager: AudioLevelManagerProtocl {
    
    enum AudioIndicator {
        static let minLevel: Float = 0.0
        static let maxLevel: Float = 0.3
        static let gainfactor: Float = 3.0
    }
    
    @ObservationIgnored private var isSessionActivate = false
    @ObservationIgnored private var audioEngine = AVAudioEngine()
    @ObservationIgnored private let session = AVAudioSession.sharedInstance()
    @ObservationIgnored private var inputNode: AVAudioInputNode!
    @ObservationIgnored private var queue = DispatchQueue.global(qos: .userInteractive)
    @ObservationIgnored private var audioFile: AVAudioFile?
    
    var isRecording = false
    var recordingError: Error?
    var audioLevel: Float = 0.0
    
    var internalInputPickerInteraction: AVInputPickerInteraction? /*= */
    let inputPickerDelegateAdaptor = InputPickerDelegateAdaptor()
    
    
    @ObservationIgnored private let audioLevelSubject = CurrentValueSubject<Float, Never>(0.0)
    @ObservationIgnored var audioLvelPublisher: AnyPublisher<Float, Never> {
        audioLevelSubject
            .receive(on: DispatchQueue.global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }
    var cancellables: Set<AnyCancellable> = []
    
    var inputPickerInteraction: AVInputPickerInteraction {
        if let internalInputPickerInteraction {
            return internalInputPickerInteraction
        }
        _ = getActivatedSession()
        
        internalInputPickerInteraction = AVInputPickerInteraction(audioSession: session)
        internalInputPickerInteraction?.delegate = inputPickerDelegateAdaptor
        
        return internalInputPickerInteraction!
    }
    
    private func getActivatedSession() -> AVAudioSession {
        do {
            if !isSessionActivate {
                try session.setCategory(AVAudioSession.Category.record)
                try session.setActive(true)
                isSessionActivate = true
            }
        } catch {
            self.recordingError = error
        }
        return session
    }
    
    init () {
        audioLevelSubject
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .sink { [weak self] audioLevel in
                let normalizedLevel = min(max((audioLevel - AudioIndicator.minLevel) / (AudioIndicator.maxLevel - AudioIndicator.minLevel), 1 ), 0)
                if normalizedLevel < 0.01 {
                    self?.audioLevel = 0
                } else {
                    let gainedAudioLevel = min(1, normalizedLevel * AudioIndicator.gainfactor)
                    self?.audioLevel = gainedAudioLevel
                }
                
                self?.audioLevel = audioLevel
            }
            .store(in: &cancellables)
    }
    
    private func startRcordingInternal() {
        do {
            _ = getActivatedSession()
            
            // Sweep audio engine
            if audioEngine.isRunning {
                audioEngine.inputNode.removeTap(onBus: 0)
                audioEngine.stop()
            }
            
            // WAVファイルのパスを取得
            let tempDir = FileManager.default.temporaryDirectory
            let audioFileURL = tempDir.appendingPathComponent("simple.wav")
            
            // 既存のファイルを削除
            if FileManager.default.fileExists(atPath: audioFileURL.path) {
                try FileManager.default.removeItem(at: audioFileURL)
            }
            
            inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            let dummyOutputFormat = AVAudioFormat(
                commonFormat: .pcmFormatInt16,
                sampleRate: 44100,
                channels: 1,
                interleaved: true
            )!
            
            // WAVファイルを作成
            audioFile = try AVAudioFile(
                forWriting: audioFileURL,
                settings: dummyOutputFormat.settings,
                commonFormat: .pcmFormatInt16,
                interleaved: true
            )
            
            let converter = AVAudioConverter(from: recordingFormat, to: dummyOutputFormat)!
            
            inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) {[weak self] buffer, audioTime in
                let inputFrameCount = buffer.frameLength
                let outputFrameCount = AVAudioFrameCount(
                    Double(inputFrameCount) * dummyOutputFormat.sampleRate / recordingFormat.sampleRate
                )
                
                guard let convertedBuffer = AVAudioPCMBuffer(
                    pcmFormat: dummyOutputFormat,
                    frameCapacity: outputFrameCount
                ) else {
                    return
                }
                
                var error: NSError?
                let outputStatus = converter.convert( to: convertedBuffer, error: &error) { _, status in
                    status.pointee = AVAudioConverterInputStatus.haveData
                    return buffer
                }
                
                if let convertError = error {
                    DispatchQueue.main.async {
                        self?.recordingError = convertError
                    }
                } else if outputStatus == .haveData {
                    self?.calculateAudioLevel(from: buffer)
                    
                    // convertedBufferをWAVファイルに書き込む
                    do {
                        try self?.audioFile?.write(from: convertedBuffer)
                    } catch {
                        DispatchQueue.main.async {
                            self?.recordingError = error
                        }
                    }
                }
            }
            audioEngine.prepare()
            try audioEngine.start()

            DispatchQueue.main.async {
                self.isRecording = true
                self.recordingError = nil
            }
        } catch {
            print("録音開始エラー")
            DispatchQueue.main.async {
                self.recordingError = error
                self.isRecording = false
            }
        }
    }
    
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer){
        guard let channnelData = buffer.floatChannelData else { return }
                
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0.0
        
        for i in 0..<frameLength {
            let sample = channnelData[0][i]
            sum += sample * sample
        }

        let rms = sqrt(sum / Float(frameLength))
        let level = min(max(rms, 0.0), 1.0)
        audioLevelSubject.send(level)
    }
    
    private func stopRecordingInternal() {
        if audioEngine.isRunning {
            inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        
        // オーディオファイルをクローズ
        audioFile = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
            self.audioLevel = 0
        }
    }
    
    func startRecording() {
        queue.async { [weak self] in
            self?.startRcordingInternal()
        }
    }
    
    func stopRecording() {
        queue.async { [weak self] in
            self?.stopRecordingInternal()
        }
    }
}

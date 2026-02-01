//
//  StandardAudioLevelVisualizerModifier.swift
//  SimpleAudioRecord
//
//  Created by kaname.noto on 2026/01/26.
//

import SwiftUI

// MARK: - Constants
enum AudioLevelVisualizerConstants {
    static let barCount = 14
    static let barWidthRatio: CGFloat = 0.4
    static let backgroundColor = Color(red: 0.8, green: 0.8, blue: 0.8)
    static let barColor = Color(red: 0.42, green: 0.84, blue: 0.5)
}

// MARK: - SwiftUI Audio Level Visualizer View
/// Pure SwiftUI audio level visualizer with 14 bars
struct AudioLevelVisualizerView: View {
    /// Audio levels for each of the 14 bars (0.0 - 1.0)
    let levels: [Float]

    var body: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(AudioLevelVisualizerConstants.barCount)
            let barWidth = cellWidth * AudioLevelVisualizerConstants.barWidthRatio

            ZStack {
                // Background
                AudioLevelVisualizerConstants.backgroundColor

                // Bars
                HStack(spacing: 0) {
                    ForEach(0..<AudioLevelVisualizerConstants.barCount, id: \.self) { index in
                        let level = CGFloat(levels.indices.contains(index) ? levels[index] : 0)
                        let barHeight = geometry.size.height * level

                        ZStack(alignment: .bottom) {
                            Color.clear
                                .frame(width: cellWidth)

                            AudioLevelVisualizerConstants.barColor
                                .frame(width: barWidth, height: barHeight)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - SwiftUI Audio Level Visualizer Modifier
/// Audio level visualizer using pure SwiftUI (no Metal shader)
struct StandardAudioLevelVisualizerModifier: ViewModifier {
    /// Audio levels for each of the 14 bars (0.0 - 1.0)
    let levels: [Float]

    func body(content: Content) -> some View {
        content.overlay {
            AudioLevelVisualizerView(levels: levels)
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Apply audio level visualizer using pure SwiftUI (no Metal shader)
    /// - Parameter levels: Array of 14 float values (0.0 - 1.0) for each bar
    /// - Returns: View with audio level visualizer overlay applied
    func standardAudioLevelVisualizerModifier(levels: [Float]) -> some View {
        modifier(StandardAudioLevelVisualizerModifier(levels: levels))
    }
    
    func standardAudioLevelVisualizerModifier(level: Float) -> some View {
        modifier(StandardAudioLevelVisualizerModifier(levels: [Float].init(repeating: level, count: 14)))
    }

}



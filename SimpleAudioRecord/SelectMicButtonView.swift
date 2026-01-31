//
//  SelectMicButtonView.swift
//  SimpleAudioRecord
//
//  Created by 能登 要 on 2026/01/30.
//

import SwiftUI
import UIKit

/// Enhanced SelectMicButtonView with customizable UIButton.Configuration
struct SelectMicButtonView: UIViewRepresentable {
    /// Button title text
    var title: String = "Select Microphone"
    
    /// Button configuration style
    var style: ButtonStyle = .filled
    
    /// Button corner style
    var cornerStyle: UIButton.Configuration.CornerStyle = .medium
    
    /// Content insets
    var contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(
        top: 12,
        leading: 20,
        bottom: 12,
        trailing: 20
    )
    
    /// Base background color
    var backgroundColor: UIColor = .systemBlue
    
    /// Base foreground color
    var foregroundColor: UIColor = .white
    
    /// Optional UIInteraction to add to the button
    var interaction: UIInteraction? = nil
    
    /// Action to perform when button is tapped
    var action: () -> Void
    
    // MARK: - Button Style
    
    enum ButtonStyle {
        case filled
        case tinted
        case gray
        case plain
        case bordered
        case borderedTinted
        case borderedProminent
        
        var configuration: UIButton.Configuration {
            switch self {
            case .filled:
                return .filled()
            case .tinted:
                return .tinted()
            case .gray:
                return .gray()
            case .plain:
                return .plain()
            case .bordered:
                return .bordered()
            case .borderedTinted:
                return .borderedTinted()
            case .borderedProminent:
                return .borderedProminent()
            }
        }
    }
    
    // MARK: - UIViewRepresentable
    
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        
        // Create button configuration based on style
        var configuration = style.configuration
        configuration.title = title
        
        if style == .plain {
            configuration.baseBackgroundColor = .clear
            configuration.baseForegroundColor = backgroundColor
        } else {
            configuration.baseBackgroundColor = backgroundColor
            configuration.baseForegroundColor = foregroundColor
            configuration.cornerStyle = cornerStyle
        }
        
        // Set content insets using UIButton.Configuration
        configuration.contentInsets = contentInsets
        
        // Configure title font
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        
        // Apply configuration to button
        button.configuration = configuration
        
        // Add UIInteraction if provided
        if let interaction = interaction {
            button.addInteraction(interaction)
        }
        
        // Add target for tap action
        button.addTarget(
            context.coordinator,
            action: #selector(Coordinator.buttonTapped),
            for: .touchUpInside
        )
        
        return button
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        // Update button configuration if properties change
        var configuration = uiView.configuration
        configuration?.title = title
        if style == .plain {
            configuration?.baseBackgroundColor = .clear
            configuration?.baseForegroundColor = backgroundColor
        } else {
            configuration?.baseBackgroundColor = backgroundColor
            configuration?.baseForegroundColor = foregroundColor
            configuration?.cornerStyle = cornerStyle
        }
        configuration?.cornerStyle = cornerStyle
        configuration?.contentInsets = contentInsets
        uiView.configuration = configuration
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    // MARK: - Coordinator
    
    class Coordinator {
        var action: () -> Void
        
        init(action: @escaping () -> Void) {
            self.action = action
        }
        
        @objc func buttonTapped() {
            action()
        }
    }
}

// MARK: - Convenience Initializers

extension SelectMicButtonView {
    /// Creates a filled button with default settings
    init(
        title: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = .plain
        self.action = action
    }

    init(
        title: String,
        interaction: UIInteraction,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = .plain
        self.interaction = interaction
        self.action = action
    }

    /// Creates a button with custom style
    init(
        title: String,
        style: ButtonStyle,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    init(
        title: String,
        style: ButtonStyle,
        interaction: UIInteraction,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.interaction = interaction
        self.action = action
    }

}

// MARK: - Preview

#Preview("Button Styles") {
    ScrollView {
        VStack(spacing: 20) {
            Group {
                SelectMicButtonView(
                    title: "Plain Button",
                    style: .plain
                ) {
                    print("Filled tapped")
                }
                .frame(height: 44)

                Text("Filled Style")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Filled Button",
                    style: .filled
                ) {
                    print("Filled tapped")
                }
                .frame(height: 44)
                
                Text("Tinted Style")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Tinted Button",
                    style: .tinted
                ) {
                    print("Tinted tapped")
                }
                .frame(height: 44)
                
                Text("Gray Style")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Gray Button",
                    style: .gray
                ) {
                    print("Gray tapped")
                }
                .frame(height: 44)
                
                Text("Bordered Style")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Bordered Button",
                    style: .bordered
                ) {
                    print("Bordered tapped")
                }
                .frame(height: 44)
                
                Text("Bordered Tinted Style")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Bordered Tinted",
                    style: .borderedTinted
                ) {
                    print("Bordered tinted tapped")
                }
                .frame(height: 44)
            }
            
            Group {
                Text("Custom Insets")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Large Padding",
                    style: .filled,
                    cornerStyle: .large,
                    contentInsets: NSDirectionalEdgeInsets(
                        top: 20,
                        leading: 40,
                        bottom: 20,
                        trailing: 40
                    ),
                    backgroundColor: .systemPurple,
                    foregroundColor: .white
                ) {
                    print("Large padding tapped")
                }
                .frame(height: 60)
                
                Text("Small Padding")
                    .font(.headline)
                SelectMicButtonView(
                    title: "Compact",
                    style: .filled,
                    cornerStyle: .small,
                    contentInsets: NSDirectionalEdgeInsets(
                        top: 8,
                        leading: 12,
                        bottom: 8,
                        trailing: 12
                    ),
                    backgroundColor: .systemGreen,
                    foregroundColor: .white
                ) {
                    print("Small padding tapped")
                }
                .frame(height: 36)
            }
        }
        .padding()
    }
}

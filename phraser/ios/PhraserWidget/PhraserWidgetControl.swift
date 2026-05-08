//
//  PhraserWidgetControl.swift
//  PhraserWidget
//
//  Created by Haris on 19/10/2025.
//
//  NOTE: This file requires iOS 18.0+ and is currently disabled
//  to maintain compatibility with iOS 14+

import AppIntents
import SwiftUI
import WidgetKit

// ControlWidget is only available in iOS 18.0+
@available(iOS 18.0, *)
struct PhraserWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.iam.blessed.affirmation.PhraserWidget",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

@available(iOS 18.0, *)
extension PhraserWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

@available(iOS 18.0, *)
struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}

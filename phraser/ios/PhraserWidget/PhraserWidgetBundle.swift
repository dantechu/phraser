//
//  PhraserWidgetBundle.swift
//  PhraserWidget
//
//  Created by Haris on 19/10/2025.
//

import WidgetKit
import SwiftUI

// Note: We only include the basic PhraserWidget to support iOS 14+
// Control and LiveActivity widgets require iOS 18+ and are commented out

// Removed the @main from here since PhraserWidget.swift has it
struct PhraserWidgetBundle: WidgetBundle {
    var body: some Widget {
        PhraserWidget()
        // Uncomment these if you want iOS 18+ features in the future:
        // if #available(iOS 18.0, *) {
        //     PhraserWidgetControl()
        //     PhraserWidgetLiveActivity()
        // }
    }
}

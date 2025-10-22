//
//  PhraserWidget.swift
//  PhraserWidget
//
//  Created by Haris on 19/10/2025.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: "I am blessed with infinite potential", category: "Affirmation", hasData: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Move to next quote automatically
        moveToNextQuote()

        // Load updated entry
        let currentEntry = loadEntry()

        // Get refresh interval from UserDefaults (in minutes)
        let sharedDefaults = UserDefaults(suiteName: "group.phraser.widget")
        let intervalMinutes = sharedDefaults?.integer(forKey: "widgetRefreshInterval") ?? 5

        // Update based on user preference
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: Date())!
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))

        print("📱 iOS Widget: Next update in \(intervalMinutes) minutes")
        completion(timeline)
    }

    private func loadEntry() -> SimpleEntry {
        // Load data from shared UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.phraser.widget")

        let quote = sharedDefaults?.string(forKey: "quote_text") ?? "Open Phraser for daily inspiration"
        let category = sharedDefaults?.string(forKey: "quote_category") ?? "Daily Quote"
        let hasData = sharedDefaults?.bool(forKey: "has_data") ?? false

        return SimpleEntry(date: Date(), quote: quote, category: category, hasData: hasData)
    }

    private func moveToNextQuote() {
        // Load data from shared UserDefaults (App Group)
        guard let sharedDefaults = UserDefaults(suiteName: "group.phraser.widget") else {
            print("❌ iOS Widget: Could not access shared UserDefaults")
            return
        }

        // Get current index and total quotes
        let currentIndex = sharedDefaults.integer(forKey: "current_quote_index")
        let totalQuotes = sharedDefaults.integer(forKey: "total_quotes")

        print("📱 iOS Widget: Current index: \(currentIndex), Total quotes: \(totalQuotes)")

        guard totalQuotes > 0 else {
            print("❌ iOS Widget: No quotes available in storage")
            return
        }

        // Calculate next index (wrap around if at end)
        let nextIndex = (currentIndex + 1) % totalQuotes

        // Get the next quote and category
        let nextQuote = sharedDefaults.string(forKey: "quote_\(nextIndex)")
        let nextCategory = sharedDefaults.string(forKey: "category_\(nextIndex)")

        print("📱 iOS Widget: Moving to index \(nextIndex), Quote exists: \(nextQuote != nil)")

        if let quote = nextQuote, let category = nextCategory {
            // Update the widget data with next quote
            sharedDefaults.set(nextIndex, forKey: "current_quote_index")
            sharedDefaults.set(quote, forKey: "quote_text")
            sharedDefaults.set(category, forKey: "quote_category")

            print("✅ iOS Widget: Updated to quote \(nextIndex): \(String(quote.prefix(50)))...")
        } else {
            print("❌ iOS Widget: Quote at index \(nextIndex) not found")
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: String
    let category: String
    let hasData: Bool
}

struct PhraserWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            // Gradient background - matching Android widget colors
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.29, green: 0.56, blue: 0.89), // #4A90E2
                    Color(red: 0.60, green: 0.40, blue: 0.80), // #9966CC
                    Color(red: 0.80, green: 0.40, blue: 0.60)  // #CC6699
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea() // Extend to edges

            VStack(spacing: 12) {
                // Quote icon
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: family == .systemSmall ? 20 : 24))
                    .foregroundColor(.white)
                    .padding(.top, 8)

                Spacer()

                // Quote text
                Text(entry.quote)
                    .font(.system(size: family == .systemSmall ? 14 : 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                    .minimumScaleFactor(0.8)

                Spacer()

                // Category badge
                Text(entry.category.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(0.9)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.25))
                    )
                    .padding(.bottom, 8)
            }
        }
        .widgetURL(URL(string: "phraser://open_quote"))
    }
}

@main
struct PhraserWidget: Widget {
    let kind: String = "PhraserWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PhraserWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        // iOS 17+ background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.29, green: 0.56, blue: 0.89),
                                Color(red: 0.60, green: 0.40, blue: 0.80),
                                Color(red: 0.80, green: 0.40, blue: 0.60)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
            } else {
                PhraserWidgetEntryView(entry: entry)
                    .background(
                        // iOS 16 and below background
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.29, green: 0.56, blue: 0.89),
                                Color(red: 0.60, green: 0.40, blue: 0.80),
                                Color(red: 0.80, green: 0.40, blue: 0.60)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .configurationDisplayName("Phraser Quote")
        .description("Display daily inspirational quotes from your current phraser list")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#if DEBUG
struct PhraserWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhraserWidgetEntryView(entry: SimpleEntry(date: Date(), quote: "I am blessed with infinite abundance and prosperity", category: "Affirmation", hasData: true))
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            PhraserWidgetEntryView(entry: SimpleEntry(date: Date(), quote: "Today I choose to see the beauty in every moment and embrace all possibilities", category: "Daily Inspiration", hasData: true))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
#endif

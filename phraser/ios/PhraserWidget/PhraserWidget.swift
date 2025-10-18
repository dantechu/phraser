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
        let currentEntry = loadEntry()

        // Update every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))

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
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.29, green: 0.56, blue: 0.89), // #4A90E2
                    Color(red: 0.60, green: 0.40, blue: 0.80), // #9966CC
                    Color(red: 0.80, green: 0.40, blue: 0.60)  // #CC6699
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

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
            PhraserWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Phraser Quote")
        .description("Display daily inspirational quotes from your current phraser list")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

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

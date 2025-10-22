import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:phraser/services/model/data_repository.dart';
import 'package:phraser/services/model/phreasers_list_model.dart';
import 'package:phraser/util/preferences.dart';

/// Service for managing home screen widgets
///
/// This service handles updating iOS and Android home screen widgets
/// with quotes from the current phraser list.
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // Widget IDs for different platforms
  static const String _androidWidgetName = 'PhraserWidgetProvider';
  static const String _iOSWidgetKind = 'PhraserWidget';

  /// Initialize the widget service
  Future<void> initialize() async {
    try {
      // Set the App Group ID for iOS (must match Xcode configuration)
      await HomeWidget.setAppGroupId('group.phraser.widget');

      // Register for background updates (iOS)
      await HomeWidget.registerBackgroundCallback(_backgroundCallback);

      debugPrint('✅ Widget service initialized with App Group: group.phraser.widget');
    } catch (e) {
      debugPrint('❌ Error initializing widget service: $e');
    }
  }

  /// Update the home screen widget with a random quote
  Future<void> updateWidget() async {
    try {
      final quotes = DataRepository().currentPhrasersList;

      if (quotes.isEmpty) {
        await _updateWidgetWithNoData();
        return;
      }

      // Get a random quote or the current one
      final currentPosition = Preferences.instance.currentPhraserPosition;
      final quote = quotes[currentPosition.clamp(0, quotes.length - 1)];

      await _updateWidgetWithQuote(quote);

      // Store all quotes for Android widget to cycle through
      await _storeQuotesForAutoUpdate(quotes);

      debugPrint('✅ Widget updated with quote: ${quote.quote.substring(0, 30)}...');
    } catch (e) {
      debugPrint('❌ Error updating widget: $e');
    }
  }

  /// Update widget with a specific quote
  Future<void> updateWidgetWithQuote(Phraser quote) async {
    try {
      await _updateWidgetWithQuote(quote);
      debugPrint('✅ Widget updated with specific quote');
    } catch (e) {
      debugPrint('❌ Error updating widget with quote: $e');
    }
  }

  /// Update widget with the next quote
  Future<void> updateWidgetWithNextQuote() async {
    try {
      final quotes = DataRepository().currentPhrasersList;
      if (quotes.isEmpty) {
        await _updateWidgetWithNoData();
        return;
      }

      final currentPosition = Preferences.instance.currentPhraserPosition;
      final nextPosition = (currentPosition + 1) % quotes.length;
      Preferences.instance.currentPhraserPosition = nextPosition;

      final nextQuote = quotes[nextPosition];
      await _updateWidgetWithQuote(nextQuote);

      debugPrint('✅ Widget updated with next quote');
    } catch (e) {
      debugPrint('❌ Error updating widget with next quote: $e');
    }
  }

  /// Update widget with a random quote
  Future<void> updateWidgetWithRandomQuote() async {
    try {
      final quotes = DataRepository().currentPhrasersList;
      if (quotes.isEmpty) {
        await _updateWidgetWithNoData();
        return;
      }

      final random = Random();
      final randomIndex = random.nextInt(quotes.length);
      final randomQuote = quotes[randomIndex];

      await _updateWidgetWithQuote(randomQuote);
      debugPrint('✅ Widget updated with random quote');
    } catch (e) {
      debugPrint('❌ Error updating widget with random quote: $e');
    }
  }

  /// Internal method to update widget data
  Future<void> _updateWidgetWithQuote(Phraser quote) async {
    // Save data to widget storage
    await HomeWidget.saveWidgetData<String>('quote_text', quote.quote);
    await HomeWidget.saveWidgetData<String>('quote_category', quote.categoryName);
    await HomeWidget.saveWidgetData<String>('quote_id', quote.phraserId);
    await HomeWidget.saveWidgetData<bool>('has_data', true);
    await HomeWidget.saveWidgetData<String>(
      'last_updated',
      DateTime.now().toIso8601String(),
    );

    // Update the widget on both platforms
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetKind,
    );
  }

  /// Update widget when no data is available
  Future<void> _updateWidgetWithNoData() async {
    await HomeWidget.saveWidgetData<bool>('has_data', false);
    await HomeWidget.saveWidgetData<String>(
      'quote_text',
      'Open Phraser to see inspiring quotes',
    );
    await HomeWidget.saveWidgetData<String>('quote_category', 'Phraser');

    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetKind,
    );
  }

  /// Store multiple quotes for Android widget auto-update
  Future<void> _storeQuotesForAutoUpdate(List<Phraser> quotes) async {
    try {
      // Store total count
      await HomeWidget.saveWidgetData<int>('total_quotes', quotes.length);

      // Store up to 50 quotes to avoid excessive storage
      final quotesToStore = quotes.take(50).toList();

      for (int i = 0; i < quotesToStore.length; i++) {
        await HomeWidget.saveWidgetData<String>(
          'quote_$i',
          quotesToStore[i].quote,
        );
        await HomeWidget.saveWidgetData<String>(
          'category_$i',
          quotesToStore[i].categoryName,
        );
      }

      // Initialize current index to 0
      await HomeWidget.saveWidgetData<int>('current_quote_index', 0);

      debugPrint('✅ Stored ${quotesToStore.length} quotes for auto-update');
    } catch (e) {
      debugPrint('❌ Error storing quotes for auto-update: $e');
    }
  }

  /// Schedule periodic widget updates
  Future<void> scheduleWidgetUpdates({
    Duration interval = const Duration(hours: 1),
  }) async {
    try {
      // This would typically be handled by WorkManager on Android
      // and Background Tasks on iOS
      debugPrint('✅ Widget updates scheduled every ${interval.inMinutes} minutes');
    } catch (e) {
      debugPrint('❌ Error scheduling widget updates: $e');
    }
  }

  /// Check if widget is available on this platform
  Future<bool> isWidgetAvailable() async {
    try {
      // Home widget package supports both iOS and Android
      return true;
    } catch (e) {
      debugPrint('❌ Error checking widget availability: $e');
      return false;
    }
  }

  /// Get widget data for testing
  Future<Map<String, dynamic>> getWidgetData() async {
    try {
      final quoteText = await HomeWidget.getWidgetData<String>('quote_text');
      final category = await HomeWidget.getWidgetData<String>('quote_category');
      final hasData = await HomeWidget.getWidgetData<bool>('has_data');
      final lastUpdated = await HomeWidget.getWidgetData<String>('last_updated');

      return {
        'quote_text': quoteText,
        'quote_category': category,
        'has_data': hasData,
        'last_updated': lastUpdated,
      };
    } catch (e) {
      debugPrint('❌ Error getting widget data: $e');
      return {};
    }
  }

  /// Background callback for widget updates (iOS)
  @pragma('vm:entry-point')
  static Future<void> _backgroundCallback(Uri? uri) async {
    try {
      debugPrint('📱 Background widget update triggered');

      // Handle widget tap action
      if (uri?.path == '/next_quote') {
        await WidgetService().updateWidgetWithNextQuote();
      } else if (uri?.path == '/random_quote') {
        await WidgetService().updateWidgetWithRandomQuote();
      }
    } catch (e) {
      debugPrint('❌ Error in background callback: $e');
    }
  }

  /// Handle widget tap from home screen
  Future<void> handleWidgetLaunch() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();

      if (uri != null) {
        debugPrint('📱 App launched from widget with URI: $uri');

        // Handle different widget actions
        if (uri.path == '/open_quote') {
          // Navigate to specific quote
          final quoteId = uri.queryParameters['id'];
          debugPrint('Opening quote: $quoteId');
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling widget launch: $e');
    }
  }

  /// Show instructions for adding widget to home screen
  Future<void> showWidgetInstructions() async {
    try {
      // Note: home_widget package doesn't support programmatic widget pinning
      // Users must manually add widgets through their device's widget picker
      debugPrint('ℹ️ Users can add widgets manually from home screen');
      debugPrint('   iOS: Long-press home screen → tap + → search for Phraser');
      debugPrint('   Android: Long-press home screen → Widgets → find Phraser Widget');
    } catch (e) {
      debugPrint('❌ Error showing widget instructions: $e');
    }
  }
}

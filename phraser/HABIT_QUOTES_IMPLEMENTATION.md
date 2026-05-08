# Habit Quotes Implementation Guide

## Overview

This implementation provides a category-based quote merging system for the Habit Builder feature. When a user selects or creates a habit, the system automatically merges and shuffles quotes from relevant phraser categories based on the habit's category.

---

## Files Modified/Created

### 1. New Files Created

#### `/lib/services/habit_quote_service.dart`
- Main service for managing habit quotes
- Maps habit categories to phraser category IDs
- Provides methods to fetch, merge, and shuffle quotes
- Includes console logging for debugging

#### `/habit_builder.md`
- Documentation mapping all 38 phraser categories to 10 habit categories
- Lists category IDs, names, and quote counts
- Provides implementation recommendations

### 2. Files Modified

#### `/lib/floor_db/phrasers_dao.dart`
- Added `getPhrasersByCategoryId(String categoryId)` - Fetch quotes by category ID
- Added `getPhraserCountByCategoryId(String categoryId)` - Get quote count by category ID

#### `/lib/screens/habit_builder/view_model/habit_builder_view_model.dart`
- Integrated `HabitQuoteService`
- Added `_logQuotesForCategory()` - Logs quotes when category is selected
- Added `_logQuotesForHabit()` - Logs quotes when habit is created
- Added console logging with emoji indicators

---

## How It Works

### Category Mapping

Each habit category maps to multiple phraser categories:

```dart
HabitCategory.healthFitness → ['44', '11', '42', '36']
// Maps to: Running, Gym, Body Positivity, Healthier Life

HabitCategory.mindEmotions → ['50', '45', '43', '40', '37', '12', '41', '35', '51']
// Maps to: Patience, Respect, Kindness, Dream, Motivation, Self Love, Self Respect, Hard Times, Moving On
```

### Quote Fetching Flow

1. **User selects a habit category** (e.g., "Health & Fitness")
2. **System fetches quotes** from all mapped phraser categories
3. **Quotes are merged** into a single list
4. **List is shuffled** using `Random()`
5. **Console logs** show the total count and sample quotes

### Console Output

When a user selects a category:
```
🎯 Selected Category: Health & Fitness
📊 Available Quotes after merge & shuffle: 800
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

When a habit is created:
```
═══════════════════════════════════════════════════════════
✨ HABIT CREATED: Morning Exercise
═══════════════════════════════════════════════════════════

🎯 Habit Category: Health & Fitness
📊 Total Quotes Available (after merge & shuffle): 800

📝 Sample Quotes (first 3):
  1. "Your body can stand almost anything. It's your mind you have to convince."
     - From: Running (ID: 44)
  2. "Take care of your body. It's the only place you have to live."
     - From: Gym (ID: 11)
  3. "Strong body, strong mind."
     - From: Running (ID: 44)

═══════════════════════════════════════════════════════════
```

---

## Usage Examples

### 1. Get Quotes for a Habit

```dart
final HabitQuoteService quoteService = HabitQuoteService();

// Get all quotes for a specific habit
final quotes = await quoteService.getQuotesForHabit(habit);
print('Total quotes: ${quotes.length}');

// Display quotes in UI
for (var quote in quotes) {
  print(quote.quote);
}
```

### 2. Get Random Quote for Daily Motivation

```dart
// Get a single random quote
final randomQuote = await quoteService.getRandomQuoteForHabit(habit);

if (randomQuote != null) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Daily Motivation'),
      content: Text(randomQuote.quote),
    ),
  );
}
```

### 3. Get Multiple Random Quotes

```dart
// Get 5 random quotes for a carousel
final quotes = await quoteService.getRandomQuotesForHabit(habit, 5);

// Display in PageView or Carousel
PageView.builder(
  itemCount: quotes.length,
  itemBuilder: (context, index) {
    return QuoteCard(quote: quotes[index]);
  },
);
```

### 4. Get Quote Count Without Loading All Data

```dart
// Efficient way to get count
final count = await quoteService.getQuoteCountForHabit(habit);
print('This habit has $count motivational quotes available');
```

### 5. Get Statistics for All Categories

```dart
// Get quote counts for all habit categories
final stats = await quoteService.getQuoteStatistics();

stats.forEach((category, count) {
  print('$category: $count quotes');
});

// Or print formatted statistics
await quoteService.printQuoteStatistics();
```

---

## Integration Points

### Habit Setup Screen

When user selects a category in `habit_setup_screen.dart`:

```dart
onTap: () {
  viewModel.selectCategory(category); // This triggers quote fetching
}
```

The `selectCategory` method now:
1. Updates the selected category
2. Fetches quotes for that category
3. Logs the count to console

### Habit Creation

When user creates a habit:

```dart
await viewModel.createHabit(); // This triggers quote logging
```

The `createHabit` method now:
1. Creates the habit object
2. Saves to database
3. Fetches and logs quotes with samples
4. Shows formatted output in console

### Habit Dashboard

To show daily motivation on the dashboard:

```dart
class HabitDashboardScreen extends StatefulWidget {
  // ...
}

class _HabitDashboardScreenState extends State<HabitDashboardScreen> {
  final HabitQuoteService _quoteService = HabitQuoteService();
  Phraser? dailyQuote;

  @override
  void initState() {
    super.initState();
    _loadDailyQuote();
  }

  Future<void> _loadDailyQuote() async {
    final habit = widget.currentHabit;
    if (habit != null) {
      final quote = await _quoteService.getRandomQuoteForHabit(habit);
      setState(() {
        dailyQuote = quote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (dailyQuote != null)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Daily Motivation', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(dailyQuote!.quote, style: TextStyle(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          // ... rest of dashboard
        ],
      ),
    );
  }
}
```

---

## Quote Availability by Habit Category

| Habit Category | Available Quotes | Free | Paid |
|---|---|---|---|
| Health & Fitness | 800 | 594 | 206 |
| Mind & Emotions | 2,435 | 2,236 | 199 |
| Learning & Growth | 1,938 | 1,413 | 525 |
| Productivity & Work | 1,320 | 795 | 525 |
| Finance & Money | 625 | 100 | 525 |
| Lifestyle & Routine | 498 | 399 | 99 |
| Relationships & Social | 5,699 | 4,188 | 1,511 |
| Creativity & Hobbies | 2,792 | 2,272 | 520 |
| Contribution & Impact | 1,585 | 1,585 | 0 |
| Spirituality & Mindfulness | 1,469 | 949 | 520 |

**Total: ~19,161 quotes across all categories**

---

## Database Schema

The Floor database queries added:

```sql
-- Get quotes by category ID
SELECT * FROM phrasers WHERE categoryId = ?

-- Get quote count by category ID
SELECT COUNT(*) FROM phrasers WHERE categoryId = ?
```

---

## Important Notes

### 1. Database Regeneration Required

After modifying `phrasers_dao.dart`, you need to regenerate the Floor database:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will update `/lib/floor_db/database.g.dart` with the new DAO methods.

### 2. Quote Shuffling

Quotes are shuffled using `Random()` to ensure variety. Each time quotes are fetched, they are in a different order:

```dart
allQuotes.shuffle(Random());
```

### 3. Performance Considerations

- Use `getQuoteCountForHabit()` for getting counts without loading all quotes
- Quotes are fetched from database, not API, for fast performance
- Consider caching quotes in memory if showing repeatedly

### 4. Error Handling

All methods include try-catch blocks with console logging:

```dart
try {
  // Fetch quotes
} catch (e) {
  debugPrint('❌ Error fetching quotes: $e');
  return [];
}
```

### 5. Console Logging

Console output uses emojis for easy identification:
- 📋 = Fetching operation
- 📂 = Category information
- 🎯 = Target/mapped data
- ✓ = Success
- ✗ = No data found
- 🎲 = Shuffle operation
- 📊 = Statistics
- ❌ = Error

---

## Testing Checklist

- [ ] Select each habit category and verify console shows correct quote count
- [ ] Create a habit and verify console shows sample quotes
- [ ] Verify quotes are from correct mapped categories (check category IDs)
- [ ] Verify quotes are shuffled (order changes on each fetch)
- [ ] Test with empty database (should handle gracefully)
- [ ] Test quote display in UI components
- [ ] Verify performance with large quote datasets

---

## Future Enhancements

1. **Mood-Based Filtering**: Filter quotes based on user's current mood
2. **Favorite Quotes**: Allow users to favorite and revisit specific quotes
3. **Quote Sharing**: Share motivational quotes to social media
4. **Custom Quote Categories**: Let users add custom phraser categories to habits
5. **Quote Notifications**: Send random quotes as push notifications
6. **Quote Analytics**: Track which quotes are most effective for habit completion
7. **Regional Filtering**: Use the `regionsString` field to show location-based quotes

---

## API Reference

### HabitQuoteService

```dart
class HabitQuoteService {
  // Get category mapping
  Map<HabitCategory, List<String>> getCategoryMapping()

  // Get all quotes for a habit (merged and shuffled)
  Future<List<Phraser>> getQuotesForHabit(Habit habit)

  // Get quotes for a category
  Future<List<Phraser>> getQuotesForCategory(HabitCategory category)

  // Get single random quote
  Future<Phraser?> getRandomQuoteForHabit(Habit habit)

  // Get multiple random quotes
  Future<List<Phraser>> getRandomQuotesForHabit(Habit habit, int count)

  // Get quote count (efficient)
  Future<int> getQuoteCountForHabit(Habit habit)

  // Get statistics for all categories
  Future<Map<HabitCategory, int>> getQuoteStatistics()

  // Print formatted statistics to console
  Future<void> printQuoteStatistics()
}
```

---

## Troubleshooting

### No Quotes Showing

1. Check if database has data: `await phrasersDAO.getAllQuotesFromAllCategories()`
2. Verify category IDs match database: Check `categoryId` field in database
3. Ensure Floor database is regenerated after DAO changes

### Console Not Showing Logs

1. Verify you're in debug mode
2. Check console filter settings
3. Try using `print()` instead of `debugPrint()` temporarily

### Wrong Category Quotes

1. Verify mapping in `getCategoryMapping()` matches `habit_builder.md`
2. Check category IDs in database match API response
3. Ensure `categoryId` is stored as string, not int

---

## Summary

✅ **Completed:**
- Created `HabitQuoteService` with full category mapping
- Updated `PhrasersDAO` with category-based queries
- Integrated quote fetching into `HabitBuilderViewModel`
- Added comprehensive console logging with emoji indicators
- Created documentation files

🔧 **Remaining:**
- Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate Floor database
- Test the implementation by creating habits
- Verify console output shows correct quote counts

📊 **Result:**
When users select a habit category or create a habit, the console will show:
- Category name
- Total quotes available after merge & shuffle
- Sample quotes from different source categories
- Source category information for transparency

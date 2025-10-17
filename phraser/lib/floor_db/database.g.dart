// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CategoriesDAO? _categoriesDAOInstance;

  SectionDAO? _sectionDAOInstance;

  PhrasersDAO? _phraserDAOInstance;

  CurrentPhrasersDAO? _currentPhraserDAOInstance;

  FavoritesDAO? _favoritesDAOInstance;

  MoodsDAO? _moodsDAOInstance;

  MoodTrackingDAO? _moodTrackingDAOInstance;

  HabitsDAO? _habitsDAOInstance;

  HabitProgressDAO? _habitProgressDAOInstance;

  HabitStreakDAO? _habitStreakDAOInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 5,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `categories` (`categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `categoryImage` TEXT NOT NULL, `totalPhraser` TEXT NOT NULL, `isSelected` INTEGER, PRIMARY KEY (`categoryId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `sections` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `phrasers` (`phraserId` TEXT NOT NULL, `tags` TEXT NOT NULL, `quote` TEXT NOT NULL, `categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `lastUpdate` TEXT NOT NULL, `moodsString` TEXT, `regionsString` TEXT, PRIMARY KEY (`phraserId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `currentphrasers` (`phraserId` TEXT NOT NULL, `tags` TEXT NOT NULL, `quote` TEXT NOT NULL, `categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `lastUpdate` TEXT NOT NULL, `moodsString` TEXT, `regionsString` TEXT, PRIMARY KEY (`phraserId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `favorites` (`phraserId` TEXT NOT NULL, `tags` TEXT NOT NULL, `quote` TEXT NOT NULL, `categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `lastUpdate` TEXT NOT NULL, `moodsString` TEXT, `regionsString` TEXT, PRIMARY KEY (`phraserId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `moods` (`moodId` TEXT NOT NULL, `moodTitle` TEXT NOT NULL, `moodIcon` TEXT NOT NULL, `totalPhrasers` TEXT NOT NULL, PRIMARY KEY (`moodId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `mood_entries` (`moodId` TEXT NOT NULL, `mood` TEXT NOT NULL, `intensity` TEXT NOT NULL, `date` TEXT NOT NULL, `timestamp` TEXT NOT NULL, `notes` TEXT, `triggers` TEXT, `activities` TEXT, PRIMARY KEY (`moodId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `habits` (`habitId` TEXT NOT NULL, `name` TEXT NOT NULL, `description` TEXT NOT NULL, `category` TEXT NOT NULL, `frequency` TEXT NOT NULL, `difficulty` TEXT NOT NULL, `targetValue` INTEGER NOT NULL, `unit` TEXT NOT NULL, `isActive` INTEGER NOT NULL, `createdAt` TEXT NOT NULL, `updatedAt` TEXT NOT NULL, `iconPath` TEXT, `colorHex` TEXT, `motivationalQuote` TEXT, `tags` TEXT, PRIMARY KEY (`habitId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `habit_progress` (`progressId` TEXT NOT NULL, `habitId` TEXT NOT NULL, `date` TEXT NOT NULL, `completedValue` INTEGER NOT NULL, `isCompleted` INTEGER NOT NULL, `notes` TEXT NOT NULL, `createdAt` TEXT NOT NULL, `mood` TEXT, `energyLevel` INTEGER, `difficultyRating` INTEGER, PRIMARY KEY (`progressId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `habit_streaks` (`streakId` TEXT NOT NULL, `habitId` TEXT NOT NULL, `currentStreak` INTEGER NOT NULL, `longestStreak` INTEGER NOT NULL, `lastCompletedDate` TEXT NOT NULL, `streakStartDate` TEXT NOT NULL, `updatedAt` TEXT NOT NULL, PRIMARY KEY (`streakId`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CategoriesDAO get categoriesDAO {
    return _categoriesDAOInstance ??= _$CategoriesDAO(database, changeListener);
  }

  @override
  SectionDAO get sectionDAO {
    return _sectionDAOInstance ??= _$SectionDAO(database, changeListener);
  }

  @override
  PhrasersDAO get phraserDAO {
    return _phraserDAOInstance ??= _$PhrasersDAO(database, changeListener);
  }

  @override
  CurrentPhrasersDAO get currentPhraserDAO {
    return _currentPhraserDAOInstance ??=
        _$CurrentPhrasersDAO(database, changeListener);
  }

  @override
  FavoritesDAO get favoritesDAO {
    return _favoritesDAOInstance ??= _$FavoritesDAO(database, changeListener);
  }

  @override
  MoodsDAO get moodsDAO {
    return _moodsDAOInstance ??= _$MoodsDAO(database, changeListener);
  }

  @override
  MoodTrackingDAO get moodTrackingDAO {
    return _moodTrackingDAOInstance ??=
        _$MoodTrackingDAO(database, changeListener);
  }

  @override
  HabitsDAO get habitsDAO {
    return _habitsDAOInstance ??= _$HabitsDAO(database, changeListener);
  }

  @override
  HabitProgressDAO get habitProgressDAO {
    return _habitProgressDAOInstance ??=
        _$HabitProgressDAO(database, changeListener);
  }

  @override
  HabitStreakDAO get habitStreakDAO {
    return _habitStreakDAOInstance ??=
        _$HabitStreakDAO(database, changeListener);
  }
}

class _$CategoriesDAO extends CategoriesDAO {
  _$CategoriesDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _categoriesInsertionAdapter = InsertionAdapter(
            database,
            'categories',
            (Categories item) => <String, Object?>{
                  'categoryId': item.categoryId,
                  'categoryName': item.categoryName,
                  'categorySection': item.categorySection,
                  'categoryType': item.categoryType,
                  'categoryImage': item.categoryImage,
                  'totalPhraser': item.totalPhraser,
                  'isSelected': item.isSelected == null
                      ? null
                      : (item.isSelected! ? 1 : 0)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Categories> _categoriesInsertionAdapter;

  @override
  Future<List<Categories>> getAllCategories() async {
    return _queryAdapter.queryList('SELECT * FROM categories',
        mapper: (Map<String, Object?> row) => Categories(
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            categoryImage: row['categoryImage'] as String,
            totalPhraser: row['totalPhraser'] as String,
            isSelected: row['isSelected'] == null
                ? null
                : (row['isSelected'] as int) != 0));
  }

  @override
  Future<void> deleteAllCategories() async {
    await _queryAdapter.queryNoReturn('DELETE FROM categories');
  }

  @override
  Future<void> insertAllCategories(List<Categories> categories) async {
    await _categoriesInsertionAdapter.insertList(
        categories, OnConflictStrategy.replace);
  }
}

class _$SectionDAO extends SectionDAO {
  _$SectionDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _categorySectionsInsertionAdapter = InsertionAdapter(
            database,
            'sections',
            (CategorySections item) =>
                <String, Object?>{'id': item.id, 'name': item.name});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<CategorySections> _categorySectionsInsertionAdapter;

  @override
  Future<List<CategorySections>> getAllSection() async {
    return _queryAdapter.queryList('SELECT * FROM sections',
        mapper: (Map<String, Object?> row) => CategorySections(
            id: row['id'] as String, name: row['name'] as String));
  }

  @override
  Future<void> insertAllSections(List<CategorySections> sectionList) async {
    await _categorySectionsInsertionAdapter.insertList(
        sectionList, OnConflictStrategy.replace);
  }
}

class _$PhrasersDAO extends PhrasersDAO {
  _$PhrasersDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _phraserInsertionAdapter = InsertionAdapter(
            database,
            'phrasers',
            (Phraser item) => <String, Object?>{
                  'phraserId': item.phraserId,
                  'tags': item.tags,
                  'quote': item.quote,
                  'categoryId': item.categoryId,
                  'categoryName': item.categoryName,
                  'categorySection': item.categorySection,
                  'categoryType': item.categoryType,
                  'lastUpdate': item.lastUpdate,
                  'moodsString': item.moodsString,
                  'regionsString': item.regionsString
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Phraser> _phraserInsertionAdapter;

  @override
  Future<List<Phraser>> getAllPhrasers(String name) async {
    return _queryAdapter.queryList(
        'SELECT * FROM  phrasers WHERE categoryName = ?1',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String,
            moodsString: row['moodsString'] as String?,
            regionsString: row['regionsString'] as String?),
        arguments: [name]);
  }

  @override
  Future<List<Phraser>> getAllQuotesFromAllCategories() async {
    return _queryAdapter.queryList('SELECT * FROM  phrasers',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String,
            moodsString: row['moodsString'] as String?,
            regionsString: row['regionsString'] as String?));
  }

  @override
  Future<List<Phraser>> getPhrasersByCategoryId(String categoryId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM  phrasers WHERE categoryId = ?1',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String,
            moodsString: row['moodsString'] as String?,
            regionsString: row['regionsString'] as String?),
        arguments: [categoryId]);
  }

  @override
  Future<int?> getPhraserCountByCategoryId(String categoryId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM  phrasers WHERE categoryId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [categoryId]);
  }

  @override
  Future<void> insertAllPhrasers(List<Phraser> phrasersList) async {
    await _phraserInsertionAdapter.insertList(
        phrasersList, OnConflictStrategy.replace);
  }
}

class _$CurrentPhrasersDAO extends CurrentPhrasersDAO {
  _$CurrentPhrasersDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _phraserInsertionAdapter = InsertionAdapter(
            database,
            'currentphrasers',
            (Phraser item) => <String, Object?>{
                  'phraserId': item.phraserId,
                  'tags': item.tags,
                  'quote': item.quote,
                  'categoryId': item.categoryId,
                  'categoryName': item.categoryName,
                  'categorySection': item.categorySection,
                  'categoryType': item.categoryType,
                  'lastUpdate': item.lastUpdate,
                  'moodsString': item.moodsString,
                  'regionsString': item.regionsString
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Phraser> _phraserInsertionAdapter;

  @override
  Future<List<Phraser>> getAllCurrentPhrasers() async {
    return _queryAdapter.queryList(
        'SELECT * FROM  currentphrasers ORDER BY ROWID',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String,
            moodsString: row['moodsString'] as String?,
            regionsString: row['regionsString'] as String?));
  }

  @override
  Future<void> deleteCurrentPhrasers() async {
    await _queryAdapter.queryNoReturn('DELETE FROM currentphrasers');
  }

  @override
  Future<void> insertAllCurrentPhrasers(List<Phraser> phrasersList) async {
    await _phraserInsertionAdapter.insertList(
        phrasersList, OnConflictStrategy.replace);
  }
}

class _$FavoritesDAO extends FavoritesDAO {
  _$FavoritesDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _phraserInsertionAdapter = InsertionAdapter(
            database,
            'favorites',
            (Phraser item) => <String, Object?>{
                  'phraserId': item.phraserId,
                  'tags': item.tags,
                  'quote': item.quote,
                  'categoryId': item.categoryId,
                  'categoryName': item.categoryName,
                  'categorySection': item.categorySection,
                  'categoryType': item.categoryType,
                  'lastUpdate': item.lastUpdate,
                  'moodsString': item.moodsString,
                  'regionsString': item.regionsString
                },
            changeListener),
        _phraserDeletionAdapter = DeletionAdapter(
            database,
            'favorites',
            ['phraserId'],
            (Phraser item) => <String, Object?>{
                  'phraserId': item.phraserId,
                  'tags': item.tags,
                  'quote': item.quote,
                  'categoryId': item.categoryId,
                  'categoryName': item.categoryName,
                  'categorySection': item.categorySection,
                  'categoryType': item.categoryType,
                  'lastUpdate': item.lastUpdate,
                  'moodsString': item.moodsString,
                  'regionsString': item.regionsString
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Phraser> _phraserInsertionAdapter;

  final DeletionAdapter<Phraser> _phraserDeletionAdapter;

  @override
  Future<List<Phraser>> getAllFavoritesPhrasers() async {
    return _queryAdapter.queryList('SELECT * FROM favorites',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String,
            moodsString: row['moodsString'] as String?,
            regionsString: row['regionsString'] as String?));
  }

  @override
  Stream<Phraser?> getFavoriteById(String id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM favorites WHERE phraserId = ?1',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String,
            moodsString: row['moodsString'] as String?,
            regionsString: row['regionsString'] as String?),
        arguments: [id],
        queryableName: 'favorites',
        isView: false);
  }

  @override
  Future<void> addPhraserToFavorite(Phraser phraser) async {
    await _phraserInsertionAdapter.insert(phraser, OnConflictStrategy.abort);
  }

  @override
  Future<void> removeFromFavorites(Phraser phraser) async {
    await _phraserDeletionAdapter.delete(phraser);
  }
}

class _$MoodsDAO extends MoodsDAO {
  _$MoodsDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _moodEntityInsertionAdapter = InsertionAdapter(
            database,
            'moods',
            (MoodEntity item) => <String, Object?>{
                  'moodId': item.moodId,
                  'moodTitle': item.moodTitle,
                  'moodIcon': item.moodIcon,
                  'totalPhrasers': item.totalPhrasers
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MoodEntity> _moodEntityInsertionAdapter;

  @override
  Future<List<MoodEntity>> getAllMoods() async {
    return _queryAdapter.queryList('SELECT * FROM moods',
        mapper: (Map<String, Object?> row) => MoodEntity(
            moodId: row['moodId'] as String,
            moodTitle: row['moodTitle'] as String,
            moodIcon: row['moodIcon'] as String,
            totalPhrasers: row['totalPhrasers'] as String));
  }

  @override
  Future<void> deleteAllMoods() async {
    await _queryAdapter.queryNoReturn('DELETE FROM moods');
  }

  @override
  Future<int?> getMoodsCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM moods',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> insertAllMoods(List<MoodEntity> moods) async {
    await _moodEntityInsertionAdapter.insertList(
        moods, OnConflictStrategy.replace);
  }
}

class _$MoodTrackingDAO extends MoodTrackingDAO {
  _$MoodTrackingDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _moodEntryInsertionAdapter = InsertionAdapter(
            database,
            'mood_entries',
            (MoodEntry item) => <String, Object?>{
                  'moodId': item.moodId,
                  'mood': item.mood,
                  'intensity': item.intensity,
                  'date': item.date,
                  'timestamp': item.timestamp,
                  'notes': item.notes,
                  'triggers': item.triggers,
                  'activities': item.activities
                }),
        _moodEntryUpdateAdapter = UpdateAdapter(
            database,
            'mood_entries',
            ['moodId'],
            (MoodEntry item) => <String, Object?>{
                  'moodId': item.moodId,
                  'mood': item.mood,
                  'intensity': item.intensity,
                  'date': item.date,
                  'timestamp': item.timestamp,
                  'notes': item.notes,
                  'triggers': item.triggers,
                  'activities': item.activities
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MoodEntry> _moodEntryInsertionAdapter;

  final UpdateAdapter<MoodEntry> _moodEntryUpdateAdapter;

  @override
  Future<List<MoodEntry>> getAllMoodEntries() async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?));
  }

  @override
  Future<MoodEntry?> getMoodEntryById(String moodId) async {
    return _queryAdapter.query('SELECT * FROM mood_entries WHERE moodId = ?1',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?),
        arguments: [moodId]);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByDate(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE date = ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?),
        arguments: [date]);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesInDateRange(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE date BETWEEN ?1 AND ?2 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(moodId: row['moodId'] as String, mood: row['mood'] as String, intensity: row['intensity'] as String, date: row['date'] as String, timestamp: row['timestamp'] as String, notes: row['notes'] as String?, triggers: row['triggers'] as String?, activities: row['activities'] as String?),
        arguments: [startDate, endDate]);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesSinceDate(String startDate) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE date >= ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?),
        arguments: [startDate]);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByType(String mood) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE mood = ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?),
        arguments: [mood]);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByTypeInRange(
    String mood,
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE mood = ?1 AND date BETWEEN ?2 AND ?3 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(moodId: row['moodId'] as String, mood: row['mood'] as String, intensity: row['intensity'] as String, date: row['date'] as String, timestamp: row['timestamp'] as String, notes: row['notes'] as String?, triggers: row['triggers'] as String?, activities: row['activities'] as String?),
        arguments: [mood, startDate, endDate]);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesByIntensity(String intensity) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE intensity = ?1 ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(moodId: row['moodId'] as String, mood: row['mood'] as String, intensity: row['intensity'] as String, date: row['date'] as String, timestamp: row['timestamp'] as String, notes: row['notes'] as String?, triggers: row['triggers'] as String?, activities: row['activities'] as String?),
        arguments: [intensity]);
  }

  @override
  Future<int?> getTotalMoodEntriesCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM mood_entries',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> getMoodEntriesCountInRange(
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM mood_entries WHERE date BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [startDate, endDate]);
  }

  @override
  Future<int?> getMoodTypeCount(String mood) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM mood_entries WHERE mood = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [mood]);
  }

  @override
  Future<int?> getMoodTypeCountInRange(
    String mood,
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM mood_entries WHERE mood = ?1 AND date BETWEEN ?2 AND ?3',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [mood, startDate, endDate]);
  }

  @override
  Future<int?> getMoodEntriesCountForDate(String date) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM mood_entries WHERE date = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [date]);
  }

  @override
  Future<MoodEntry?> getLatestMoodEntry() async {
    return _queryAdapter.query(
        'SELECT * FROM mood_entries ORDER BY timestamp DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?));
  }

  @override
  Future<MoodEntry?> getLatestMoodEntryForDate(String date) async {
    return _queryAdapter.query(
        'SELECT * FROM mood_entries WHERE date = ?1 ORDER BY timestamp DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => MoodEntry(moodId: row['moodId'] as String, mood: row['mood'] as String, intensity: row['intensity'] as String, date: row['date'] as String, timestamp: row['timestamp'] as String, notes: row['notes'] as String?, triggers: row['triggers'] as String?, activities: row['activities'] as String?),
        arguments: [date]);
  }

  @override
  Future<List<String>> getDistinctMoodTypes() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT mood FROM mood_entries ORDER BY mood',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<List<String>> getDistinctDates() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT date FROM mood_entries ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesWithNotes() async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE notes IS NOT NULL AND notes != \"\" ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?));
  }

  @override
  Future<List<MoodEntry>> getMoodEntriesWithTriggers() async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries WHERE triggers IS NOT NULL AND triggers != \"\" ORDER BY timestamp DESC',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?));
  }

  @override
  Future<void> deleteMoodEntry(String moodId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM mood_entries WHERE moodId = ?1',
        arguments: [moodId]);
  }

  @override
  Future<void> deleteMoodEntriesBeforeDate(String date) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM mood_entries WHERE date < ?1',
        arguments: [date]);
  }

  @override
  Future<void> deleteAllMoodEntries() async {
    await _queryAdapter.queryNoReturn('DELETE FROM mood_entries');
  }

  @override
  Future<List<MoodEntry>> getRecentMoodEntries(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM mood_entries ORDER BY timestamp DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => MoodEntry(
            moodId: row['moodId'] as String,
            mood: row['mood'] as String,
            intensity: row['intensity'] as String,
            date: row['date'] as String,
            timestamp: row['timestamp'] as String,
            notes: row['notes'] as String?,
            triggers: row['triggers'] as String?,
            activities: row['activities'] as String?),
        arguments: [limit]);
  }

  @override
  Future<List<String>> getAllDatesWithEntries() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT date FROM mood_entries ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => row.values.first as String);
  }

  @override
  Future<void> insertMoodEntry(MoodEntry entry) async {
    await _moodEntryInsertionAdapter.insert(entry, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertMoodEntries(List<MoodEntry> entries) async {
    await _moodEntryInsertionAdapter.insertList(
        entries, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMoodEntry(MoodEntry entry) async {
    await _moodEntryUpdateAdapter.update(entry, OnConflictStrategy.abort);
  }
}

class _$HabitsDAO extends HabitsDAO {
  _$HabitsDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _habitInsertionAdapter = InsertionAdapter(
            database,
            'habits',
            (Habit item) => <String, Object?>{
                  'habitId': item.habitId,
                  'name': item.name,
                  'description': item.description,
                  'category': item.category,
                  'frequency': item.frequency,
                  'difficulty': item.difficulty,
                  'targetValue': item.targetValue,
                  'unit': item.unit,
                  'isActive': item.isActive ? 1 : 0,
                  'createdAt': item.createdAt,
                  'updatedAt': item.updatedAt,
                  'iconPath': item.iconPath,
                  'colorHex': item.colorHex,
                  'motivationalQuote': item.motivationalQuote,
                  'tags': item.tags
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Habit> _habitInsertionAdapter;

  @override
  Future<Habit?> getHabitById(String habitId) async {
    return _queryAdapter.query('SELECT * FROM habits WHERE habitId = ?1',
        mapper: (Map<String, Object?> row) => Habit(
            habitId: row['habitId'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            category: row['category'] as String,
            frequency: row['frequency'] as String,
            difficulty: row['difficulty'] as String,
            targetValue: row['targetValue'] as int,
            unit: row['unit'] as String,
            isActive: (row['isActive'] as int) != 0,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String,
            iconPath: row['iconPath'] as String?,
            colorHex: row['colorHex'] as String?,
            motivationalQuote: row['motivationalQuote'] as String?,
            tags: row['tags'] as String?),
        arguments: [habitId]);
  }

  @override
  Future<List<Habit>> getAllActiveHabits() async {
    return _queryAdapter.queryList(
        'SELECT * FROM habits WHERE isActive = 1 ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Habit(
            habitId: row['habitId'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            category: row['category'] as String,
            frequency: row['frequency'] as String,
            difficulty: row['difficulty'] as String,
            targetValue: row['targetValue'] as int,
            unit: row['unit'] as String,
            isActive: (row['isActive'] as int) != 0,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String,
            iconPath: row['iconPath'] as String?,
            colorHex: row['colorHex'] as String?,
            motivationalQuote: row['motivationalQuote'] as String?,
            tags: row['tags'] as String?));
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    return _queryAdapter.queryList(
        'SELECT * FROM habits ORDER BY createdAt DESC',
        mapper: (Map<String, Object?> row) => Habit(
            habitId: row['habitId'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            category: row['category'] as String,
            frequency: row['frequency'] as String,
            difficulty: row['difficulty'] as String,
            targetValue: row['targetValue'] as int,
            unit: row['unit'] as String,
            isActive: (row['isActive'] as int) != 0,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String,
            iconPath: row['iconPath'] as String?,
            colorHex: row['colorHex'] as String?,
            motivationalQuote: row['motivationalQuote'] as String?,
            tags: row['tags'] as String?));
  }

  @override
  Future<List<Habit>> getHabitsByCategory(String category) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habits WHERE category = ?1 AND isActive = 1',
        mapper: (Map<String, Object?> row) => Habit(
            habitId: row['habitId'] as String,
            name: row['name'] as String,
            description: row['description'] as String,
            category: row['category'] as String,
            frequency: row['frequency'] as String,
            difficulty: row['difficulty'] as String,
            targetValue: row['targetValue'] as int,
            unit: row['unit'] as String,
            isActive: (row['isActive'] as int) != 0,
            createdAt: row['createdAt'] as String,
            updatedAt: row['updatedAt'] as String,
            iconPath: row['iconPath'] as String?,
            colorHex: row['colorHex'] as String?,
            motivationalQuote: row['motivationalQuote'] as String?,
            tags: row['tags'] as String?),
        arguments: [category]);
  }

  @override
  Future<int?> getActiveHabitsCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM habits WHERE isActive = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<void> updateHabitActiveStatus(
    String habitId,
    bool isActive,
    String updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE habits SET isActive = ?2, updatedAt = ?3 WHERE habitId = ?1',
        arguments: [habitId, isActive ? 1 : 0, updatedAt]);
  }

  @override
  Future<void> updateHabitTarget(
    String habitId,
    int targetValue,
    String updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE habits SET targetValue = ?2, updatedAt = ?3 WHERE habitId = ?1',
        arguments: [habitId, targetValue, updatedAt]);
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await _queryAdapter.queryNoReturn('DELETE FROM habits WHERE habitId = ?1',
        arguments: [habitId]);
  }

  @override
  Future<void> deleteAllHabits() async {
    await _queryAdapter.queryNoReturn('DELETE FROM habits');
  }

  @override
  Future<void> deactivateAllHabits(String updatedAt) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE habits SET isActive = 0, updatedAt = ?1',
        arguments: [updatedAt]);
  }

  @override
  Future<void> insertHabit(Habit habit) async {
    await _habitInsertionAdapter.insert(habit, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertAllHabits(List<Habit> habits) async {
    await _habitInsertionAdapter.insertList(habits, OnConflictStrategy.replace);
  }
}

class _$HabitProgressDAO extends HabitProgressDAO {
  _$HabitProgressDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _habitProgressInsertionAdapter = InsertionAdapter(
            database,
            'habit_progress',
            (HabitProgress item) => <String, Object?>{
                  'progressId': item.progressId,
                  'habitId': item.habitId,
                  'date': item.date,
                  'completedValue': item.completedValue,
                  'isCompleted': item.isCompleted ? 1 : 0,
                  'notes': item.notes,
                  'createdAt': item.createdAt,
                  'mood': item.mood,
                  'energyLevel': item.energyLevel,
                  'difficultyRating': item.difficultyRating
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<HabitProgress> _habitProgressInsertionAdapter;

  @override
  Future<HabitProgress?> getProgressById(String progressId) async {
    return _queryAdapter.query(
        'SELECT * FROM habit_progress WHERE progressId = ?1',
        mapper: (Map<String, Object?> row) => HabitProgress(
            progressId: row['progressId'] as String,
            habitId: row['habitId'] as String,
            date: row['date'] as String,
            completedValue: row['completedValue'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            notes: row['notes'] as String,
            createdAt: row['createdAt'] as String,
            mood: row['mood'] as String?,
            energyLevel: row['energyLevel'] as int?,
            difficultyRating: row['difficultyRating'] as int?),
        arguments: [progressId]);
  }

  @override
  Future<List<HabitProgress>> getProgressByHabitId(String habitId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habit_progress WHERE habitId = ?1 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => HabitProgress(
            progressId: row['progressId'] as String,
            habitId: row['habitId'] as String,
            date: row['date'] as String,
            completedValue: row['completedValue'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            notes: row['notes'] as String,
            createdAt: row['createdAt'] as String,
            mood: row['mood'] as String?,
            energyLevel: row['energyLevel'] as int?,
            difficultyRating: row['difficultyRating'] as int?),
        arguments: [habitId]);
  }

  @override
  Future<HabitProgress?> getProgressByHabitAndDate(
    String habitId,
    String date,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM habit_progress WHERE habitId = ?1 AND date = ?2',
        mapper: (Map<String, Object?> row) => HabitProgress(
            progressId: row['progressId'] as String,
            habitId: row['habitId'] as String,
            date: row['date'] as String,
            completedValue: row['completedValue'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            notes: row['notes'] as String,
            createdAt: row['createdAt'] as String,
            mood: row['mood'] as String?,
            energyLevel: row['energyLevel'] as int?,
            difficultyRating: row['difficultyRating'] as int?),
        arguments: [habitId, date]);
  }

  @override
  Future<List<HabitProgress>> getProgressByDateRange(
    String habitId,
    String startDate,
    String endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habit_progress WHERE habitId = ?1 AND date >= ?2 AND date <= ?3 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => HabitProgress(progressId: row['progressId'] as String, habitId: row['habitId'] as String, date: row['date'] as String, completedValue: row['completedValue'] as int, isCompleted: (row['isCompleted'] as int) != 0, notes: row['notes'] as String, createdAt: row['createdAt'] as String, mood: row['mood'] as String?, energyLevel: row['energyLevel'] as int?, difficultyRating: row['difficultyRating'] as int?),
        arguments: [habitId, startDate, endDate]);
  }

  @override
  Future<List<HabitProgress>> getCompletedProgressByHabitId(
      String habitId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habit_progress WHERE habitId = ?1 AND isCompleted = 1 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => HabitProgress(progressId: row['progressId'] as String, habitId: row['habitId'] as String, date: row['date'] as String, completedValue: row['completedValue'] as int, isCompleted: (row['isCompleted'] as int) != 0, notes: row['notes'] as String, createdAt: row['createdAt'] as String, mood: row['mood'] as String?, energyLevel: row['energyLevel'] as int?, difficultyRating: row['difficultyRating'] as int?),
        arguments: [habitId]);
  }

  @override
  Future<List<HabitProgress>> getProgressByDate(String date) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habit_progress WHERE date = ?1',
        mapper: (Map<String, Object?> row) => HabitProgress(
            progressId: row['progressId'] as String,
            habitId: row['habitId'] as String,
            date: row['date'] as String,
            completedValue: row['completedValue'] as int,
            isCompleted: (row['isCompleted'] as int) != 0,
            notes: row['notes'] as String,
            createdAt: row['createdAt'] as String,
            mood: row['mood'] as String?,
            energyLevel: row['energyLevel'] as int?,
            difficultyRating: row['difficultyRating'] as int?),
        arguments: [date]);
  }

  @override
  Future<int?> getTotalCompletions(String habitId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM habit_progress WHERE habitId = ?1 AND isCompleted = 1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [habitId]);
  }

  @override
  Future<int?> getCompletionsAfterDate(
    String habitId,
    String startDate,
  ) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM habit_progress WHERE habitId = ?1 AND isCompleted = 1 AND date >= ?2',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [habitId, startDate]);
  }

  @override
  Future<List<HabitProgress>> getRecentProgress(
    String habitId,
    String startDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habit_progress WHERE habitId = ?1 AND date >= ?2 ORDER BY date DESC',
        mapper: (Map<String, Object?> row) => HabitProgress(progressId: row['progressId'] as String, habitId: row['habitId'] as String, date: row['date'] as String, completedValue: row['completedValue'] as int, isCompleted: (row['isCompleted'] as int) != 0, notes: row['notes'] as String, createdAt: row['createdAt'] as String, mood: row['mood'] as String?, energyLevel: row['energyLevel'] as int?, difficultyRating: row['difficultyRating'] as int?),
        arguments: [habitId, startDate]);
  }

  @override
  Future<void> updateProgress(
    String progressId,
    int completedValue,
    bool isCompleted,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE habit_progress SET completedValue = ?2, isCompleted = ?3 WHERE progressId = ?1',
        arguments: [progressId, completedValue, isCompleted ? 1 : 0]);
  }

  @override
  Future<void> deleteProgress(String progressId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM habit_progress WHERE progressId = ?1',
        arguments: [progressId]);
  }

  @override
  Future<void> deleteProgressByHabitId(String habitId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM habit_progress WHERE habitId = ?1',
        arguments: [habitId]);
  }

  @override
  Future<void> deleteAllProgress() async {
    await _queryAdapter.queryNoReturn('DELETE FROM habit_progress');
  }

  @override
  Future<void> insertProgress(HabitProgress progress) async {
    await _habitProgressInsertionAdapter.insert(
        progress, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertAllProgress(List<HabitProgress> progressList) async {
    await _habitProgressInsertionAdapter.insertList(
        progressList, OnConflictStrategy.replace);
  }
}

class _$HabitStreakDAO extends HabitStreakDAO {
  _$HabitStreakDAO(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _habitStreakInsertionAdapter = InsertionAdapter(
            database,
            'habit_streaks',
            (HabitStreak item) => <String, Object?>{
                  'streakId': item.streakId,
                  'habitId': item.habitId,
                  'currentStreak': item.currentStreak,
                  'longestStreak': item.longestStreak,
                  'lastCompletedDate': item.lastCompletedDate,
                  'streakStartDate': item.streakStartDate,
                  'updatedAt': item.updatedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<HabitStreak> _habitStreakInsertionAdapter;

  @override
  Future<HabitStreak?> getStreakById(String streakId) async {
    return _queryAdapter.query(
        'SELECT * FROM habit_streaks WHERE streakId = ?1',
        mapper: (Map<String, Object?> row) => HabitStreak(
            streakId: row['streakId'] as String,
            habitId: row['habitId'] as String,
            currentStreak: row['currentStreak'] as int,
            longestStreak: row['longestStreak'] as int,
            lastCompletedDate: row['lastCompletedDate'] as String,
            streakStartDate: row['streakStartDate'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [streakId]);
  }

  @override
  Future<HabitStreak?> getStreakByHabitId(String habitId) async {
    return _queryAdapter.query('SELECT * FROM habit_streaks WHERE habitId = ?1',
        mapper: (Map<String, Object?> row) => HabitStreak(
            streakId: row['streakId'] as String,
            habitId: row['habitId'] as String,
            currentStreak: row['currentStreak'] as int,
            longestStreak: row['longestStreak'] as int,
            lastCompletedDate: row['lastCompletedDate'] as String,
            streakStartDate: row['streakStartDate'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [habitId]);
  }

  @override
  Future<List<HabitStreak>> getTopStreaks(int limit) async {
    return _queryAdapter.queryList(
        'SELECT * FROM habit_streaks ORDER BY currentStreak DESC LIMIT ?1',
        mapper: (Map<String, Object?> row) => HabitStreak(
            streakId: row['streakId'] as String,
            habitId: row['habitId'] as String,
            currentStreak: row['currentStreak'] as int,
            longestStreak: row['longestStreak'] as int,
            lastCompletedDate: row['lastCompletedDate'] as String,
            streakStartDate: row['streakStartDate'] as String,
            updatedAt: row['updatedAt'] as String),
        arguments: [limit]);
  }

  @override
  Future<void> updateStreak(
    String habitId,
    int currentStreak,
    int longestStreak,
    String lastCompletedDate,
    String updatedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE habit_streaks SET currentStreak = ?2, longestStreak = ?3, lastCompletedDate = ?4, updatedAt = ?5 WHERE habitId = ?1',
        arguments: [
          habitId,
          currentStreak,
          longestStreak,
          lastCompletedDate,
          updatedAt
        ]);
  }

  @override
  Future<void> deleteStreakByHabitId(String habitId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM habit_streaks WHERE habitId = ?1',
        arguments: [habitId]);
  }

  @override
  Future<void> deleteAllStreaks() async {
    await _queryAdapter.queryNoReturn('DELETE FROM habit_streaks');
  }

  @override
  Future<void> insertStreak(HabitStreak streak) async {
    await _habitStreakInsertionAdapter.insert(
        streak, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertAllStreaks(List<HabitStreak> streaks) async {
    await _habitStreakInsertionAdapter.insertList(
        streaks, OnConflictStrategy.replace);
  }
}

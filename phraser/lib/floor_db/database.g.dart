// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
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

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `categories` (`categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `categoryImage` TEXT NOT NULL, `totalPhraser` TEXT NOT NULL, PRIMARY KEY (`categoryId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `sections` (`id` TEXT NOT NULL, `name` TEXT NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `phrasers` (`phraserId` TEXT NOT NULL, `tags` TEXT NOT NULL, `quote` TEXT NOT NULL, `categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `lastUpdate` TEXT NOT NULL, PRIMARY KEY (`phraserId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `currentphrasers` (`phraserId` TEXT NOT NULL, `tags` TEXT NOT NULL, `quote` TEXT NOT NULL, `categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `lastUpdate` TEXT NOT NULL, PRIMARY KEY (`phraserId`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `favorites` (`phraserId` TEXT NOT NULL, `tags` TEXT NOT NULL, `quote` TEXT NOT NULL, `categoryId` TEXT NOT NULL, `categoryName` TEXT NOT NULL, `categorySection` TEXT NOT NULL, `categoryType` TEXT NOT NULL, `lastUpdate` TEXT NOT NULL, PRIMARY KEY (`phraserId`))');

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
                  'totalPhraser': item.totalPhraser
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
            totalPhraser: row['totalPhraser'] as String));
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
                  'lastUpdate': item.lastUpdate
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
            lastUpdate: row['lastUpdate'] as String),
        arguments: [name]);
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
                  'lastUpdate': item.lastUpdate
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Phraser> _phraserInsertionAdapter;

  @override
  Future<List<Phraser>> getAllCurrentPhrasers() async {
    return _queryAdapter.queryList('SELECT * FROM  currentphrasers',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String));
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
                  'lastUpdate': item.lastUpdate
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
                  'lastUpdate': item.lastUpdate
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
            lastUpdate: row['lastUpdate'] as String));
  }

  @override
  Stream<Phraser?> getFavoriteById(int id) {
    return _queryAdapter.queryStream('SELECT * FROM favorites WHERE phraserId = ?1',
        mapper: (Map<String, Object?> row) => Phraser(
            phraserId: row['phraserId'] as String,
            tags: row['tags'] as String,
            quote: row['quote'] as String,
            categoryId: row['categoryId'] as String,
            categoryName: row['categoryName'] as String,
            categorySection: row['categorySection'] as String,
            categoryType: row['categoryType'] as String,
            lastUpdate: row['lastUpdate'] as String),
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

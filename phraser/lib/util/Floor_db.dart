import 'package:floor/floor.dart';
import '../floor_db/database.dart';
import 'constant_strings.dart';

class FloorDB {

  FloorDB._();

  static final FloorDB _instance = FloorDB._();
  static FloorDB get instance => _instance;

  AppDatabase get floorDatabase => _floorDatabase!;

  late AppDatabase? _floorDatabase;


  Future<void> init() async {
   _floorDatabase = await $FloorAppDatabase
       .databaseBuilder(ConstantStrings.kFloorDatabaseName)
       .addCallback(Callback(
         onCreate: (database, version) async {
           // Create currentphrasers table on database creation
           await database.execute('''
             CREATE TABLE IF NOT EXISTS currentphrasers (
               phraserId TEXT PRIMARY KEY NOT NULL,
               tags TEXT NOT NULL,
               quote TEXT NOT NULL,
               categoryId TEXT NOT NULL,
               categoryName TEXT NOT NULL
             )
           ''');

           // Create mood_entries table on database creation
           await database.execute('''
             CREATE TABLE IF NOT EXISTS mood_entries (
               moodId TEXT PRIMARY KEY NOT NULL,
               mood TEXT NOT NULL,
               intensity TEXT NOT NULL,
               date TEXT NOT NULL,
               timestamp TEXT NOT NULL,
               notes TEXT,
               triggers TEXT,
               activities TEXT
             )
           ''');
         },
       ))
       .build();

  }

}
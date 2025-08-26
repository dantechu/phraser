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
       .build();

  }

}
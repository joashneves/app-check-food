
import 'package:checkfood/model/comida.dart';
import 'package:checkfood/model/ingrediente.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'checkfood.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE comida(
        id TEXT PRIMARY KEY,
        o_que_e_a_comida TEXT,
        tipo_da_comida TEXT,
        dia_para_fazer TEXT,
        ingredientes_faltando INTEGER,
        tem_todos_ingredientes INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE ingrediente(
        id TEXT PRIMARY KEY,
        marcado INTEGER,
        nome TEXT,
        data_de_aquisicao TEXT,
        comida_id TEXT,
        FOREIGN KEY (comida_id) REFERENCES comida (id)
      )
    ''');
  }

  // Comida CRUD
  Future<void> insertComida(Comida comida) async {
    final db = await database;
    await db.insert('comida', comida.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Comida>> getComidas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('comida');
    return List.generate(maps.length, (i) {
      return Comida.fromMap(maps[i]);
    });
  }

  Future<void> updateComida(Comida comida) async {
    final db = await database;
    await db.update(
      'comida',
      comida.toMap(),
      where: 'id = ?',
      whereArgs: [comida.id],
    );
  }

  Future<void> deleteComida(String id) async {
    final db = await database;
    await db.delete(
      'comida',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Ingrediente CRUD
  Future<void> insertIngrediente(Ingrediente ingrediente, String comidaId) async {
    final db = await database;
    var map = ingrediente.toMap();
    map['comida_id'] = comidaId;
    await db.insert('ingrediente', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Ingrediente>> getIngredientes(String comidaId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'ingrediente',
      where: 'comida_id = ?',
      whereArgs: [comidaId],
    );
    return List.generate(maps.length, (i) {
      return Ingrediente.fromMap(maps[i]);
    });
  }

  Future<void> updateIngrediente(Ingrediente ingrediente) async {
    final db = await database;
    await db.update(
      'ingrediente',
      ingrediente.toMap(),
      where: 'id = ?',
      whereArgs: [ingrediente.id],
    );
  }

  Future<void> deleteIngrediente(String id) async {
    final db = await database;
    await db.delete(
      'ingrediente',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

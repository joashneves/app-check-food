import 'package:checkfood/model/comida.dart';
import 'package:checkfood/model/ingrediente.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Classe para gerenciar o banco de dados SQLite.
class DatabaseHelper {
  // Instância única da classe (Singleton).
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter para o banco de dados. Se o banco de dados não foi inicializado, ele o inicializa.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializa o banco de dados.
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'checkfood.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Chamado quando o banco de dados é atualizado.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE ingrediente ADD COLUMN data_de_criacao TEXT');
      await db.rawUpdate("UPDATE ingrediente SET data_de_criacao = ? WHERE data_de_criacao IS NULL", [DateTime.now().toIso8601String()]);
    }
  }

  // Chamado quando o banco de dados é criado pela primeira vez.
  Future<void> _onCreate(Database db, int version) async {
    // Cria a tabela 'comida'.
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

    // Cria a tabela 'ingrediente'.
    await db.execute('''
      CREATE TABLE ingrediente(
        id TEXT PRIMARY KEY,
        marcado INTEGER,
        nome TEXT,
        data_de_criacao TEXT,
        data_de_aquisicao TEXT,
        comida_id TEXT
      )
    ''');
  }

  // Métodos CRUD para a tabela 'comida'.

  // Insere uma nova comida no banco de dados.
  Future<void> insertComida(Comida comida) async {
    final db = await database;
    await db.insert('comida', comida.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Obtém a lista de todas as comidas do banco de dados.
  Future<List<Comida>> getComidas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('comida');
    return List.generate(maps.length, (i) {
      return Comida.fromMap(maps[i]);
    });
  }

  // Atualiza uma comida existente no banco de dados.
  Future<void> updateComida(Comida comida) async {
    final db = await database;
    await db.update(
      'comida',
      comida.toMap(),
      where: 'id = ?',
      whereArgs: [comida.id],
    );
  }

  // Exclui uma comida do banco de dados.
  Future<void> deleteComida(String id) async {
    final db = await database;
    await db.delete(
      'comida',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos CRUD para a tabela 'ingrediente'.

  // Insere um novo ingrediente no banco de dados.
  Future<void> insertIngrediente(Ingrediente ingrediente) async {
    final db = await database;
    await db.insert('ingrediente', ingrediente.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Obtém a lista de ingredientes de uma comida específica.
  Future<List<Ingrediente>> getIngredientesPorComida(String comidaId) async {
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

  // Obtém a lista de todos os ingredientes.
  Future<List<Ingrediente>> getIngredientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('ingrediente');
    return List.generate(maps.length, (i) {
      return Ingrediente.fromMap(maps[i]);
    });
  }

  // Atualiza um ingrediente existente no banco de dados.
  Future<void> updateIngrediente(Ingrediente ingrediente) async {
    final db = await database;
    await db.update(
      'ingrediente',
      ingrediente.toMap(),
      where: 'id = ?',
      whereArgs: [ingrediente.id],
    );
  }

  // Exclui um ingrediente do banco de dados.
  Future<void> deleteIngrediente(String id) async {
    final db = await database;
    await db.delete(
      'ingrediente',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
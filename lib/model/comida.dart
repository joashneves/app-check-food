
import 'ingrediente.dart';

class Comida {
  String id;
  String o_que_e_a_comida;
  String tipo_da_comida;
  DateTime dia_para_fazer;
  int ingredientes_faltando;
  bool tem_todos_ingredientes;
  List<Ingrediente> ingredientes;

  Comida({
    required this.id,
    required this.o_que_e_a_comida,
    required this.tipo_da_comida,
    required this.dia_para_fazer,
    required this.ingredientes_faltando,
    required this.tem_todos_ingredientes,
    required this.ingredientes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'o_que_e_a_comida': o_que_e_a_comida,
      'tipo_da_comida': tipo_da_comida,
      'dia_para_fazer': dia_para_fazer.toIso8601String(),
      'ingredientes_faltando': ingredientes_faltando,
      'tem_todos_ingredientes': tem_todos_ingredientes ? 1 : 0,
    };
  }

  factory Comida.fromMap(Map<String, dynamic> map) {
    return Comida(
      id: map['id'],
      o_que_e_a_comida: map['o_que_e_a_comida'],
      tipo_da_comida: map['tipo_da_comida'],
      dia_para_fazer: DateTime.parse(map['dia_para_fazer']),
      ingredientes_faltando: map['ingredientes_faltando'],
      tem_todos_ingredientes: map['tem_todos_ingredientes'] == 1,
      ingredientes: [],
    );
  }
}

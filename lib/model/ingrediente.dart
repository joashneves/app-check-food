class Ingrediente {
  String id;
  bool marcado;
  String nome;
  DateTime data_de_aquisicao;

  Ingrediente({
    required this.id,
    required this.marcado,
    required this.nome,
    required this.data_de_aquisicao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marcado': marcado ? 1 : 0,
      'nome': nome,
      'data_de_aquisicao': data_de_aquisicao.toIso8601String(),
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'],
      marcado: map['marcado'] == 1,
      nome: map['nome'],
      data_de_aquisicao: DateTime.parse(map['data_de_aquisicao']),
    );
  }
}

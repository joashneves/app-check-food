class Ingrediente {
  String id;
  bool marcado;
  String nome;
  DateTime data_de_criacao;
  DateTime? data_de_aquisicao;
  String? comida_id;

  Ingrediente({
    required this.id,
    required this.marcado,
    required this.nome,
    required this.data_de_criacao,
    this.data_de_aquisicao,
    this.comida_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marcado': marcado ? 1 : 0,
      'nome': nome,
      'data_de_criacao': data_de_criacao.toIso8601String(),
      'data_de_aquisicao': data_de_aquisicao?.toIso8601String(),
      'comida_id': comida_id,
    };
  }

  factory Ingrediente.fromMap(Map<String, dynamic> map) {
    return Ingrediente(
      id: map['id'],
      marcado: map['marcado'] == 1,
      nome: map['nome'],
      data_de_criacao: DateTime.parse(map['data_de_criacao']),
      data_de_aquisicao: map['data_de_aquisicao'] != null ? DateTime.parse(map['data_de_aquisicao']) : null,
      comida_id: map['comida_id'],
    );
  }
}

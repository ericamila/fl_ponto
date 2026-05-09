class Registro {
  final String? id;
  final String data;
  final String hora;
  final int mes;
  final int ano;
  final bool isEntrada;

  Registro({
    required this.data,
    required this.hora,
    required this.mes,
    required this.ano,
    required this.isEntrada,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      "data": data,
      "hora": hora,
      "mes": mes,
      "ano": ano,
      "entrada": isEntrada,
    };
  }

  factory Registro.fromMap(Map<String, dynamic> map, {String? id}) {
    return Registro(
      id: id,
      data: map['data'] ?? '',
      hora: map['hora'] ?? '',
      mes: map['mes'] ?? 0,
      ano: map['ano'] ?? 0,
      isEntrada: map['entrada'] ?? true,
    );
  }

  static List<Registro> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Registro.fromMap(map)).toList();
  }
}

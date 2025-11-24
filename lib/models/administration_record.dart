class AdministrationRecord {
  final DateTime dateTime;
  final int? glucose;
  final String insulinType;
  final int dose;
  final String local;
  final String notes;

  AdministrationRecord({
    required this.dateTime,
    this.glucose,
    required this.insulinType,
    required this.dose,
    required this.local,
    required this.notes,
  });

  // Converte para MAPA (para salvar)
  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'glucose': glucose,
      'insulinType': insulinType,
      'dose': dose,
      'local': local,
      'notes': notes,
    };
  }

  // Cria a partir do MAPA (para carregar)
  factory AdministrationRecord.fromMap(Map<String, dynamic> map) {
    return AdministrationRecord(
      dateTime: DateTime.parse(map['dateTime']),
      glucose: map['glucose'],
      insulinType: map['insulinType'],
      dose: map['dose'],
      local: map['local'],
      notes: map['notes'] ?? '',
    );
  }
}
// lib/models/daily_record_model.dart

class DailyRecord {
  final String patientId;
  final DateTime date;
  final String prescriptionText; // Prescrição gerada no dia (texto Markdown)
  final String observations; // Campo de observações

  DailyRecord({
    required this.patientId,
    required this.date,
    required this.prescriptionText,
    required this.observations,
  });

  // Construtor para facilitar a criação a partir de um mapa (simulando um banco de dados)
  DailyRecord.fromMap(Map<String, dynamic> map)
      : patientId = map['patientId'],
        date = DateTime.parse(map['date']),
        prescriptionText = map['prescriptionText'],
        observations = map['observations'];

  // Converte o objeto para um mapa (simulando um banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'date': date.toIso8601String(),
      'prescriptionText': prescriptionText,
      'observations': observations,
    };
  }
}

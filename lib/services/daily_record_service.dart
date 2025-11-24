// lib/services/daily_record_service.dart

import '../models/daily_record_model.dart';

class DailyRecordService {
  // Mock de um banco de dados simples (armazenamento em memória)
  static final List<DailyRecord> _records = [];

  // Adiciona um novo registro diário
  void addRecord(DailyRecord record) {
    // Remove registros antigos para o mesmo dia, se houver
    _records.removeWhere((r) =>
        r.patientId == record.patientId &&
        r.date.year == record.date.year &&
        r.date.month == record.date.month &&
        r.date.day == record.date.day);

    _records.add(record);
  }

  // Obtém todos os registros de um paciente
  List<DailyRecord> getRecordsByPatientId(String patientId) {
    return _records
        .where((r) => r.patientId == patientId)
        .toList()
        .reversed
        .toList(); // Retorna em ordem decrescente de data
  }

  // Obtém o último registro de um paciente
  DailyRecord? getLastRecord(String patientId) {
    final patientRecords = getRecordsByPatientId(patientId);
    return patientRecords.isNotEmpty ? patientRecords.first : null;
  }

  // Limpa todos os registros (para fins de teste ou alta)
  void clearRecords(String patientId) {
    _records.removeWhere((r) => r.patientId == patientId);
  }
}

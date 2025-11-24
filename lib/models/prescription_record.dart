class PrescriptionRecord {
  final DateTime date;
  final int glucose;
  final String prescriptionText;
  final String medicalNotes;

  PrescriptionRecord({
    required this.date,
    required this.glucose,
    required this.prescriptionText,
    required this.medicalNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'glucose': glucose,
      'prescriptionText': prescriptionText,
      'medicalNotes': medicalNotes,
    };
  }

  factory PrescriptionRecord.fromMap(Map<String, dynamic> map) {
    return PrescriptionRecord(
      date: DateTime.parse(map['date']),
      glucose: map['glucose'],
      prescriptionText: map['prescriptionText'] ?? '',
      medicalNotes: map['medicalNotes'] ?? '',
    );
  }
}
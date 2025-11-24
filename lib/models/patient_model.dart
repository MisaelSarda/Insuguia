import 'dart:math';
import 'prescription_record.dart';
import 'administration_record.dart';

class Patient {
  String id;
  String name;
  double weight;
  double height;
  double creatinine;
  int age;
  String gender;
  bool isDischarged;
  String ethnicity;

  final List<PrescriptionRecord> prescriptionHistory;
  final List<AdministrationRecord> administrationHistory;

  Patient({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.creatinine,
    required this.age,
    required this.gender,
    this.isDischarged = false,
    required this.ethnicity,
    List<PrescriptionRecord>? prescriptionHistory,
    List<AdministrationRecord>? administrationHistory,
  }) : 
    prescriptionHistory = prescriptionHistory ?? [],
    administrationHistory = administrationHistory ?? [];

  // --- LÓGICA DE BANCO DE DADOS (JSON) ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'height': height,
      'creatinine': creatinine,
      'age': age,
      'gender': gender,
      'isDischarged': isDischarged,
      'ethnicity': ethnicity,
      // Converte as listas internas
      'prescriptionHistory': prescriptionHistory.map((x) => x.toMap()).toList(),
      'administrationHistory': administrationHistory.map((x) => x.toMap()).toList(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      weight: map['weight'],
      height: map['height'],
      creatinine: map['creatinine'],
      age: map['age'],
      gender: map['gender'],
      isDischarged: map['isDischarged'] ?? false,
      ethnicity: map['ethnicity'] ?? 'Não-Negro',
      // Reconstrói as listas internas
      prescriptionHistory: map['prescriptionHistory'] != null
          ? List<PrescriptionRecord>.from(map['prescriptionHistory']?.map((x) => PrescriptionRecord.fromMap(x)))
          : [],
      administrationHistory: map['administrationHistory'] != null
          ? List<AdministrationRecord>.from(map['administrationHistory']?.map((x) => AdministrationRecord.fromMap(x)))
          : [],
    );
  }

  // --- CÁLCULOS CLÍNICOS ---
  double get imc {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  double get tfgCkdEpi {
    double k = gender == 'Feminino' ? 0.7 : 0.9;
    double alpha = gender == 'Feminino' ? -0.329 : -0.411;
    double beta = gender == 'Feminino' ? -1.209 : -1.209;
    double egfr;
    if (creatinine <= k) {
      egfr = (141 * pow(creatinine / k, alpha) * pow(0.993, age)).toDouble();
    } else {
      egfr = (141 * pow(creatinine / k, beta) * pow(0.993, age)).toDouble();
    }
    if (gender == 'Feminino') egfr *= 1.018;
    if (ethnicity == 'Negro') egfr *= 1.159;
    return egfr;
  }
}
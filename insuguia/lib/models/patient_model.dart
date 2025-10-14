// lib/models/patient_model.dart

class Patient {
  String id;
  String name;
  double weight; // em kg
  double height; // em cm
  double creatinine; // creatinina sérica

  Patient({
    required this.id,
    required this.name,
    required this.weight,
    required this.height,
    required this.creatinine,
  });

  // Método para calcular o Índice de Massa Corporal (IMC)
  double get imc {
    if (height <= 0) return 0;
    // fórmula: peso / (altura em metros)^2
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // A função para calcular a Taxa de Filtração Glomerular (TFG) pelo CKD-EPI
  // é mais complexa e precisaria de mais dados (idade, sexo, etnia).
  // Por enquanto, deixamos um placeholder.
  String get tfgPlaceholder {
    // Placeholder - A implementação real requer mais dados e uma fórmula específica.
    return "Cálculo de TFG (CKD-EPI) pendente";
  }
}
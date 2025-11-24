// lib/services/patient_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_model.dart';

class PatientService {
  static const String _key = 'patients_data_v1';

  // Salvar a lista inteira de pacientes
  Future<void> savePatients(List<Patient> patients) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Converte cada paciente para Mapa
    // 2. Converte a lista de Mapas para Texto (JSON)
    final String data = json.encode(patients.map((p) => p.toMap()).toList());
    await prefs.setString(_key, data);
    print("Dados salvos com sucesso!");
  }

  // Carregar a lista de pacientes
  Future<List<Patient>> loadPatients() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    
    if (data == null) return [];

    try {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((map) => Patient.fromMap(map)).toList();
    } catch (e) {
      print("Erro ao carregar dados: $e");
      return [];
    }
  }

  // Adicionar ou Atualizar um paciente e salvar automaticamente
  Future<void> saveOrUpdatePatient(Patient patient) async {
    final patients = await loadPatients();
    final index = patients.indexWhere((p) => p.id == patient.id);

    if (index >= 0) {
      patients[index] = patient; // Atualiza existente
    } else {
      patients.add(patient); // Adiciona novo
    }
    
    await savePatients(patients);
  }
}
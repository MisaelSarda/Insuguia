// lib/screens/daily_record_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/patient_model.dart';
import '../models/enums.dart';
import '../models/daily_record_model.dart';
import '../services/insulin_calculator.dart';
import '../services/daily_record_service.dart';

class DailyRecordScreen extends StatefulWidget {
  final Patient patient;

  const DailyRecordScreen({super.key, required this.patient});

  @override
  State<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends State<DailyRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _observationsController = TextEditingController();
  InsulinSensitivity _selectedSensitivity = InsulinSensitivity.Usual;
  DietStatus _selectedDietStatus = DietStatus.DietaOral;
  String _prescriptionText = '';
  final DailyRecordService _recordService = DailyRecordService();

  @override
  void initState() {
    super.initState();
    _calculatePrescription();
  }

  void _calculatePrescription() {
    setState(() {
      _prescriptionText = InsulinCalculator.generatePrescription(
        widget.patient,
        _selectedSensitivity,
        _selectedDietStatus,
        int.tryParse(_glucoseController.text) ?? 0,
        _observationsController.text,
      );
    });
  }

  void _saveDailyRecord() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Recalcula a prescrição uma última vez antes de salvar
    _calculatePrescription();

    final newRecord = DailyRecord(
      patientId: widget.patient.id,
      date: DateTime.now(),
      prescriptionText: _prescriptionText,
      observations: _observationsController.text,
    );

    _recordService.addRecord(newRecord);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro diário salvo com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acompanhamento Diário - ${widget.patient.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 1. Glicemia Capilar Atual
              TextFormField(
                controller: _glucoseController,
                decoration: const InputDecoration(
                    labelText: 'Glicemia Capilar Atual (mg/dL)'),
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  // Não recalcula a prescrição aqui para evitar o bug de regeneração constante
                },
                validator: (value) {
                  if (int.tryParse(value ?? '') == null ||
                      int.parse(value!) <= 0) {
                    return 'Insira um valor válido de glicemia.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 2. Sensibilidade à Insulina
              DropdownButtonFormField<InsulinSensitivity>(
                decoration:
                    const InputDecoration(labelText: 'Sensibilidade à Insulina'),
                value: _selectedSensitivity,
                items: InsulinSensitivity.values.map((sensitivity) {
                  return DropdownMenuItem(
                    value: sensitivity,
                    child: Text(sensitivity.toString().split('.').last),
                  );
                }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedSensitivity = newValue!;
                    });
                  },
              ),
              const SizedBox(height: 20),

              // 3. Dieta
              DropdownButtonFormField<DietStatus>(
                decoration: const InputDecoration(labelText: 'Status da Dieta'),
                value: _selectedDietStatus,
                items: DietStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.toString().split('.').last),
                  );
                }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDietStatus = newValue!;
                    });
                  },
              ),
              const SizedBox(height: 30),

              // 4. Prescrição Sugerida (Resultado)
              const Text('Prescrição Sugerida (Atualizada em Tempo Real):',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: MarkdownBody(data: _prescriptionText),
              ),
              const SizedBox(height: 20),



              // 6. Botão Salvar
              ElevatedButton(
                onPressed: _saveDailyRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Salvar Registro Diário',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/screens/add_edit_patient_screen.dart

import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'dart:math';

class AddEditPatientScreen extends StatefulWidget {
  const AddEditPatientScreen({super.key});

  @override
  State<AddEditPatientScreen> createState() => _AddEditPatientScreenState();
}

class _AddEditPatientScreenState extends State<AddEditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _creatinineController = TextEditingController();

  void _saveForm() {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final newPatient = Patient(
      id: 'p${Random().nextInt(1000)}', // ID simples para o protótipo
      name: _nameController.text,
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      creatinine: double.parse(_creatinineController.text),
    );

    Navigator.of(context).pop(newPatient);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _creatinineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Paciente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Por favor, insira um peso válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                   if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Por favor, insira uma altura válida.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _creatinineController,
                decoration: const InputDecoration(labelText: 'Creatinina Sérica'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                validator: (value) {
                   if (value == null || double.tryParse(value) == null || double.parse(value) < 0) {
                    return 'Por favor, insira um valor válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blueGrey,
                   padding: const EdgeInsets.symmetric(vertical: 12),
                   textStyle: const TextStyle(fontSize: 18)
                ),
                child: const Text('Salvar Paciente', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
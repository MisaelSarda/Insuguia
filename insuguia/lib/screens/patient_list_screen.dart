// lib/screens/patient_list_screen.dart

import 'package:flutter/material.dart';
import '../models/patient_model.dart';
import 'add_edit_patient_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  // Lista simulada de pacientes para começar
  final List<Patient> _patients = [
    Patient(id: 'p1', name: 'José da Silva', weight: 85, height: 175, creatinine: 1.1),
    Patient(id: 'p2', name: 'Maria Souza', weight: 68, height: 162, creatinine: 0.9),
  ];

  void _addPatient(Patient patient) {
    setState(() {
      _patients.add(patient);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InsuGuia - Pacientes'),
      ),
      body: Column(
        children: [
          // Aviso Legal fixo no topo da tela
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.amber[100],
            child: const Text(
              'Protótipo acadêmico - Não utilizar em prática clínica.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _patients.isEmpty
                ? const Center(
                    child: Text('Nenhum paciente cadastrado.'),
                  )
                : ListView.builder(
                    itemCount: _patients.length,
                    itemBuilder: (ctx, index) {
                      final patient = _patients[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text(patient.name),
                          subtitle: Text(
                              'IMC: ${patient.imc.toStringAsFixed(2)} | Peso: ${patient.weight}kg'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // A navegação para a tela de detalhes do paciente será implementada aqui.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tela de detalhes para ${patient.name} a ser implementada.')),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newPatient = await Navigator.push<Patient>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditPatientScreen(),
            ),
          );
          if (newPatient != null) {
            _addPatient(newPatient);
          }
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
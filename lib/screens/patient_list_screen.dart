import 'package:flutter/material.dart';

import 'patient_detail_screen.dart';

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

  ];



  void _updatePatientList() {

    // Força a reconstrução da lista para refletir o status de alta

    setState(() {});

  }

 



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

            child: _patients.where((p) => !p.isDischarged).isEmpty

                ? const Center(

                    child: Text('Nenhum paciente cadastrado.'),

                  )

                : ListView.builder(

                    itemCount: _patients.where((p) => !p.isDischarged).length,

                    itemBuilder: (ctx, index) {

                      final activePatients = _patients.where((p) => !p.isDischarged).toList();

                      final patient = activePatients[index];

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

                          onTap: () async {

                            await Navigator.of(context).push(

                              MaterialPageRoute(

                                builder: (ctx) => PatientDetailScreen(patient: patient, onDischarge: _updatePatientList),

                              ),

                            );

                            _updatePatientList(); // Atualiza a lista ao retornar da tela de detalhes

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

        backgroundColor: Colors.teal,

        child: const Icon(Icons.add, color: Colors.white),

      ),

    );

  }

}


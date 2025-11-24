// lib/screens/patient_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/patient_model.dart';
import '../models/prescription_record.dart';
import 'prescription_screen.dart';
import 'insulin_administration_screen.dart'; // <--- Importe a nova tela

// Imports legado
import 'package:insuguia/screens/daily_record_screen.dart';
import 'daily_record_history_screen.dart';
import 'package:insuguia/services/daily_record_service.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  final VoidCallback? onDischarge;

  const PatientDetailScreen({super.key, required this.patient, this.onDischarge});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DailyRecordService _recordService = DailyRecordService();

  @override
  void initState() {
    super.initState();
    // Usaremos Abas para organizar: Prescrições vs Aplicações
    _tabController = TabController(length: 2, vsync: this);
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2,'0')}";
  }

  Color _getPrescriptionColor(int glucose) {
    if (glucose < 70) return Colors.red.shade50;
    if (glucose < 140) return Colors.green.shade50;
    if (glucose <= 180) return Colors.amber.shade50;
    return Colors.blue.shade50;
  }

  // Modal para Prescrição
  void _showPrescriptionDetails(PrescriptionRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Detalhes da Prescrição", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(),
              Text("Data: ${_formatDate(record.date)}"),
              Text("Glicemia Base: ${record.glucose} mg/dL"),
              const SizedBox(height: 20),
              MarkdownBody(data: record.prescriptionText),
            ],
          ),
        ),
      ),
    );
  }

  void _dischargePatient(BuildContext context, Patient patient) {
    // (Código de alta mantido igual)
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Alta'),
        content: const Text('Tem certeza que deseja dar alta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              _recordService.clearRecords(patient.id);
              patient.prescriptionHistory.clear();
              patient.administrationHistory.clear(); // Limpa também as aplicações
              setState(() => patient.isDischarged = true);
              if (widget.onDischarge != null) widget.onDischarge!();
              Navigator.pop(ctx);
            },
            child: const Text('Confirmar Alta'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    
    return Scaffold(
      appBar: AppBar(title: Text(patient.name), backgroundColor: Colors.teal),
      body: Column(
        children: [
          // --- DADOS DO PACIENTE ---
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Peso: ${patient.weight}kg | Altura: ${patient.height}cm"),
                  Text("IMC: ${patient.imc.toStringAsFixed(1)}"),
                ]),
                ElevatedButton.icon(
                  onPressed: patient.isDischarged ? null : () => _dischargePatient(context, patient),
                  icon: const Icon(Icons.exit_to_app, size: 16),
                  label: const Text("Dar Alta"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                )
              ],
            ),
          ),

          // --- BOTÕES DE AÇÃO ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Botão 1: Prescrever (Médico)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (ctx) => PrescriptionScreen(patient: patient)));
                      setState(() {});
                    },
                    icon: const Icon(Icons.note_add),
                    label: const Text("Prescrever"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão 2: Aplicar (Enfermagem)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (ctx) => InsulinAdministrationScreen(patient: patient)));
                      setState(() {});
                    },
                    icon: const Icon(Icons.vaccines),
                    label: const Text("Aplicar"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // --- ABAS DE HISTÓRICO ---
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "Histórico de Prescrições", icon: Icon(Icons.history_edu, color: Colors.teal)),
              Tab(text: "Registro de Aplicações", icon: Icon(Icons.assignment_turned_in, color: Colors.purple)),
            ],
          ),

          // --- LISTAS ---
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ABA 1: PRESCRIÇÕES
                _buildPrescriptionList(patient),
                
                // ABA 2: APLICAÇÕES REALIZADAS
                _buildAdministrationList(patient),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionList(Patient patient) {
    final list = patient.prescriptionHistory.reversed.toList();
    if (list.isEmpty) return const Center(child: Text("Nenhuma prescrição."));
    
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (ctx, i) {
        final rec = list[i];
        return Card(
          color: _getPrescriptionColor(rec.glucose),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white, child: Text("${rec.glucose}", style: const TextStyle(fontSize: 12))),
            title: Text(rec.glucose > 180 ? "Correção Indicada" : "Monitoramento"),
            subtitle: Text(_formatDate(rec.date)),
            trailing: const Icon(Icons.visibility),
            onTap: () => _showPrescriptionDetails(rec),
          ),
        );
      },
    );
  }

  Widget _buildAdministrationList(Patient patient) {
    final list = patient.administrationHistory.reversed.toList();
    if (list.isEmpty) return const Center(child: Text("Nenhuma aplicação registrada."));

    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (ctx, i) {
        final rec = list[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.check, color: Colors.white)),
            title: Text("${rec.dose} UI de ${rec.insulinType}"),
            subtitle: Text("${_formatDate(rec.dateTime)} - ${rec.local}"),
            trailing: rec.glucose != null ? Text("Glic: ${rec.glucose}") : null,
          ),
        );
      },
    );
  }
}
// lib/screens/daily_record_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/patient_model.dart';
import '../models/daily_record_model.dart';
import '../services/daily_record_service.dart';

class DailyRecordHistoryScreen extends StatefulWidget {
  final Patient patient;

  const DailyRecordHistoryScreen({super.key, required this.patient});

  @override
  State<DailyRecordHistoryScreen> createState() => _DailyRecordHistoryScreenState();
}

class _DailyRecordHistoryScreenState extends State<DailyRecordHistoryScreen> {
  final DailyRecordService _recordService = DailyRecordService();
  List<DailyRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    setState(() {
      _records = _recordService.getRecordsByPatientId(widget.patient.id);
      // Ordenar por data decrescente (mais recente primeiro)
      _records.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico Diário - ${widget.patient.name}'),
      ),
      body: _records.isEmpty
          ? const Center(
              child: Text('Nenhum registro diário encontrado.'),
            )
          : ListView.builder(
              itemCount: _records.length,
              itemBuilder: (ctx, index) {
                final record = _records[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ExpansionTile(
                    title: Text(
                      'Registro de ${record.date.day}/${record.date.month}/${record.date.year} ${record.date.hour}:${record.date.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Observações: ${record.observations.isEmpty ? 'Nenhuma' : record.observations}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prescrição Gerada:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: MarkdownBody(data: record.prescriptionText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/patient_model.dart';

import '../models/enums.dart';

import '../models/prescription_record.dart'; // Importe o modelo novo

import '../services/insulin_calculator.dart';



class PrescriptionScreen extends StatefulWidget {

  final Patient patient;



  const PrescriptionScreen({super.key, required this.patient});



  @override

  State<PrescriptionScreen> createState() => _PrescriptionScreenState();

}



class _PrescriptionScreenState extends State<PrescriptionScreen> {

  InsulinSensitivity _sensibilidadeSelecionada = InsulinSensitivity.Usual;

  DietStatus _statusDietaSelecionado = DietStatus.DietaOral;

  final _controladorGlicemia = TextEditingController();

  final _controladorObservacoes = TextEditingController();

 

  // Variáveis de visualização

  String? _textoOrientacao;

  Color _corDeFundoOrientacao = Colors.white;

  IconData _iconeOrientacao = Icons.info_outline;



  @override

  void dispose() {

    _controladorGlicemia.dispose();

    _controladorObservacoes.dispose();

    super.dispose();

  }



  void _calculatePrescription() {

    final glicemiaInput = _controladorGlicemia.text;

    final glicemiaAtual = int.tryParse(glicemiaInput);



    if (glicemiaInput.isEmpty || glicemiaAtual == null) {

      setState(() {

        _textoOrientacao = null;

      });

      return;

    }



    String textoGerado;

    Color corGerada;

    IconData iconeGerado;



    // --- LÓGICA DE SEGURANÇA ---



    // 1. HIPOGLICEMIA (< 70)

    if (glicemiaAtual < 70) {

      textoGerado = """

### 🚨 **PROTOCOLO DE HIPOGLICEMIA (< 70 mg/dL)**



**Conduta Imediata:**

* **Paciente Consciente:** Oferecer 15-20g de carboidrato rápido.

* **Paciente Inconsciente:** Glicose 50% IV (20-30ml).



**Monitoramento:**

* Repetir glicemia em 15 min.

* Suspender insulina do horário.

""";

      corGerada = Colors.red.shade50;

      iconeGerado = Icons.warning_amber_rounded;

    }

    // 2. ALVO (70-139)

    else if (glicemiaAtual < 140) {

      textoGerado = """

### ✅ **Glicemia no Alvo**



**Conduta:**

* Nenhuma correção necessária.

* Manter monitoramento de rotina.

""";

      corGerada = Colors.green.shade50;

      iconeGerado = Icons.check_circle_outline;

    }

    // 3. ALERTA (140-180)

    else if (glicemiaAtual <= 180) {

      textoGerado = """

### ⚠️ **Alerta: Hiperglicemia Hospitalar**

*(140 - 180 mg/dL)*



**Conduta:**

* Monitorar.

* Ainda não atinge critério para correção medicamentosa obrigatória (>180).

""";

      corGerada = Colors.amber.shade50;

      iconeGerado = Icons.health_and_safety;

    }

    // 4. PRESCRIÇÃO (> 180)

    else {

      final prescricao = InsulinCalculator.generatePrescription(

        widget.patient,

        _sensibilidadeSelecionada,

        _statusDietaSelecionado,

        glicemiaAtual,

        _controladorObservacoes.text,

      );



      textoGerado = """

### 💉 **Indicação de Correção**



$prescricao

""";

      corGerada = Colors.blue.shade50;

      iconeGerado = Icons.medication;

    }



    setState(() {

      _textoOrientacao = textoGerado;

      _corDeFundoOrientacao = corGerada;

      _iconeOrientacao = iconeGerado;

    });

  }



  // --- FUNÇÃO DE SALVAR (NOVA) ---

  void _salvarPrescricao() {

    if (_textoOrientacao == null || _controladorGlicemia.text.isEmpty) return;



    final novoRegistro = PrescriptionRecord(

      date: DateTime.now(),

      glucose: int.parse(_controladorGlicemia.text),

      prescriptionText: _textoOrientacao!,

      medicalNotes: _controladorObservacoes.text,

    );



    setState(() {

      widget.patient.prescriptionHistory.add(novoRegistro);

    });



    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text('Prescrição salva no histórico do paciente!'),

        backgroundColor: Colors.green,

      ),

    );



    Navigator.pop(context); // Fecha a tela após salvar

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('Gerar Prescrição'), backgroundColor: Colors.teal),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16.0),

        child: Column(

          children: [

            // Inputs

            Card(

              child: Padding(

                padding: const EdgeInsets.all(16),

                child: Column(

                  children: [

                    TextFormField(

                      controller: _controladorGlicemia,

                      decoration: const InputDecoration(labelText: 'Glicemia (mg/dL)', border: OutlineInputBorder()),

                      keyboardType: TextInputType.number,

                      onChanged: (_) => _calculatePrescription(),

                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<InsulinSensitivity>(

                      decoration: const InputDecoration(labelText: 'Sensibilidade', border: OutlineInputBorder()),

                      value: _sensibilidadeSelecionada,

                      items: InsulinSensitivity.values.map((s) => DropdownMenuItem(value: s, child: Text(s.toString().split('.').last))).toList(),

                      onChanged: (v) { if (v != null) setState(() { _sensibilidadeSelecionada = v; _calculatePrescription(); }); },

                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<DietStatus>(

                      decoration: const InputDecoration(labelText: 'Dieta', border: OutlineInputBorder()),

                      value: _statusDietaSelecionado,

                      items: DietStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.toString().split('.').last))).toList(),

                      onChanged: (v) { if (v != null) setState(() { _statusDietaSelecionado = v; _calculatePrescription(); }); },

                    ),

                    const SizedBox(height: 16),

                    TextFormField(

                      controller: _controladorObservacoes,

                      decoration: const InputDecoration(labelText: 'Observações', border: OutlineInputBorder()),

                      onChanged: (_) => _calculatePrescription(),

                    ),

                  ],

                ),

              ),

            ),



            const SizedBox(height: 20),



            const SizedBox(height: 20),

            if (_textoOrientacao != null)

              Container(

                decoration: BoxDecoration(

                  color: _corDeFundoOrientacao,

                  border: Border.all(color: Colors.grey.shade300),

                  borderRadius: BorderRadius.circular(8),

                ),

                child: Column(

                  children: [

                    ListTile(

                      leading: Icon(_iconeOrientacao, color: Colors.black87),

                      title: const Text("PROTOCOLO SUGERIDO", style: TextStyle(fontWeight: FontWeight.bold)),

                    ),

                    const Divider(height: 1),

                    Padding(

                      padding: const EdgeInsets.all(16),

                      child: MarkdownBody(data: _textoOrientacao!),

                    ),

                   

                    // --- BOTÃO SALVAR (Fica dentro do card ou logo abaixo) ---

                    Padding(

                      padding: const EdgeInsets.all(16.0),

                      child: ElevatedButton.icon(

                        onPressed: _salvarPrescricao,

                        icon: const Icon(Icons.save),

                        label: const Text('CONFIRMAR E SALVAR NO PRONTUÁRIO'),

                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.blue.shade900,

                          foregroundColor: Colors.white,

                          minimumSize: const Size(double.infinity, 50),

                        ),

                      ),

                    ),

                  ],

                ),

              ),

          ],

        ),

      ),

    );

  }

}
import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import '../models/patient_model.dart';

import '../models/administration_record.dart';



class InsulinAdministrationScreen extends StatefulWidget {

  final Patient patient;



  const InsulinAdministrationScreen({super.key, required this.patient});



  @override

  State<InsulinAdministrationScreen> createState() => _InsulinAdministrationScreenState();

}



class _InsulinAdministrationScreenState extends State<InsulinAdministrationScreen> {

  final _formKey = GlobalKey<FormState>();

 

  // Controladores

  final _glicemiaController = TextEditingController();

  final _doseController = TextEditingController();

  final _obsController = TextEditingController();

 

  // Valores selecionados

  String _tipoInsulina = 'Regular';

  String _localAplicacao = 'Abdômen';

  String _motivoAplicacao = 'Correção de Hiperglicemia'; // Novo campo



  final List<String> _tiposInsulina = ['Regular', 'NPH', 'Lispro', 'Aspart', 'Glulisina', 'Glargina', 'Detemir'];

  final List<String> _locais = ['Abdômen', 'Braço Direito', 'Braço Esquerdo', 'Coxa Direita', 'Coxa Esquerda', 'Glúteo'];

  final List<String> _motivos = ['Correção de Hiperglicemia', 'Dose de Refeição (Prandial)', 'Dose Basal (Horário)', 'Outro'];



  @override

  void dispose() {

    _glicemiaController.dispose();

    _doseController.dispose();

    _obsController.dispose();

    super.dispose();

  }



  void _tentarSalvar() {

    if (!_formKey.currentState!.validate()) return;



    final int? glicemia = int.tryParse(_glicemiaController.text);

   

    // --- LÓGICA DE SEGURANÇA (TRAVAS) ---



    // 1. Alerta de Hipoglicemia (Bloqueio Total sugerido)

    if (glicemia != null && glicemia < 70) {

      _mostrarAlertaBloqueio(

        titulo: "PERIGO: HIPOGLICEMIA",

        mensagem: "Glicemia de $glicemia mg/dL detectada.\n\nNÃO APLICAR INSULINA.\nInicie protocolo de tratamento de hipoglicemia imediatamente.",

        cor: Colors.red,

      );

      return;

    }



    // 2. Trava de Correção Desnecessária (< 180)

    // Só aplica se o motivo for "Correção". Se for "Refeição", pode aplicar mesmo < 180.

    if (_motivoAplicacao == 'Correção de Hiperglicemia' && glicemia != null && glicemia <= 180) {

      _mostrarAlertaBloqueio(

        titulo: "Correção Não Indicada",

        mensagem: "Para correção, o protocolo exige Glicemia > 180 mg/dL.\n\nValor atual: $glicemia mg/dL.\n\nA dose de correção não deve ser aplicada.",

        cor: Colors.amber.shade900,

      );

      return;

    }



    // Se passou pelas travas, salva

    _salvarAplicacaoConfirmada();

  }



  void _mostrarAlertaBloqueio({required String titulo, required String mensagem, required Color cor}) {

    showDialog(

      context: context,

      builder: (ctx) => AlertDialog(

        title: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold)),

        content: Text(mensagem),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx),

            child: const Text('Entendido, vou revisar'),

          ),

        ],

      ),

    );

  }



  void _salvarAplicacaoConfirmada() {

    final novaAplicacao = AdministrationRecord(

      dateTime: DateTime.now(),

      glucose: int.tryParse(_glicemiaController.text),

      insulinType: _tipoInsulina,

      dose: int.parse(_doseController.text),

      local: _localAplicacao,

      notes: "Motivo: $_motivoAplicacao. ${_obsController.text}", // Salva o motivo nas notas

    );



    setState(() {

      widget.patient.administrationHistory.add(novaAplicacao);

    });



    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text('Aplicação registrada com sucesso!'), backgroundColor: Colors.purple),

    );



    Navigator.pop(context);

  }



  @override

  Widget build(BuildContext context) {

    // Pega a última prescrição para exibir como referência

    final ultimaPrescricao = widget.patient.prescriptionHistory.isNotEmpty

        ? widget.patient.prescriptionHistory.last

        : null;



    return Scaffold(

      appBar: AppBar(

        title: const Text('Registrar Aplicação'),

        backgroundColor: Colors.purple.shade700,

        foregroundColor: Colors.white,

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16.0),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // --- BLOCO 1: REFERÊNCIA (PRESCRIÇÃO) ---

            if (ultimaPrescricao != null) ...[

              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(

                  color: Colors.blue.shade50,

                  border: Border.all(color: Colors.blue.shade200),

                  borderRadius: BorderRadius.circular(8),

                ),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Row(

                      children: [

                        Icon(Icons.description, color: Colors.blue),

                        SizedBox(width: 8),

                        Text("Referência: Última Prescrição", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),

                      ],

                    ),

                    const Divider(),

                    SizedBox(

                      height: 120, // Altura reduzida para focar no registro

                      child: SingleChildScrollView(

                        child: MarkdownBody(data: ultimaPrescricao.prescriptionText),

                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(height: 20),

            ],



            const Text("Dados da Aplicação", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const Divider(),



            // --- BLOCO 2: FORMULÁRIO ---

            Form(

              key: _formKey,

              child: Card(

                elevation: 2,

                child: Padding(

                  padding: const EdgeInsets.all(16),

                  child: Column(

                    children: [

                      // Glicemia Atual

                      TextFormField(

                        controller: _glicemiaController,

                        decoration: const InputDecoration(

                          labelText: 'Glicemia no momento (mg/dL)',

                          border: OutlineInputBorder(),

                          prefixIcon: Icon(Icons.water_drop, color: Colors.red),

                          helperText: 'Obrigatório para doses de correção',

                        ),

                        keyboardType: TextInputType.number,

                        validator: (v) {

                          if (_motivoAplicacao == 'Correção de Hiperglicemia' && (v == null || v.isEmpty)) {

                            return 'Informe a glicemia para calcular correção';

                          }

                          return null;

                        },

                      ),

                      const SizedBox(height: 16),



                      // Motivo da Aplicação (Novo)

                      DropdownButtonFormField<String>(

                        decoration: const InputDecoration(labelText: 'Motivo da Aplicação', border: OutlineInputBorder()),

                        value: _motivoAplicacao,

                        isExpanded: true,

                        items: _motivos.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),

                        onChanged: (v) => setState(() => _motivoAplicacao = v!),

                      ),

                      const SizedBox(height: 16),



                      // Tipo de Insulina e Dose

                      Row(

                        children: [

                          Expanded(

                            flex: 2,

                            child: DropdownButtonFormField<String>(

                              decoration: const InputDecoration(labelText: 'Insulina', border: OutlineInputBorder()),

                              value: _tipoInsulina,

                              isExpanded: true,

                              items: _tiposInsulina.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),

                              onChanged: (v) => setState(() => _tipoInsulina = v!),

                            ),

                          ),

                          const SizedBox(width: 10),

                          Expanded(

                            flex: 1,

                            child: TextFormField(

                              controller: _doseController,

                              decoration: const InputDecoration(labelText: 'Dose (UI)', border: OutlineInputBorder()),

                              keyboardType: TextInputType.number,

                              validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 16),



                      // Local

                      DropdownButtonFormField<String>(

                        decoration: const InputDecoration(labelText: 'Local de Aplicação', border: OutlineInputBorder()),

                        value: _localAplicacao,

                        items: _locais.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),

                        onChanged: (v) => setState(() => _localAplicacao = v!),

                      ),

                      const SizedBox(height: 16),



                      // Obs

                      TextFormField(

                        controller: _obsController,

                        decoration: const InputDecoration(labelText: 'Observações', border: OutlineInputBorder()),

                        maxLines: 2,

                      ),

                      const SizedBox(height: 20),



                      // Botão Salvar com Validação

                      SizedBox(

                        width: double.infinity,

                        height: 50,

                        child: ElevatedButton.icon(

                          onPressed: _tentarSalvar, // Chama a função que verifica as travas

                          icon: const Icon(Icons.check_circle),

                          label: const Text('VALIDAR E CONFIRMAR', style: TextStyle(fontWeight: FontWeight.bold)),

                          style: ElevatedButton.styleFrom(

                            backgroundColor: Colors.purple.shade700,

                            foregroundColor: Colors.white,

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}
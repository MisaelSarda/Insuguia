import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// O import foi ajustado para o nome do seu app, conforme o main.dart
import 'package:insuguia/main.dart'; 

void main() {
  // O nome do teste foi alterado para refletir o que ele realmente faz.
  testWidgets('Verifica se a tela inicial de pacientes carrega corretamente', (WidgetTester tester) async {
    // Constrói nosso aplicativo e dispara um frame.
    // A classe MyApp foi substituída pela classe principal do seu app: InsuGuiaApp.
    await tester.pumpWidget(const InsuGuiaApp());

    // Verifica se o título da AppBar está correto.
    expect(find.text('InsuGuia - Pacientes'), findsOneWidget);

    // Verifica se o aviso legal importante está visível na tela.
    expect(find.text('Protótipo acadêmico - Não utilizar em prática clínica.'), findsOneWidget);

    // Verifica se o botão de adicionar paciente (FloatingActionButton) existe.
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verifica se um dos pacientes da lista de mock inicial está sendo exibido.
    // Isso confirma que o ListView está sendo populado.
    expect(find.text('José da Silva'), findsOneWidget);
  });
}

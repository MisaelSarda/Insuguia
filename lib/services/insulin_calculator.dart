// lib/services/insulin_calculator.dart


import '../models/patient_model.dart';
import '../models/enums.dart';

class InsulinCalculator {
  // Regras de sensibilidade à insulina para DTD inicial (UI/Kg/dia)
  static const Map<InsulinSensitivity, double> _sensitivityFactors = {
    InsulinSensitivity.Sensivel: 0.4,
    InsulinSensitivity.Usual: 0.5,
    InsulinSensitivity.Resistente: 0.6,
  };

  // Tabela 3 simplificada para correção (Insulina Regular/Aspart/Glulisina/Lispro)
  // Valores são UI de correção para cada faixa de glicemia (mg/dl)
  // A tabela real é mais complexa e depende da sensibilidade, mas para o protótipo
  // usaremos uma simplificação com base na lógica de correção progressiva.
  static const Map<int, int> _correctionDoseTable = {
    // Glicemia (mg/dl) : Dose de Correção (UI)
    181: 2, // 181-250
    251: 4, // 251-350
    351: 6, // > 350
  };

  // Função para arredondar a dose de insulina para o número inteiro mais próximo.
  // A regra de arredondamento é para números pares (2/2) ou inteiros (1/1).
  // Para o protótipo, usaremos o arredondamento para o inteiro mais próximo.
  static int _roundDose(double dose) {
    return dose.round();
  }

  // 1. Cálculo da Dose Total Diária (DTD) de Insulina
  static double calculateTDD(Patient patient, InsulinSensitivity sensitivity) {
    final factor = _sensitivityFactors[sensitivity] ?? 0.4; // Default para usual
    return patient.weight * factor;
  }

  // 2. Cálculo da Dose Basal
  static int calculateBasalDose(double tdd) {
    // Metade da DTD deve ser usada na insulina basal (0.1 a 0.3 UI/Kg/dia)
    // Se a DTD foi calculada com 0.2-0.6, a basal será 0.1-0.3, o que está correto.
    return _roundDose(tdd / 2.0);
  }

  // 3. Cálculo da Dose Bôlus (Pré-prandial)
  static int calculateBolusDose(double tdd) {
    // Os bôlus de insulina de ação rápida devem ser 50% da DTD, divididos em 3 doses iguais (café, almoço, jantar).
    final bolusTotal = tdd / 2.0;
    // Dividido por 3 para obter a dose pré-prandial
    return _roundDose(bolusTotal / 3.0);
  }

  // 4. Cálculo da Dose de Correção
  static int calculateCorrectionDose(int currentGlucose) {
    if (currentGlucose <= 180) {
      return 0;
    }
    // Encontra a dose de correção na tabela
    for (final entry in _correctionDoseTable.entries) {
      if (currentGlucose >= entry.key) {
        return entry.value;
      }
    }
    // Caso a glicemia seja muito alta, retorna a dose máxima da tabela
    return _correctionDoseTable.values.last;
  }

  // 5. Geração da Prescrição Sugerida (Texto)
  static String generatePrescription(
    Patient patient,
    InsulinSensitivity sensitivity,
    DietStatus dietStatus,
    int currentGlucose,
    String observations, // Novo parâmetro
  ) {
    final tdd = calculateTDD(patient, sensitivity);
    final basalDose = calculateBasalDose(tdd);
    final isBasalBolus = dietStatus == DietStatus.DietaOral;
    final bolusDose = isBasalBolus ? calculateBolusDose(tdd) : 0;
    // final correctionDose = calculateCorrectionDose(currentGlucose); // Variável não utilizada na geração da string

    final buffer = StringBuffer();

    // 1. Dieta
    buffer.writeln('**1. Dieta:** Dieta para diabético.');

    // 2. Monitorização da Glicemia Capilar
    buffer.writeln('\n**2. Monitorização da Glicemia Capilar:**');
    if (dietStatus == DietStatus.DietaOral) {
      buffer.writeln('   - Antes do café (AC), do almoço (AA) e do jantar (AJ) e às 22 horas.');
    } else {
      buffer.writeln('   - 6/6 horas (opcional de 4/4 horas).');
    }

    // 3. Insulina Basal (NPH como padrão)
    buffer.writeln('\n**3. Insulina Basal (NPH - Padrão HRAV):**');
    buffer.writeln('   - Insulina NPH SC - $basalDose UI. (Dividir em 3 doses iguais: 6h, 11h e 22h, ou 2/3 às 6h e 1/3 às 22h, conforme orientação médica).');

    // 4. Insulina Rápida (Bôlus/Correção)
    buffer.writeln('\n**4. Insulina Rápida (Regular/Aspart/Glulisina/Lispro):**');
    if (isBasalBolus) {
      buffer.writeln('   - **Bôlus Pré-prandial:** $bolusDose UI SC antes do café, almoço e jantar.');
      buffer.writeln('   - **Correção (AC, AA, AJ):** Aplicar dose de correção conforme tabela abaixo, somada à dose de bôlus, *se a glicemia estiver acima de 180 mg/dl*.');
    } else {
      buffer.writeln('   - **Correção (6/6h ou 4/4h):** Aplicar dose de correção conforme tabela abaixo, *se a glicemia estiver acima de 180 mg/dl*.');
    }

    // Tabela de Correção
    buffer.writeln('\n**Tabela de Correção (Insulina Rápida - UI):**');
    buffer.writeln('| Glicemia (mg/dl) | Dose de Correção (UI) |');
    buffer.writeln('|:----------------:|:---------------------:|');
    _correctionDoseTable.forEach((glicemia, dose) {
      final range = glicemia == 181 ? '181 - 250' : glicemia == 251 ? '251 - 350' : '> 350';
      buffer.writeln('| $range | $dose |');
    });

    // 5. Orientações para Hipoglicemia
    buffer.writeln('\n**5. Orientações para Hipoglicemia (< 70 mg/dl):**');
    buffer.writeln('   - Se paciente consciente e capaz de deglutir: Oferecer 30 ml de glicose 50% (ou alimento líquido açucarado).');
    buffer.writeln('   - Se inconsciente ou incapaz de deglutir: Aplicar 30 ml de glicose 50% IV em veia calibrosa.');
    buffer.writeln('   - Repetir glicemia e administração de glicose a cada 15 minutos até glicemia > 100 mg/dl.');

    // 6. Orientação para Glicemia das 22h
    buffer.writeln('\n**6. Orientação para Glicemia das 22 horas:**');
    buffer.writeln('   - Abaixo de 100: Oferecer lanche.');
    buffer.writeln('   - 100 a 250: 0 UI.');
    buffer.writeln('   - 251 a 350: Aplicar 2 UI de Insulina Regular SC.');
    buffer.writeln('   - 351 ou acima: Aplicar 4 UI de Insulina Regular SC.');

    // 7. Observações do Médico
    if (observations.isNotEmpty) {
      buffer.writeln('\n**7. Observações do Médico:**');
      buffer.writeln('   - $observations');
    }

    // Aviso de isenção de responsabilidade
    buffer.writeln('\n---\n**AVISO IMPORTANTE:** Este é um protótipo acadêmico. As sugestões são meramente orientadoras e devem ser individualizadas pelo médico. Não possui validade clínica ou regulatória.');

    return buffer.toString();
  }
}

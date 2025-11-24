# InsuGuia Mobile - Protótipo Acadêmico

## Visão Geral

Este repositório contém o protótipo do aplicativo móvel **InsuGuia Mobile**, desenvolvido em **Flutter** como projeto de extensão da disciplina de Desenvolvimento para Plataformas Móveis do curso de Bacharelado em Sistemas de Informação da UNIDAVI.

O objetivo do projeto é servir como uma **prova de conceito funcional** para uma ferramenta digital de apoio ao manejo da hiperglicemia hospitalar em pacientes não-críticos, baseada nas diretrizes da Sociedade Brasileira de Diabetes (SBD).

**AVISO IMPORTANTE:** Este é um protótipo acadêmico, sem validade clínica ou regulatória. As sugestões de prescrição geradas são meramente orientadoras e não substituem a decisão e o julgamento médico.

## Escopo e Funcionalidades Implementadas

O protótipo foca no cenário de **"Paciente Não Crítico"** e inclui as seguintes funcionalidades:

1.  **Cadastro de Paciente:** Permite a inserção de dados essenciais para o cálculo, como:
    *   Nome
    *   Peso (kg)
    *   Altura (cm)
    *   Creatinina sérica
    *   Idade (anos)
    *   Sexo
    *   Etnia
2.  **Cálculos Automáticos:**
    *   **Índice de Massa Corporal (IMC)**.
    *   **Taxa de Filtração Glomerular (TFG)**, calculada pelo score CKD-EPI, utilizando os dados de creatinina, idade, sexo e etnia.
3.  **Geração de Prescrição Sugerida:** Com base nas regras de negócio fornecidas pelo Dr. Itairan da Silva Terres, o aplicativo calcula e sugere:
    *   **Dose Total Diária (DTD)** de insulina, ajustada pela sensibilidade (Sensível, Usual, Resistente).
    *   **Dose Basal** (NPH).
    *   **Dose Bôlus** (Insulina Rápida), se o paciente estiver em dieta oral.
    *   **Tabela de Correção** (Insulina Rápida).
    *   **Orientações para Hipoglicemia e Glicemia das 22h**.
4.  **Módulos Simulados:** Acompanhamento Diário e Orientações de Alta são módulos navegáveis, mas com funcionalidade simulada (placeholders), conforme o escopo acadêmico inicial.

## Estrutura do Projeto

O projeto segue a estrutura padrão de um aplicativo Flutter, com foco na separação de responsabilidades:

| Diretório/Arquivo | Conteúdo |
| :--- | :--- |
| `lib/main.dart` | Ponto de entrada do aplicativo e definição do tema. |
| `lib/models/patient_model.dart` | Modelo de dados do paciente, incluindo a lógica de cálculo de IMC e TFG (CKD-EPI). |
| `lib/models/enums.dart` | Definições de enums para `InsulinSensitivity` e `DietStatus`. |
| `lib/services/insulin_calculator.dart` | Contém a **lógica de negócio** para o cálculo da DTD, doses de insulina (basal, bôlus, correção) e a formatação da prescrição sugerida. |
| `lib/screens/patient_list_screen.dart` | Tela inicial com a lista de pacientes e navegação para cadastro/detalhes. |
| `lib/screens/add_edit_patient_screen.dart` | Formulário para cadastro de novos pacientes. |
| `lib/screens/patient_detail_screen.dart` | Exibe os dados do paciente, IMC, TFG e botões de ação. |
| `lib/screens/prescription_screen.dart` | Tela de inputs para glicemia e status de dieta, e exibição da prescrição sugerida. |

## Como Rodar o Protótipo

1.  **Pré-requisitos:** Certifique-se de ter o Flutter SDK (versão 3.19.6 ou superior) instalado e configurado.
2.  **Clonar o Repositório:**
    ```bash
    git clone [LINK DO REPOSITÓRIO]
    cd Insuguia/insuguia
    ```
3.  **Instalar Dependências:**
    ```bash
    flutter pub get
    ```
4.  **Rodar o Aplicativo:**
    ```bash
    flutter run -d linux # ou o dispositivo desejado (web, android, etc.)
    ```

## Próximos Passos (Sugestões para Continuidade)

*   Implementar a lógica completa de **Acompanhamento Diário**, permitindo o ajuste da dose basal/bôlus com base nas glicemias do dia anterior.
*   Refinar a **Tabela de Correção** para que seja dinâmica e baseada na sensibilidade do paciente, conforme as diretrizes da SBD.
*   Adicionar persistência de dados (e.g., usando `shared_preferences` ou `sqflite`) para que os pacientes e prescrições sejam salvos entre as sessões.
*   Melhorar a interface do usuário (UI) e a experiência do usuário (UX).

---
*Desenvolvido por Manus AI para o Projeto de Extensão UNIDAVI - Sistemas de Informação.*

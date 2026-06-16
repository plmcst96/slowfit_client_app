import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import 'exercise_provider.dart';

bool isValidJson(String input) {
  try {
    jsonDecode(input);
    return true;
  } catch (e) {
    print("Errore nel parsing JSON: $e");
    return false;
  }
}

String sanitizeJsonContent(String content) {
  content = content.replaceAll(RegExp(r'```json\n?'), '');
  content = content.replaceAll(RegExp(r'\n?```'), '');
  content = content.replaceAll(RegExp(r'":\s*},'), '": ""},');
  content = content.replaceAll(RegExp(r',\s*}\s*}'), '}');
  content = content.replaceAll(RegExp(r'"esercizio":\s*{'), '"esercizio": {}');
  content = content.replaceAll(RegExp(r'"esercizio":\s*{}\s*"exerciseId":'),
      '"esercizio": {}, "exerciseId":');
  if (!content.endsWith('}')) content += '}';
  if (!content.endsWith(']')) content += ']';
  return content;
}

Future<http.Response> sendOpenAIRequestWithRetry({
  required Uri url,
  required Map<String, String> headers,
  required String body,
  required List<String> models,
  int maxRetries = 5,
}) async {
  final random = Random();
  int retryCount = 0;
  int modelIndex = 0;

  while (true) {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 429) {
      retryCount++;
      if (retryCount > maxRetries) {
        if (modelIndex < models.length - 1) {
          modelIndex++;
          print("🔁 Cambio modello: ${models[modelIndex]}");
          final newBody = jsonDecode(body);
          newBody["model"] = models[modelIndex];
          body = jsonEncode(newBody);
          retryCount = 0; // reset retry per nuovo modello
          continue;
        } else {
          throw Exception('Troppe richieste a OpenAI. Riprova più tardi.');
        }
      }

      final waitTime = pow(2, retryCount).toInt() + random.nextInt(3);
      print(
          '🟠 Rate limit. Attendo $waitTime secondi... (tentativo $retryCount)');
      await Future.delayed(Duration(seconds: waitTime));
    } else {
      return response;
    }
  }
}

final trainingRequestProvider =
    FutureProvider.family<Map<String, dynamic>, int>(
        (ref, typeTrainingId) async {
  print("➡️ Eseguo richiesta OpenAI per typeTrainingId: $typeTrainingId");

  // 1. Recupera esercizi dal backend
  await ref.read(exerciseProvider.notifier).getExercise(typeTrainingId);
  final exerciseList = ref.read(exerciseProvider);

  // 2. Mappa esercizi
  final exerciseMap = {
    for (var e in exerciseList)
      e.name: {
        "exerciseId": e.exerciseId,
        "name": e.name,
      }
  };

  // 3. JSON leggibile
  final availableExercisesJson =
      const JsonEncoder.withIndent('  ').convert(exerciseMap);

  // 4. Prompt
  final prompt = '''
Crea un piano di allenamento per il gruppo muscolare "$typeTrainingId", suddiviso in 3 livelli di difficoltà:

- Principiante (3-4 esercizi per fase)
- Intermedio (4-6 esercizi per fase)
- Avanzato (4-6 esercizi per fase)

Ogni livello dovrà essere suddiviso nelle seguenti fasi:

1. Riscaldamento (3-4 esercizi)
2. Allenamento (4-6 esercizi)
3. Stretching (3-4 esercizi)

La struttura finale del piano dovrà essere la seguente:

{
  "Principiante": {
    "riscaldamento": [
      {"esercizio": {...}, "serie": ..., "ripetizioni": ..., "recupero": ...},
      ...
    ],
    "allenamento": [...],
    "stretching": [...]
  },
  "Intermedio": { ... },
  "Avanzato": { ... }
}

Puoi usare solo questi esercizi (nome → oggetto JSON):

$availableExercisesJson

Ogni esercizio nel piano deve essere nel formato:
{
  "esercizio": oggetto JSON corrispondente (copia dalla mappa sopra),
  "serie": numero intero,
  "ripetizioni": numero intero,
  "recupero": numero intero (secondi)
}

Genera solo il JSON, senza commenti. Racchiudi il risultato in un blocco ```json
''';

  // 5. Parametri richiesta
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${AppConfig.chatGptKey}',
  };

  final models = [
    "gpt-4o-2024-08-06",
    "gpt-3.5-turbo-0125",
  ];

  final bodyMap = {
    "model": models[0],
    "messages": [
      {"role": "user", "content": prompt}
    ],
    "max_tokens": 4096,
    "temperature": 1,
  };

  // 6. Invio richiesta con retry
  final response = await sendOpenAIRequestWithRetry(
    url: url,
    headers: headers,
    body: jsonEncode(bodyMap),
    models: models,
  );

  print("✅ Risposta OpenAI ricevuta: ${response.statusCode}");

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    final content = decoded['choices'][0]['message']['content'];

    if (content.isEmpty) {
      print('❌ La risposta di OpenAI è vuota.');
      throw Exception('Risposta vuota da OpenAI');
    }

    final sanitizedContent = sanitizeJsonContent(content);

    if (isValidJson(sanitizedContent)) {
      final finalResponse = jsonDecode(sanitizedContent);
      return finalResponse;
    } else {
      print("❌ JSON malformato dopo sanitizzazione:");
      print(sanitizedContent);
      throw Exception('JSON malformato dopo sanitizzazione.');
    }
  } else {
    print('❌ Errore nella richiesta OpenAI: ${response.statusCode}');
    print('📦 Body: ${response.body}');
    throw Exception('Errore nella richiesta OpenAI: ${response.statusCode}');
  }
});

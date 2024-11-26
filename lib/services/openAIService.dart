import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:diet_management_suppport_app/utills/openAIApiKey.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];
  final FlutterTts _flutterTts = FlutterTts(); // Inicjalizacja TTS

  OpenAIService() {
    // Ustawienia dla TTS
    _flutterTts.setLanguage("pl-PL");
    _flutterTts.setPitch(1.0); // Ustawienie tonacji
  }

  Future<String> chatGPTAPI(String prompt) async {
    // Shadow prompt - dopisywany do każdego zapytania
    const shadowPrompt =
        "Jeśli pytanie nie dotyczy diety lub zdrowego stylu życia odpowiedz "
        "\"Przepraszam nie znam odpowiedzi na to pytanie, gdyż moja wiedza "
        "ogranicza się do zagadnień dotyczących zdrowego stylu życia oraz diety\"";

    // Dodanie shadow prompta do prompta użytkownika
    final modifiedPrompt = "$prompt\n\n$shadowPrompt";

    messages.add({
      'role': 'user',
      'content': modifiedPrompt,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8', // Dodaj kodowanie
          'Authorization': 'Bearer $openAiAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        // Dekoduj odpowiedź jako UTF-8
        String content = utf8.decode(res.bodyBytes); // Użycie utf8.decode
        content = jsonDecode(content)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });

        // Odczytanie odpowiedzi AI
        await _speak(content);
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop(); // Zatrzymaj odczyt
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:diet_management_suppport_app/services/openAIService.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final OpenAIService _openAIService = OpenAIService();
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Tap the mic to speak';
  List<Map<String, String>> _messages = [];
  Timer? _sendMessageTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpeechToText();
  }

  Future<void> _initializeSpeechToText() async {
    bool initialized = await _speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );
    if (!initialized) {
      print('Speech recognition not available.');
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              _controller.text = _text;
            });

            _resetSendMessageTimer();
          },
          listenFor: Duration(seconds: 10),
          pauseFor: Duration(seconds: 2),
          partialResults: true,
        );
      } else {
        print("Speech recognition not available.");
      }
    } else {
      _stopListening();
    }
  }

  void _resetSendMessageTimer() {
    _sendMessageTimer?.cancel();
    _sendMessageTimer = Timer(Duration(seconds: 2), () {
      _sendMessage();
    });
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
    _sendMessageTimer?.cancel();
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({'role': 'user', 'content': text});
      });
      _controller.clear();

      final response = await _openAIService.chatGPTAPI(text);
      print('Response from OpenAI: $response');

      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
    }
  }

  void _stopSpeaking() async {
    await _openAIService.stopSpeaking(); // Zatrzymanie mówienia
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with GPT'),
        backgroundColor: const Color.fromARGB(255, 98, 221, 16),
        actions: [
          IconButton(
            icon: Icon(Icons.stop), // Przycisk do zatrzymania mówienia
            color: const Color.fromARGB(255, 181, 90, 204),
            onPressed: _stopSpeaking,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isUserMessage = message['role'] == 'user';

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.deepPurple[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['content'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: const Color.fromARGB(255, 98, 221, 16),
                  onPressed: _sendMessage,
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                  color: Colors.deepPurple,
                  onPressed: _listen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _sendMessageTimer?.cancel();
    super.dispose();
  }
}

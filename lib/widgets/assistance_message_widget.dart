import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class AssistantMessageWidget extends StatefulWidget {
  const AssistantMessageWidget({
    super.key,
    required this.message,
  });

  final String message;

  @override
  _AssistantMessageWidgetState createState() => _AssistantMessageWidgetState();
}

class _AssistantMessageWidgetState extends State<AssistantMessageWidget> {
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  String apiKey = "AIzaSyCL8kAToRhMewFqUEOdw0QhRw3rhrmATCw";
  bool _isPlaying = false;
  bool _hasPlayedAudio = false; // Nueva bandera para evitar múltiples reproducciones
  final msg = Logger();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _audioPlayer.openPlayer();
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _speak(String text) async {
    if (_hasPlayedAudio || text.isEmpty) return; // Evita múltiples ejecuciones
    _hasPlayedAudio = true; // Marca que ya se ejecutó

    msg.w('Text to speech: $text');

    final url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'input': {'text': text},
        'voice': {
          'languageCode': 'en-US',
          'name': 'en-US-Wavenet-D',
          'ssmlGender': 'MALE',
        },
        'audioConfig': {
          'audioEncoding': 'MP3',
        },
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final audioContent = responseData['audioContent'];
      final audioBytes = base64Decode(audioContent);
      final tempFile = File('${Directory.systemTemp.path}/speech.mp3');
      await tempFile.writeAsBytes(audioBytes);
      await _playAudio(tempFile.path);
    } else {
      print('Error: ${response.statusCode}');
      print(response.body);
    }
  }

  Future<void> _playAudio(String path) async {
    if (_audioPlayer.isPlaying) return; // Evita iniciar si ya está reproduciendo

    try {
      await _audioPlayer.startPlayer(
        fromURI: path,
        codec: Codec.mp3,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
          print("Reproducción finalizada");
        },
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print("Error al reproducir audio: $e");
    }
  }

  Future<void> _stopAudio() async {
    if (_audioPlayer.isPlaying) {
      await _audioPlayer.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer();
    super.dispose();
  }

  Future<void> _waitAndSpeak() async {
    // Espera hasta que el mensaje esté completo o tenga sentido enviarlo.
    await Future.delayed(const Duration(milliseconds: 7000)); // Ajusta el tiempo según sea necesario.

    if (widget.message.isNotEmpty && !_hasPlayedAudio) {
      _speak(widget.message); // Llama a _speak solo una vez.
      setState(() {
        _hasPlayedAudio = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.isNotEmpty && !_hasPlayedAudio) {
      _waitAndSpeak(); // Llama a _speak solo una vez
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: widget.message.isEmpty
            ? const SizedBox(
                width: 50,
                child: SpinKitThreeBounce(
                  color: Color.fromARGB(255, 129, 131, 133),
                  size: 20.0,
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: MarkdownBody(
                      selectable: true,
                      data: widget.message,
                    ),
                  ),
                  if (!_isPlaying)
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _speak(widget.message),
                      tooltip: 'Hablar',
                    ),
                  if (_isPlaying)
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: _stopAudio,
                      tooltip: 'Detener',
                    ),
                ],
              ),
      ),
    );
  }
}

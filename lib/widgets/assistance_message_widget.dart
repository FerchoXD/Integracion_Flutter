import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isPlaying = false; // Estado para saber si está reproduciendo

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _audioPlayer.openPlayer(); // Abrimos el reproductor en initState
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;

    final url = 'https://texttospeech.googleapis.com/v1/text:synthesize?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'input': {'text': text},
        'voice': {
          'languageCode': 'es-ES',
          'name': 'es-ES-Wavenet-B',
          'ssmlGender': 'MALE'
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
    await _audioPlayer.startPlayer(
      fromURI: path,
      codec: Codec.mp3,
      whenFinished: () {
        setState(() {
          _isPlaying = false; // Actualizamos el estado al finalizar
        });
        print("Reproducción finalizada");
      },
    );
    setState(() {
      _isPlaying = true; // Actualizamos el estado al iniciar
    });
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stopPlayer(); // Detenemos el reproductor
    setState(() {
      _isPlaying = false; // Actualizamos el estado al detener
    });
  }

  @override
  void dispose() {
    _audioPlayer.closePlayer(); // Cerramos el reproductor después de matar al widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: _stopAudio, // Llama al método para detener
                      tooltip: 'Detener',
                    ),
                ],
              ),
      ),
    );
  }
}

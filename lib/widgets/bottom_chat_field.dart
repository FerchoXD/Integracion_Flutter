import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/main.dart';
import 'package:flutter_gemini/providers/chat_provider.dart';
import 'package:flutter_gemini/utility/utilites.dart';
import 'package:flutter_gemini/widgets/preview_images_widget.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; 

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.chatProvider,
  });

  final ChatProvider chatProvider;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  final TextEditingController textController = TextEditingController();
  final FocusNode textFieldFocus = FocusNode();
  final ImagePicker _picker = ImagePicker();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;
  bool _isConnected = true; // Variable para controlar la conexión a internet
  final FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool get hasImages => widget.chatProvider.imagesFileList != null &&
      widget.chatProvider.imagesFileList!.isNotEmpty;

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none]; // Cambiado a una lista
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText(); 
    initConnectivity();
  
    // Escuchar cambios en la conectividad
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); // Cancelar la suscripción al salir
    super.dispose();
  }

  // Método para inicializar la conectividad
  Future<void> initConnectivity() async {
    try {
      var result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result); // Envolver en una lista
    } on PlatformException catch (e) {
      print('Error checking connectivity: $e');
      return;
    }
  }

  // Actualizar el estado de la conexión
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    setState(() {
      _connectionStatus = results;
      _isConnected = results.any((result) => result != ConnectivityResult.none);
    });
    print('Connectivity changed: $_connectionStatus');
  }

  Future<void> _checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }
  Future<void> _startListening() async {
    if (!_isConnected) {
      _showNoInternetSnackbar();
      return;
    }

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      _checkMicrophonePermission();
      return;
    }

    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (val) async {
        if (val.finalResult && val.recognizedWords.isNotEmpty) {
          bool hasImages = widget.chatProvider.imagesFileList != null &&
              widget.chatProvider.imagesFileList!.isNotEmpty;

          await sendChatMessage(
            message: val.recognizedWords,
            chatProvider: widget.chatProvider,
            isTextOnly: !hasImages,
          );

          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }
        }
      });
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
    await _speech.stop();
  }

  Future<void> sendChatMessage({
    required String message,
    required ChatProvider chatProvider,
    required bool isTextOnly,
  }) async {
    if (!_isConnected) {
      _showNoInternetSnackbar(); // Mostrar Snackbar si no hay conexión
      return;
    }

    try {
      await chatProvider.sentMessage(
        message: message,
        isTextOnly: isTextOnly,
      );
    } catch (e) {
      log('error : $e');
    } finally {
      textController.clear();
      widget.chatProvider.setImagesFileList(listValue: []);
      textFieldFocus.unfocus();
    }
  }

  void pickImage() async {
    if (!_isConnected) {
      _showNoInternetSnackbar(); // Mostrar Snackbar si no hay conexión
      return;
    }

    try {
      final pickedImages = await _picker.pickMultiImage(
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      widget.chatProvider.setImagesFileList(listValue: pickedImages);
    } catch (e) {
      log('error : $e');
    }
  }
void _showNoInternetSnackbar() {
  if (navigatorKey2.currentContext != null) {
    ScaffoldMessenger.of(navigatorKey2.currentContext!).showSnackBar(
      const SnackBar(
        content: Text('No hay conexión a internet.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    bool hasImages = widget.chatProvider.imagesFileList != null &&
        widget.chatProvider.imagesFileList!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Theme.of(context).textTheme.titleLarge!.color!,
        ),
      ),
      child: Column(
        children: [
          if (hasImages) const PreviewImagesWidget(),
          Row(
            children: [
              IconButton(
                onPressed: _isConnected ? () {
                  if (hasImages) {
                    showMyAnimatedDialog(
                      context: context,
                      title: 'Eliminar imágenes',
                      content: '¿Estás seguro de que quieres eliminar las imágenes?',
                      actionText: 'Eliminar',
                      onActionPressed: (value) {
                        if (value) {
                          widget.chatProvider.setImagesFileList(listValue: []);
                        }
                      },
                    );
                  } else {
                    pickImage();
                  }
                } : null,
                icon: Icon(hasImages ? Icons.delete_forever : Icons.image),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: TextField(
                  focusNode: textFieldFocus,
                  controller: textController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _isConnected && !widget.chatProvider.isLoading
                      ? (String value) {
                          if (value.isNotEmpty) {
                            sendChatMessage(
                              message: textController.text,
                              chatProvider: widget.chatProvider,
                              isTextOnly: hasImages ? false : true,
                            );
                          }
                        }
                      : null,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Ingresa tu mensaje...',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isConnected
                      ? (_isListening
                          ? const Color.fromARGB(255, 59, 59, 59)
                          : const Color.fromARGB(255, 58, 183, 58))
                      : Colors.grey, 
                ),
                child: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: _isConnected ? (_isListening ? _stopListening : _startListening) : null,
                ),
              ),

              GestureDetector(
                onTap: _isConnected && !widget.chatProvider.isLoading
                    ? () {
                        if (textController.text.isNotEmpty) {
                          sendChatMessage(
                            message: textController.text,
                            chatProvider: widget.chatProvider,
                            isTextOnly: hasImages ? false : true,
                          );
                        }
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: _isConnected
                        ? const Color.fromARGB(255, 58, 183, 58)
                        : Colors.grey, // Cambiar el color si no hay conexión
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.all(5.0),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

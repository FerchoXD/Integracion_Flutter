import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/hive/boxes.dart';
import 'package:flutter_gemini/hive/settings.dart';
import 'package:flutter_gemini/providers/settings_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userImage = 'assets/images/logo.png';  // Imagen estática desde assets
  String userName = 'Fernando Daniel Pérez Pérez';

  void getUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBox = Boxes.getUser();

      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0);
        setState(() {
          userImage = user!.name;
          userName = user.image;
        });
      }
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Datos personales'),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20.0),

                // user name
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(userName, style: Theme.of(context).textTheme.titleLarge),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage(userImage),
                  ),
                ),
                Text("Universidad Politecnica de Chiapas", style: Theme.of(context).textTheme.titleMedium),
                Text("Ingenieria en Software", style: Theme.of(context).textTheme.titleMedium),
                Text("Programación para moviles II", style: Theme.of(context).textTheme.titleMedium),
                Text("Grupo: A", style: Theme.of(context).textTheme.titleMedium),
                Text("213524", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20.0),
                _buildGitHubButton(context),
                const Divider(),

                const SizedBox(height: 20.0),

                ValueListenableBuilder<Box<Settings>>(
                    valueListenable: Boxes.getSettings().listenable(),
                    builder: (context, box, child) {
                      if (box.isEmpty) {
                        return Column(
                          children: [
                            const Text('Elige un Tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                            RadioListTile<bool>(
                              title: const Text("Light Theme"),
                              value: false,  // Tema claro
                              groupValue: false,  // Como la caja está vacía, asumimos tema claro por defecto
                              onChanged: (value) {
                                final settingProvider = context.read<SettingsProvider>();
                                settingProvider.toggleDarkMode(value: value ?? false);
                              },
                            ),

                            RadioListTile<bool>(
                              title: const Text("Dark Theme"),
                              value: true,  // Tema oscuro
                              groupValue: false,  // Tema claro por defecto
                              onChanged: (value) {
                                final settingProvider = context.read<SettingsProvider>();
                                settingProvider.toggleDarkMode(value: value ?? false);
                              },
                            ),
                          ],
                        );
                      } else {
                        final settings = box.getAt(0);
                        return Column(
                          children: [
                            const Text('Elige un Tema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                            RadioListTile<bool>(
                              title: const Text("Light Theme"),
                              value: false,  // Tema claro
                              groupValue: settings?.isDarkTheme,  
                              onChanged: (value) {
                                final settingProvider = context.read<SettingsProvider>();
                                settingProvider.toggleDarkMode(value: value ?? false);
                              },
                            ),

                            RadioListTile<bool>(
                              title: const Text("Dark Theme"),
                              value: true,  // Tema oscuro
                              groupValue: settings?.isDarkTheme,  
                              onChanged: (value) {
                                final settingProvider = context.read<SettingsProvider>();
                                settingProvider.toggleDarkMode(value: value ?? false);
                              },
                            ),
                          ],
                        );
                      }
                    })
              ],
            ),
          ),
        ));
  }
}

Widget _buildGitHubButton(BuildContext context) {
  return IconButton(
    icon: const FaIcon(FontAwesomeIcons.github, size: 40),
    color: const Color.fromARGB(255, 58, 183, 58),
    onPressed: () async {
      final Uri url = Uri.parse('https://github.com/FerchoXD/Chatbot_with_Gemini_Flutter');

      try {
        // Usa launchUrl sin el chequeo previo
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        // Aquí puedes registrar el error para depuración
        log('Error al abrir el enlace: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el enlace: $e')),
        );
      }
    },
  );
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Importa el paquete
import '../services/settings_service.dart';
import 'package:another_flushbar/flushbar.dart';
import 'main_screen.dart';

class PinLoginScreen extends StatefulWidget {
  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    // Inicializa el controlador con un video de assets
    _videoController = VideoPlayerController.asset('assets/videos/video.mp4')
      ..initialize().then((_) {
        setState(() {}); // Actualiza el estado cuando el video está listo
        _videoController.play();
        _videoController.setLooping(true);
        _videoController.setVolume(0);
      });
  }

  @override
  void dispose() {
    _videoController.dispose(); // Libera los recursos del controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    return Scaffold(
      // Extendemos el body para cubrir toda la pantalla
      body: Stack(
        children: [
          // Video de fondo
          _videoController.value.isInitialized
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      // Toma las dimensiones de la pantalla completa
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                )
              : Container(
                  color: colorFondo), // Fallback si el video no está listo

          // Imagen centrada
          Positioned(
            top: MediaQuery.of(context).size.height *
                0.25, // Ajusta este valor según necesites
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                'assets/images/fondo.png',
                width: MediaQuery.of(context).size.width *
                    0.8, // Ajusta al 80% del ancho
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Superposición con opacidad (puedes ajustar la opacidad aquí)
          Container(
            color: Colors.black.withOpacity(0.3), // 30% de opacidad
          ),

          // Contenido de la pantalla
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 600),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.25), // Fondo semi-transparente
                  borderRadius: BorderRadius.circular(16), // Bordes redondeados
                ),
                padding: EdgeInsets.all(16), // Espaciado interno
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Introducir PIN",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Introduce tu PIN",
                        labelStyle: TextStyle(
                          color: Colors
                              .white, // Cambia el color de la etiqueta a blanco
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.white, // Color del borde por defecto
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors
                                .white, // Color del borde cuando está habilitado
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors
                                .white, // Color del borde cuando está enfocado
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white
                            .withOpacity(0.8), // Fondo semitransparente
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      onPressed: () async {
                        final enteredPin = _pinController.text;
                        final savedPin = await SettingsService.getPin();

                        if (enteredPin == savedPin) {
                          // PIN correcto -> pasa al MainScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => MainScreen()),
                          );
                        } else {
                          final flush = Flushbar(
                            duration: Duration(seconds: 2),
                            borderRadius: BorderRadius.circular(8),
                            margin: EdgeInsets.all(16),
                            flushbarPosition: FlushbarPosition.TOP,
                            dismissDirection: FlushbarDismissDirection.VERTICAL,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[850]!
                                    : Colors.grey[200]!,
                            messageText: Text(
                              "PIN incorrecto",
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                          flush.show(context);
                        }
                      },
                      child: Text(
                        "Acceder",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

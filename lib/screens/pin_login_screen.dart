import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travify/services/settings_service.dart';
import 'package:video_player/video_player.dart';
import 'package:another_flushbar/flushbar.dart';
import 'main_screen.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
        _videoController.setVolume(0);
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  Future<void> _handlePinSubmit() async {
    final enteredPin = _pinController.text;
    final savedPin = await SettingsService.getPin();

    if (enteredPin == savedPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainScreen()),
      );
    } else {
      Flushbar(
        duration: Duration(seconds: 2),
        borderRadius: BorderRadius.circular(8),
        margin: EdgeInsets.all(16),
        flushbarPosition: FlushbarPosition.TOP,
        dismissDirection: FlushbarDismissDirection.VERTICAL,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]!
            : Colors.grey[200]!,
        messageText: Text(
          "incorrect_pin".tr(),
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // Oculta el teclado al tocar fuera
      child: Scaffold(
        body: Stack(
          children: [
            // Fondo de video
            _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : Container(color: colorFondo),

            // Imagen encima del video
            Positioned(
              top: MediaQuery.of(context).size.height * 0.00005,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  'assets/images/fondo.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Capa oscura encima del video
            Container(
              color: Colors.black.withOpacity(0.3),
            ),

            // Contenido interactivo
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment
                      .end, // Mantiene el contenido abajo pero flexible
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "input_pin".tr(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
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
                            controller: _pinController,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handlePinSubmit(),
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "input_your_pin".tr(),
                              labelStyle: TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: _handlePinSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                            ),
                            child: Text(
                              "go_in".tr(),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rive/rive.dart';

class RatingBear extends StatefulWidget {
  const RatingBear({super.key});

  @override
  State<RatingBear> createState() => _RatingBearState();
}

class _RatingBearState extends State<RatingBear> {
  Artboard?
  _artboard; // Guardar referencia al artboard para manipular el controlador
  StateMachineController? controller;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMITrigger? trigNeutral; // Trigger para estado neutral
  SMITrigger? reset; // Trigger para resetear/cancelar animaciones

  double _currentRating = 0;
  bool _hasRated = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Animación del oso
              SizedBox(
                width: size.width,
                height: 300,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  onInit: (artboard) {
                    _artboard = artboard;
                    controller = StateMachineController.fromArtboard(
                      artboard,
                      "Login Machine",
                    );
                    if (controller == null) return;
                    artboard.addController(controller!);
                    trigSuccess = controller!.findSMI('trigSuccess');
                    trigFail = controller!.findSMI('trigFail');
                    trigNeutral = controller!.findSMI('trigNeutral');
                    reset = controller!.findSMI('reset');

                    // Si no existe trigNeutral, buscar alternativas
                    if (trigNeutral == null) {
                      trigNeutral = controller!.findSMI('neutral');
                    }
                    if (trigNeutral == null) {
                      trigNeutral = controller!.findSMI('idle');
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // Título principal
              const SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "How was your experience?",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Subtítulo
              const SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Please share your opinion about the product",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Rating Bar
              RatingBar.builder(
                initialRating: _currentRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 8.0),
                itemSize: 40,
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) async {
                  setState(() {
                    _currentRating = rating;
                    _hasRated = true;
                  });

                  // Determinar el trigger a usar
                  int? nextAnim;
                  if (rating <= 2) {
                    nextAnim = 1; // fail
                  } else if (rating == 3) {
                    nextAnim = 2; // neutral
                  } else if (rating > 3) {
                    nextAnim = 3; // success
                  }

                  // Forzar reinicio del controlador para cancelar animación previa
                  if (_artboard != null && controller != null) {
                    _artboard!.removeController(controller!);
                    controller = StateMachineController.fromArtboard(
                      _artboard!,
                      "Login Machine",
                    );
                    if (controller != null) {
                      _artboard!.addController(controller!);
                      trigSuccess = controller!.findSMI('trigSuccess');
                      trigFail = controller!.findSMI('trigFail');
                      trigNeutral = controller!.findSMI('trigNeutral');
                      reset = controller!.findSMI('reset');
                      if (trigNeutral == null) {
                        trigNeutral = controller!.findSMI('neutral');
                      }
                      if (trigNeutral == null) {
                        trigNeutral = controller!.findSMI('idle');
                      }
                    }
                  }
                  await Future.delayed(const Duration(milliseconds: 10));

                  if (nextAnim == 1) {
                    trigFail?.fire();
                  } else if (nextAnim == 2) {
                    if (trigNeutral != null) {
                      trigNeutral?.fire();
                    } else {
                      reset?.fire();
                    }
                  } else if (nextAnim == 3) {
                    trigSuccess?.fire();
                  }

                  // _lastAnimation eliminado
                },
              ),

              const SizedBox(height: 16),

              // Texto que muestra el rating actual
              Text(
                _currentRating == 0
                    ? "Select your rating"
                    : "Your rating: $_currentRating",
                style: TextStyle(
                  fontSize: 16,
                  color: _currentRating == 0 ? Colors.grey : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // Botón Rate Now
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasRated
                      ? () {
                          // Acción al enviar el rating
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Thank you for your $_currentRating star rating!",
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "RATE NOW",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón No Thanks
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: null, // Sin función
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "NO THANKS",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

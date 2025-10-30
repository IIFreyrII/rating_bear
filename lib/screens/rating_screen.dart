import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:rive/rive.dart';

class RatingBear extends StatefulWidget {
  const RatingBear({super.key});

  @override
  State<RatingBear> createState() => _RatingBearState();
}

class _RatingBearState extends State<RatingBear> {
  StateMachineController? controller;
  SMITrigger? trigSuccess;
  SMITrigger? trigFail;
  SMITrigger? trigNeutral;
  SMITrigger? reset;

  double _currentRating = 0;
  bool _hasRated = false;
  Artboard? _artboard;

  // Timer para manejar la cancelación de animaciones
  Timer? _animationTimer;

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  void _cancelPreviousAnimation() {
    // Cancelar cualquier timer anterior
    _animationTimer?.cancel();

    // Forzar reset de la animación
    reset?.fire();

    // Pequeña pausa para asegurar el reset
    Future.delayed(const Duration(milliseconds: 16), () {
      // Opcional: agregar un trigger de idle o estado base si existe
    });
  }

  void _triggerAnimation(double rating) {
    _cancelPreviousAnimation();

    // Usar un timer para ejecutar la nueva animación después del reset
    _animationTimer = Timer(const Duration(milliseconds: 32), () {
      if (rating <= 2) {
        trigFail?.fire();
      } else if (rating == 3) {
        if (trigNeutral != null) {
          trigNeutral?.fire();
        } else {
          // Si no hay trigger neutral, mantener estado base
          reset?.fire();
        }
      } else {
        trigSuccess?.fire();
      }
    });
  }

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
                child: _artboard != null
                    ? Rive(artboard: _artboard!, fit: BoxFit.contain)
                    : RiveAnimation.asset(
                        'assets/animated_login_character.riv',
                        stateMachines: ["Login Machine"],
                        onInit: _onRiveInit,
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
                onRatingUpdate: (rating) {
                  setState(() {
                    _currentRating = rating;
                    _hasRated = true;
                  });

                  _triggerAnimation(rating);
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
                  onPressed: null,
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

  void _onRiveInit(Artboard artboard) {
    controller = StateMachineController.fromArtboard(artboard, "Login Machine");
    if (controller == null) return;

    artboard.addController(controller!);
    setState(() {
      _artboard = artboard;
    });

    // Buscar todos los posibles triggers
    trigSuccess = controller!.findSMI('trigSuccess');
    trigFail = controller!.findSMI('trigFail');
    trigNeutral = controller!.findSMI('trigNeutral');
    reset = controller!.findSMI('reset');

    // Si no encuentra reset, buscar alternativas
    if (reset == null) {
      reset = controller!.findSMI('trigReset');
    }
    if (reset == null) {
      reset = controller!.findSMI('idle');
    }

    // Debug: imprimir triggers encontrados
    print("Triggers encontrados:");
    print("Success: $trigSuccess");
    print("Fail: $trigFail");
    print("Neutral: $trigNeutral");
    print("Reset: $reset");
  }
}

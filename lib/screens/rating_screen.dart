import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';

class RatingBear extends StatefulWidget {
  const RatingBear({super.key});

  @override
  State<RatingBear> createState() => _RatingBearState();
}

class _RatingBearState extends State<RatingBear> {
  double _rating = 1;
  late RiveAnimationController _controller;
  Artboard? _riveArtboard;
  late StateMachineController? _stateMachineController;
  SMIInput<double>? _starsInput;
  SMITrigger? _failTrigger;
  SMITrigger? _neutralTrigger;
  SMITrigger? _successTrigger;

  @override
  void initState() {
    super.initState();
    _controller = SimpleAnimation('Idle');
    _loadRiveFile();
  }

  void _loadRiveFile() async {
    final data = await RiveFile.asset('assets/animated_login_character.riv');
    final artboard = data.mainArtboard;
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1', // Asegúrate de que el nombre coincide con el de tu archivo .riv
    );
    if (controller != null) {
      artboard.addController(controller);
      _stateMachineController = controller;
      _starsInput = controller.findInput<double>('stars');
      _failTrigger = controller.findInput<bool>('fail') as SMITrigger?;
      _neutralTrigger = controller.findInput<bool>('neutral') as SMITrigger?;
      _successTrigger = controller.findInput<bool>('success') as SMITrigger?;
      // Inicializar el estado
      _updateAnimation(_rating);
    }
    setState(() {
      _riveArtboard = artboard;
    });
  }

  void _updateAnimation(double rating) {
    if (_starsInput != null) {
      _starsInput!.value = rating;
    }
    // Cancelar animaciones previas
    _failTrigger?.reset();
    _neutralTrigger?.reset();
    _successTrigger?.reset();

    if (rating <= 2) {
      _failTrigger?.fire();
    } else if (rating == 3) {
      _neutralTrigger?.fire();
    } else if (rating >= 4) {
      _successTrigger?.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 24,
              offset: Offset(0, 12),
            )
          ],
        ),
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_riveArtboard != null)
              SizedBox(
                height: 160,
                child: Rive(
                  artboard: _riveArtboard!,
                  fit: BoxFit.contain,
                ),
              )
            else
              const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 16),
            const Text(
              "Enjoying Sounter?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xff2c3550),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "With how many stars do you rate your experience.\nTap a star to rate!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xff6b7588),
              ),
            ),
            const SizedBox(height: 14),
            IgnorePointer(
              ignoring: false,
              child: RatingStars(
                value: _rating,
                onValueChanged: (v) {
                  setState(() {
                    _rating = v;
                    _updateAnimation(v);
                  });
                },
                starCount: 5,
                starSize: 38,
                valueLabelVisibility: false,
                starColor: const Color(0xfff9c755),
                starOffColor: const Color(0xffd3d6db),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff6366f1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                onPressed: () {
                  // Acción Rate Now
                },
                child: const Text(
                  "Rate now",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Acción No Thanks
              },
              child: const Text(
                "NO THANKS",
                style: TextStyle(
                  color: Color(0xff6366f1),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.1
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
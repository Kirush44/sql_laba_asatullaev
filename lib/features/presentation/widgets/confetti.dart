import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class WeConfetti extends StatelessWidget {
    const WeConfetti({
    super.key,
    required this.controllerConfetti,
  });

  final ConfettiController controllerConfetti;


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: .center,
      child: ConfettiWidget(
        blastDirectionality: .explosive,
        shouldLoop: false,
        confettiController: controllerConfetti,
        blastDirection: pi / 2,
        emissionFrequency: 0.01,
        numberOfParticles: 30,
        maxBlastForce: 100,
        minBlastForce: 80,
        gravity: 0.3,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int score;

  ScoreDisplay(this.score);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Text(
        'Score: $score',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TextContainer extends StatelessWidget {
  const TextContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text(
          'No data found',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

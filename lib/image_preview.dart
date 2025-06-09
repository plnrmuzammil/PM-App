import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imageURL;
  const ImagePreview(this.imageURL, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(imageURL),
      ),
    );
  }
}

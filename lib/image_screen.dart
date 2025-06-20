import 'package:flutter/material.dart';

class ImageScreen extends StatelessWidget {
  final String? url;

  ImageScreen({
    Key? key,
    @required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Image(image: NetworkImage(url!),),
    );
  }
}
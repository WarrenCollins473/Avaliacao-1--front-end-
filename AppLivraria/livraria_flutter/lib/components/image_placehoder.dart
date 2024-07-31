import 'package:flutter/material.dart';

class ImagePlacehoder extends StatelessWidget {
  final String image;
  const ImagePlacehoder({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      fit: BoxFit.contain,
    );
  }
}

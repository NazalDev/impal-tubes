import 'package:flutter/material.dart';

class ImageShow extends StatelessWidget {
  final double width;
  final double height;
  const ImageShow({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/images/volync_logo.png',
      width: width,
      height: height,
      fit: BoxFit.fitHeight,
    );
  }
}

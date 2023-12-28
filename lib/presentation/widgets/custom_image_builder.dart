import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../styles/app_styles.dart';

// Custom Image Builder
Widget customImageBuilder(
    String url, Map<String, String> attributes, BuildContext context) {
  // Get screen size and orientation
  var screenSize = MediaQuery.of(context).size;
  var orientation = MediaQuery.of(context).orientation;

  // Decide image size based on orientation
  double imageWidth = orientation == Orientation.portrait
      ? screenSize.width
      : screenSize.height;

  return SizedBox(
    width: imageWidth,
    child: CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit
          .scaleDown, // Maintains aspect ratio and scales down if necessary
      placeholder: (context, url) => const SpinKitRing(
        color: kPinkD1,
      ), // Placeholder widget
      errorWidget: (context, url, error) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Icon(
              Icons.error,
              color: kWhite,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Failed loading image",
              style: TextStyle(color: kWhite),
            ),
          ],
        ),
      ), // Error widget
    ),
  );
}

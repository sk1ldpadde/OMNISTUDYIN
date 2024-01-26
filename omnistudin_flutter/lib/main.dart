import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'app.dart';

void main() {
  // This app is designed only to work vertically, so we limit
  // orientations to portrait up and down.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  return runApp(const OmniStudyingApp());
}

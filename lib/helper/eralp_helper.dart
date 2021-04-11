import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:flutter/material.dart';

class EralpHelper {
  static void startProgress() {
    Eralp.startProgress(
      maxSecond: 999,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void stopProgress() {
    Eralp.stopProgress();
  }
}

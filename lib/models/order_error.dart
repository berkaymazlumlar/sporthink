import 'package:flutter/material.dart';

class OrderError {
  final String firstBarcodeNumber;
  final String secondBarcodeNumber;
  final String errorReason;

  OrderError(
      {@required this.firstBarcodeNumber,
      this.secondBarcodeNumber,
      @required this.errorReason});
}

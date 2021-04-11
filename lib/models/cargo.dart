import 'package:flutter/material.dart';

class Cargo {
  final String assetImageUrl;
  final String cargoName;
  int partyNumber;

  Cargo({
    @required this.assetImageUrl,
    @required this.cargoName,
    @required this.partyNumber,
  });
}

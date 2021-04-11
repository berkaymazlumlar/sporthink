import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();

class CargoProvider with ChangeNotifier {
  List<int> _partyNumbers = [
    0,
    0,
    0,
    0,
    0,
    0,
  ];

  int getCargoPartyNumber(int index) {
    return _partyNumbers[index];
  }

  void setPartyNumber(int index, int number) {
    _partyNumbers[index] = number;
    notifyListeners();
  }
}

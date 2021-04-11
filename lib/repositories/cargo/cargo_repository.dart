import 'dart:core';

import 'package:sporthink/models/cargo.dart';

class CargoRepository {
  final List<Cargo> _cargoList = [
    Cargo(
      assetImageUrl: "assets/images/surat.jpg",
      cargoName: "Sürat Kargo",
      partyNumber: 0,
    ),
    Cargo(
      assetImageUrl: "assets/images/trendyol.png",
      cargoName: "Trendyol Express",
      partyNumber: 0,
    ),
    Cargo(
      assetImageUrl: "assets/images/yurtici.png",
      cargoName: "Yurtiçi Kargo",
      partyNumber: 0,
    ),
    Cargo(
      assetImageUrl: "assets/images/hepsijet.jpg",
      cargoName: "HepsiJet",
      partyNumber: 0,
    ),
    Cargo(
      assetImageUrl: "assets/images/aras.jpg",
      cargoName: "Aras Kargo",
      partyNumber: 0,
    ),
    Cargo(
      assetImageUrl: "assets/images/ptt.png",
      cargoName: "Ptt Kargo",
      partyNumber: 0,
    ),
  ];
  List<Cargo> get cargoList => _cargoList;

  int _choosedCargoIndex;
  int get choosedCargoIndex => _choosedCargoIndex;
  set choosedCargoIndex(int index) {
    _choosedCargoIndex = index;
    print("choosedCargoIndex setted to $index");
  }

  String getCargoName() {
    return cargoList[choosedCargoIndex].cargoName;
  }

  int getCargoPartyNumber() {
    return cargoList[choosedCargoIndex].partyNumber;
  }

  void setCargoPartyNumber(int number) {
    cargoList[choosedCargoIndex].partyNumber = number;
  }

  Cargo getMyCargo(String cargoName) {
    for (var cargo in _cargoList) {
      if (cargo.cargoName.toUpperCase() == cargoName.toUpperCase() ||
          cargo.cargoName.toLowerCase() == cargoName.toLowerCase() ||
          cargo.cargoName == cargoName) {
        return cargo;
      }
    }
    return Cargo(
      assetImageUrl: "assets/images/error.png",
      cargoName: "",
      partyNumber: 1,
    );
  }

  int _partyNumber = 1;
  int get partyNumber => _partyNumber;
  set partyNumber(int partyNumber) {
    _partyNumber = partyNumber;
    print("party number setted to $partyNumber");
  }

  int _firebasePartyNumber = 1;
  int get firebasePartyNumber => _firebasePartyNumber;
  set firebasePartyNumber(int firebasePartyNumber) {
    _firebasePartyNumber = firebasePartyNumber;
    print("firebasePartyNumber setted to $firebasePartyNumber");
  }

  String _username = "";
  String get username => _username;
  set username(String name) {
    _username = name;
    print("_username setted to $name");
  }
}

import 'package:flutter/material.dart';

const int LIMIT = 60;

class LazyLoadProvider with ChangeNotifier {
  //LIST
  int _directSuccessOrdersLength = 0;
  int get directSuccessOrdersLength => _directSuccessOrdersLength;
  set directSuccessOrdersLength(int index) {
    _directSuccessOrdersLength = index;
  }

  int _crossSuccessOrdersLength = 0;
  int get crossSuccessOrdersLength => _crossSuccessOrdersLength;
  set crossSuccessOrdersLength(int index) {
    _crossSuccessOrdersLength = index;
  }

  //BIZIM

  int _directSuccessOrdersCount = LIMIT;
  int get directSuccessOrdersCount {
    if (_directSuccessOrdersCount > _directSuccessOrdersLength) {
      print("hop buradyim");
      _directReachedMax = true;
      return _directSuccessOrdersLength;
    } else if (_directSuccessOrdersCount == 0 &&
        _directSuccessOrdersLength > LIMIT) {
      return _directSuccessOrdersCount;
    } else {
      return _directSuccessOrdersCount;
    }
  }

  bool _directReachedMax = false;
  bool get directReachedMax => _directReachedMax;
  // set directReachedMax(bool b) {
  //   _directReachedMax = true;
  // }

  void addDirectSuccessOrder() {
    _directSuccessOrdersCount += LIMIT;
    notifyListeners();
  }

  set directSuccessOrdersCount(int count) {
    _directSuccessOrdersCount = count;
    notifyListeners();
  }

  int _crossSucessOrdersCount = 0;
  int get crossSucessOrdersCount => _crossSucessOrdersCount;
  set crossSucessOrdersCount(int count) {
    _crossSucessOrdersCount = count;
    notifyListeners();
  }

  void clearAll() {
    _directSuccessOrdersLength = 0;
    _crossSuccessOrdersLength = 0;
    _directSuccessOrdersCount = LIMIT;
    _crossSucessOrdersCount = 0;
    _directReachedMax = false;
    notifyListeners();
  }

  void clearWhenPartyNumberChanged() {
    _directReachedMax = false;
    _directSuccessOrdersCount = LIMIT;
    notifyListeners();
  }
}

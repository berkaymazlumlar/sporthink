import 'package:flutter/material.dart';
import 'package:sporthink/models/order.dart';
import 'package:sporthink/models/order_error.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _successOrders = [];
  List<Order> get successOrders => _successOrders;
  void addSuccessOrder(Order order) {
    _successOrders.add(order);
    notifyListeners();
  }

  void deleteSuccessOrder(int index) {
    _successOrders.removeAt(index);
    notifyListeners();
  }

  final List<OrderError> _failedOrders = [];
  List<OrderError> get failedOrders => _failedOrders;
  void addFailedOrder(OrderError orderError) {
    _failedOrders.add(orderError);
    notifyListeners();
  }

  void deleteFailedOrder(int index) {
    _failedOrders.removeAt(index);
    notifyListeners();
  }

  String _filterText = "";
  String get filterText => _filterText;
  set filterText(String text) {
    _filterText = text;
    print("filter text setted to: $_filterText");
    notifyListeners();
  }
}

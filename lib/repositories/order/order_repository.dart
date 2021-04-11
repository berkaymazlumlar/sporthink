import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/models/order.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  final List<Order> _orders = [];
  List<Order> get orders => _orders;
  void setOrders(List<Order> order) {
    _orders.addAll(order);
    print("${order.length} order added to _orders");
  }

  final List<FirebaseOrder> _successOrders = [];
  List<FirebaseOrder> get successOrders => _successOrders;
  void setSuccessOrders(List<FirebaseOrder> sucessOrder) {
    _successOrders.clear();
    _successOrders.addAll(sucessOrder);
    print("${sucessOrder.length} order added to _orders");
  }

  final List<FirebaseOrder> _myFirebaseOrders = [];
  List<FirebaseOrder> get myFirebaseOrders => _myFirebaseOrders;
  void setFirebaseOrders(List<FirebaseOrder> firebaseOrders) {
    _myFirebaseOrders.clear();
    _myFirebaseOrders.addAll(firebaseOrders);
  }

  Future<dynamic> getOrders(DateTime startDate, DateTime endDate) async {
    final List<Order> _returningOrders = [];
    try {
      final _sporMarketUrl =
          "https://www.spormarket.com.tr/Api/PhoneOrderStatus.aspx?type=4&AuthKey=1SSqPPaa2&orderStatusId=1000&startDate=${startDate.day.toString().padLeft(2, "0")}.${startDate.month.toString().padLeft(2, "0")}.${startDate.year.toString().padLeft(2, "0")}&finishDate=${endDate.day.toString().padLeft(2, "0")}.${endDate.month.toString().padLeft(2, "0")}.${endDate.year.toString().padLeft(2, "0")}";
      final _sporThinkUrl =
          "https://www.sporthink.com.tr/Api/PhoneOrderStatus.aspx?type=4&AuthKey=3TTqSSaa4&orderStatusId=1000&startDate=${startDate.day.toString().padLeft(2, "0")}.${startDate.month.toString().padLeft(2, "0")}.${startDate.year.toString().padLeft(2, "0")}&finishDate=${endDate.day.toString().padLeft(2, "0")}.${endDate.month.toString().padLeft(2, "0")}.${endDate.year.toString().padLeft(2, "0")}";

      var responseSporMarket = await http.get(_sporMarketUrl);
      if (responseSporMarket.statusCode == 200) {
        print(responseSporMarket.body);
        _returningOrders.addAll(orderFromJson(responseSporMarket.body));
      }
      var responseSporThink = await http.get(_sporThinkUrl);
      if (responseSporThink.statusCode == 200) {
        print(responseSporThink.body);
        _returningOrders.addAll(orderFromJson(responseSporThink.body));
      }
      _orders.addAll(_returningOrders);
      for (var order in _orders) {
        if (order.shippingBarcode == "1135346") {
          print(order.toJson());
        }
      }
      return _returningOrders;
    } catch (e) {
      print("there is an error on getOrders: $e");
      return "$e";
    }
  }
}

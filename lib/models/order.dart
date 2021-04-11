import 'dart:convert';

List<Order> orderFromJson(String str) =>
    List<Order>.from(json.decode(str).map((x) => Order.fromJson(x)));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    this.orderNumber,
    this.fullName,
    this.orderDate,
    this.shipperCode,
    this.shipperName,
    this.shippingBarcode,
    this.orderStatusId,
    this.platform,
    this.isCross,
  });

  int orderNumber;
  String fullName;
  String orderDate;
  String shipperCode;
  String shipperName;
  String shippingBarcode;
  int orderStatusId;
  String platform;
  bool isCross;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        orderNumber: json["OrderNumber"],
        fullName: json["FullName"],
        orderDate: json["OrderDate"],
        shipperCode: json["ShipperCode"],
        shipperName: json["ShipperName"],
        shippingBarcode: json["ShippingBarcode"],
        orderStatusId: json["OrderStatusId"],
        platform: json["Platform"],
      );

  Map<String, dynamic> toJson() => {
        "OrderNumber": orderNumber,
        "FullName": fullName,
        "OrderDate": orderDate,
        "ShipperCode": shipperCode,
        "ShipperName": shipperName,
        "ShippingBarcode": shippingBarcode,
        "OrderStatusId": orderStatusId,
        "Platform": platform,
      };
}

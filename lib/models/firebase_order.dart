import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseOrder {
  final String errorReason;
  final String firstBarcodeNumber;
  final String secondBarcodeNumber;
  final String fullName;
  final bool isCross;
  final bool isSuccess;
  final String orderNumber;
  final int partyNumber;
  final String platform;
  final String shipperCode;
  final String shipperName;
  final String shippingBarcode;
  final String date;
  final String orderDate;
  final String checkDate;
  final bool isActive;
  final String username;
  final String deleterName;

  FirebaseOrder(
      {@required this.errorReason,
      @required this.firstBarcodeNumber,
      @required this.secondBarcodeNumber,
      @required this.fullName,
      @required this.isCross,
      @required this.isSuccess,
      @required this.orderNumber,
      @required this.partyNumber,
      @required this.platform,
      @required this.shipperCode,
      @required this.shipperName,
      @required this.shippingBarcode,
      @required this.date,
      @required this.orderDate,
      @required this.checkDate,
      this.isActive = true,
      @required this.username,
      @required this.deleterName});

  factory FirebaseOrder.fromCem(QueryDocumentSnapshot snapshot) =>
      FirebaseOrder(
        errorReason: snapshot["errorReason"] ?? "yok",
        firstBarcodeNumber: snapshot["firstBarcodeNumber"],
        secondBarcodeNumber: snapshot["secondBarcodeNumber"],
        fullName: snapshot["fullName"],
        isCross: snapshot["isCross"],
        isSuccess: snapshot["isSuccess"],
        orderNumber: snapshot["orderNumber"],
        partyNumber: snapshot["partyNumber"],
        platform: snapshot["platform"],
        shipperCode: snapshot["shipperCode"],
        shipperName: snapshot["shipperName"],
        shippingBarcode: snapshot["shippingBarcode"],
        date: snapshot["date"],
        orderDate: snapshot["orderDate"],
        checkDate: snapshot["checkDate"] == null ? "" : snapshot["checkDate"],
        username: snapshot["username"] == null ? "" : snapshot["username"],
        isActive: snapshot["isActive"] == null ? "" : snapshot["isActive"],
        deleterName:
            snapshot["deleterName"] == null ? "" : snapshot["deleterName"],
      );

  Map<String, dynamic> toJson() => {
        "fullName": fullName,
        "errorReason": errorReason,
        "firstBarcodeNumber": firstBarcodeNumber,
        "secondBarcodeNumber": secondBarcodeNumber,
        "isCross": isCross,
        "isSuccess": isSuccess,
        "orderNumber": orderNumber,
        "partyNumber": partyNumber,
        "platform": platform,
        "shipperCode": shipperCode,
        "shipperName": shipperName,
        "shippingBarcode": shippingBarcode,
        "date": date,
        "orderDate": orderDate,
        "checkDate": checkDate,
        "username": username,
        "isActive": isActive,
        "deleterName": deleterName,
      };
}

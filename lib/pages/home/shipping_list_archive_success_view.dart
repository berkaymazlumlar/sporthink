import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sporthink/helper/date_helper.dart';
import 'package:sporthink/helper/eralp_helper.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/order/order_repository.dart';
import 'package:path/path.dart' as myPath;

CargoRepository _cargoRepository = locator<CargoRepository>();
OrderRepository _orderRepository = locator<OrderRepository>();

class ShippingListArchiveSuccessView extends StatefulWidget {
  final List<FirebaseOrder> firebaseOrders;
  ShippingListArchiveSuccessView({Key key, @required this.firebaseOrders})
      : super(key: key);

  @override
  _ShippingListArchiveSuccessViewState createState() =>
      _ShippingListArchiveSuccessViewState();
}

class _ShippingListArchiveSuccessViewState
    extends State<ShippingListArchiveSuccessView> {
  SlidableController _slidableController = SlidableController();
  final List<FirebaseOrder> _successOrders = [];
  final List<FirebaseOrder> _directSuccessOrders = [];
  final List<FirebaseOrder> _crossSuccessOrders = [];
  final String _collection = 'orders';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    for (var _order in widget.firebaseOrders) {
      if (_order.isCross) {
        _crossSuccessOrders.add(_order);
      } else {
        _directSuccessOrders.add(_order);
      }
    }
    _successOrders.addAll(widget.firebaseOrders);
    _orderRepository.setSuccessOrders(_successOrders);
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Column(
      children: [
        _directSuccessOrders.length > 0
            ? _buildDirectExpansionTile(
                _size,
                _directSuccessOrders,
                "Direkt okutmalı kargolar",
                Icon(Icons.arrow_upward),
              )
            : Container(),
        _crossSuccessOrders.length > 0
            ? _buildDirectExpansionTile(
                _size,
                _crossSuccessOrders,
                "Çapraz okutmalı kargolar",
                Icon(Icons.call_split),
              )
            : Container()
      ],
    );
  }

  ExpansionTile _buildDirectExpansionTile(
    Size _size,
    List<FirebaseOrder> _orders,
    String title,
    Icon icon,
  ) {
    return ExpansionTile(
      title: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 8,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(
                "$title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(width: 4),
              icon,
            ],
          ),
        ),
      ),
      children: [
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _orders.length,
          itemBuilder: (ctx, index) {
            final _directSuccessOrder = _orders[index];

            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              controller: _slidableController,
              secondaryActions: [
                // Container(
                //   color: Colors.red,
                //   child: IconButton(
                //     onPressed: () async {
                //       await _showAreYouSureDialog(
                //         _directSuccessOrder,
                //         index,
                //         !_directSuccessOrder.isCross,
                //       );
                //     },
                //     icon: Icon(
                //       Icons.delete,
                //       color: Colors.white,
                //       size: _size.height * 0.0375,
                //     ),
                //   ),
                // ),
              ],
              child: ExpansionTile(
                leading: Image.asset(
                  _cargoRepository
                      .getMyCargo(_directSuccessOrder.shipperName)
                      .assetImageUrl,
                  fit: BoxFit.fitWidth,
                  width: _size.width * 0.15,
                ),
                title: Row(
                  children: [
                    Text("${_directSuccessOrder.shippingBarcode}"),
                    SizedBox(width: 8),
                    _directSuccessOrder.isCross
                        ? Icon(Icons.call_split)
                        : Icon(Icons.arrow_upward),
                  ],
                ),
                children: [
                  Container(
                    color: Colors.white,
                    child: _buildExpansionTileElement(
                      "Sipariş veren",
                      _directSuccessOrder.fullName,
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: _buildExpansionTileElement(
                      "Kargo kodu",
                      _directSuccessOrder.shipperCode,
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: _buildExpansionTileElement(
                      "Kargo şirketi",
                      _directSuccessOrder.shipperName.toString(),
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: _buildExpansionTileElement(
                      "Kargo barkodu",
                      _directSuccessOrder.shippingBarcode,
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: _buildExpansionTileElement(
                      "Sipariş numarası",
                      _directSuccessOrder.orderNumber.toString(),
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: _buildExpansionTileElement(
                      "Sipariş tarihi",
                      _directSuccessOrder.orderDate,
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: _buildExpansionTileElement(
                      "Okutma tarihi",
                      "${DateHelper.getStringDateHourTR(DateTime.fromMillisecondsSinceEpoch(int.parse(_directSuccessOrder.date)))}",
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: _buildExpansionTileElement(
                      "Okutma tipi",
                      _directSuccessOrder.isCross ? "Çapraz" : "Direkt",
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: _buildExpansionTileElement(
                      "Okutan personel",
                      _directSuccessOrder.username,
                      index,
                    ),
                  ),
                  Container(
                    color: Colors.grey[200],
                    child: _buildExpansionTileElement(
                      "Silen personel",
                      _directSuccessOrder.deleterName,
                      index,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Padding _buildExpansionTileElement(String key, String value, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$key",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("$value"),
        ],
      ),
    );
  }
}

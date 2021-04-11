import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sporthink/models/firebase_order.dart';

class ShippingListArchiveFailureView extends StatefulWidget {
  final List<FirebaseOrder> firebaseOrders;
  ShippingListArchiveFailureView({Key key, @required this.firebaseOrders})
      : super(key: key);

  @override
  _ShippingListArchiveFailureViewState createState() =>
      _ShippingListArchiveFailureViewState();
}

class _ShippingListArchiveFailureViewState
    extends State<ShippingListArchiveFailureView> {
  SlidableController _slidableController = SlidableController();
  final List<FirebaseOrder> _failedOrders = [];
  final List<FirebaseOrder> _directFailedOrders = [];
  final List<FirebaseOrder> _crossFailedOrders = [];

  @override
  void initState() {
    super.initState();
    _failedOrders.addAll(widget.firebaseOrders);
    for (var _order in widget.firebaseOrders) {
      if (_order.isCross) {
        _crossFailedOrders.add(_order);
      } else {
        _directFailedOrders.add(_order);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return _directFailedOrders.length > 0
        ? Column(
            children: [
              _directFailedOrders.length > 0
                  ? _buildDirectCrossExpansionTile(
                      _size,
                      _directFailedOrders,
                      "Direkt okutmalı kargolar",
                      Icon(Icons.arrow_upward),
                    )
                  : Container(),
              _crossFailedOrders.length > 0
                  ? _buildDirectCrossExpansionTile(
                      _size,
                      _crossFailedOrders,
                      "Çapraz okutmalı kargolar",
                      Icon(Icons.call_split),
                    )
                  : Container(),
            ],
          )
        : Container();
  }

  ExpansionTile _buildDirectCrossExpansionTile(
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
            final _failureOrder = _orders[index];
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              actionExtentRatio: 0.25,
              controller: _slidableController,
              secondaryActions: [],
              child: _failureOrder.isCross
                  ? _buildCrossErrorExpansionTile(
                      _failureOrder,
                      index,
                    )
                  : _buildDirectErrorExpansionTile(
                      _failureOrder,
                      index,
                    ),
            );
          },
        ),
      ],
    );
  }

  ExpansionTile _buildCrossErrorExpansionTile(
      FirebaseOrder _failureOrder, int index) {
    return ExpansionTile(
      title: Row(
        children: [
          Text("${_failureOrder.firstBarcodeNumber}"),
          SizedBox(width: 8),
          Icon(Icons.call_split),
        ],
      ),
      children: [
        Container(
          color: Colors.white,
          child: _buildExpansionTileElement(
            "Birinci barkod",
            _failureOrder.firstBarcodeNumber,
            index,
          ),
        ),
        Container(
          color: Colors.grey[200],
          child: _buildExpansionTileElement(
            "İkinci barkod",
            _failureOrder.secondBarcodeNumber,
            index,
          ),
        ),
        Container(
          color: Colors.white,
          child: _buildExpansionTileElementExpanded(
            "Hata sebebi",
            _failureOrder.errorReason.toString(),
            index,
          ),
        ),
        Container(
          color: Colors.grey[200],
          child: _buildExpansionTileElementExpanded(
            "Okutan personel",
            _failureOrder.username.toString(),
            index,
          ),
        ),
        Container(
          color: Colors.white,
          child: _buildExpansionTileElementExpanded(
            "Silen personel",
            _failureOrder.deleterName.toString(),
            index,
          ),
        ),
      ],
    );
  }

  ExpansionTile _buildDirectErrorExpansionTile(
      FirebaseOrder _failureOrder, int index) {
    return ExpansionTile(
      title: Row(
        children: [
          Text("${_failureOrder.firstBarcodeNumber}"),
          SizedBox(width: 8),
          Icon(Icons.arrow_upward),
        ],
      ),
      children: [
        Container(
          color: Colors.white,
          child: _buildExpansionTileElement(
            "Barkod",
            _failureOrder.firstBarcodeNumber,
            index,
          ),
        ),
        Container(
          color: Colors.grey[200],
          child: _buildExpansionTileElementExpanded(
            "Hata sebebi",
            _failureOrder.errorReason.toString(),
            index,
          ),
        ),
        Container(
          color: Colors.white,
          child: _buildExpansionTileElementExpanded(
            "Okutan personel",
            _failureOrder.username.toString(),
            index,
          ),
        ),
        Container(
          color: Colors.grey[200],
          child: _buildExpansionTileElementExpanded(
            "Silen personel",
            _failureOrder.deleterName.toString(),
            index,
          ),
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

  Padding _buildExpansionTileElementExpanded(
      String key, String value, int index) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$key",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                "$value",
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

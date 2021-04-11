import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sporthink/helper/date_helper.dart';
import 'package:sporthink/helper/eralp_helper.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();

class ShippingListFailureListView extends StatefulWidget {
  final List<FirebaseOrder> firebaseOrders;
  ShippingListFailureListView({Key key, @required this.firebaseOrders})
      : super(key: key);

  @override
  _ShippingListFailureListViewState createState() =>
      _ShippingListFailureListViewState();
}

class _ShippingListFailureListViewState
    extends State<ShippingListFailureListView> {
  SlidableController _slidableController = SlidableController();
  final List<FirebaseOrder> _failedOrders = [];
  final List<FirebaseOrder> _directFailedOrders = [];
  final List<FirebaseOrder> _crossFailedOrders = [];
  final String _collection = 'orders';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

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
          left: 32,
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
              secondaryActions: [
                Container(
                  color: Colors.red,
                  child: IconButton(
                    onPressed: () async {
                      await _showAreYouSureDialog(
                        _failureOrder,
                        index,
                        !_failureOrder.isCross,
                      ); // await _deleteFromFirestoreOrder(_failureOrder, index);
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: _size.height * 0.0375,
                    ),
                  ),
                ),
              ],
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

  Future _deleteFromFirestoreOrder(
    FirebaseOrder _successOrder,
    int index,
    bool isDirect,
  ) async {
    EralpHelper.startProgress();
    try {
      final QuerySnapshot _response = await _fireStore
          .collection(_collection)
          .where("checkDate", isEqualTo: "${_successOrder.checkDate}")
          .get();
      print("DOCS LENGTH: ${_response.docs.length}");
      if (_response.docs.length == 0) {
        EralpHelper.stopProgress();
        await Future.delayed(Duration(milliseconds: 251));
        _showErrorDialog("Silinecek ürün bulunamadı");
      } else if (_response.docs.length == 1) {
        await _fireStore
            .collection(_collection)
            .doc(_response.docs.first.id)
            .update(
          {
            "isActive": false,
            "deleterName": "${_cargoRepository.username}",
          },
        );
        if (isDirect) {
          _directFailedOrders.removeAt(index);
        } else {
          _crossFailedOrders.removeAt(index);
        }
        _failedOrders.removeAt(index);
        setState(() {});
      } else {
        EralpHelper.stopProgress();
        await Future.delayed(Duration(milliseconds: 251));
        _showErrorDialog(
            "Kargo silinirken bir hata oluştu. Lütfen tekrar deneyin");
      }
      EralpHelper.stopProgress();
    } catch (e) {
      EralpHelper.stopProgress();
    } finally {
      EralpHelper.stopProgress();
    }
  }

  void _showErrorDialog(String hata) {
    final _size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).errorColor,
                  size: _size.height * 0.1,
                ),
                SizedBox(height: 16),
                Text(
                  "$hata",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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
      ],
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
      ],
    );
  }

  Future<void> _showAreYouSureDialog(
    FirebaseOrder _failureOrder,
    int index,
    bool isDirect,
  ) async {
    final _size = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).errorColor,
                  size: _size.height * 0.1,
                ),
                SizedBox(height: 16),
                Text(
                  "Silmek istediğinizden emin misiniz?",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      onPressed: () async {
                        await _deleteFromFirestoreOrder(
                            _failureOrder, index, isDirect);
                        _slidableController.activeState.close();
                        Navigator.pop(ctx);
                      },
                      child: Text("Evet"),
                    ),
                    SizedBox(width: 16),
                    FlatButton(
                      onPressed: () {
                        _slidableController.activeState.close();
                        Navigator.pop(ctx);
                      },
                      child: Text("İptal"),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

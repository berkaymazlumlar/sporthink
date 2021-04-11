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
import 'package:sporthink/providers/lazy_load_provider.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/order/order_repository.dart';
import 'package:path/path.dart' as myPath;
import 'package:provider/provider.dart';
import 'package:sporthink/providers/order_provider.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();
OrderRepository _orderRepository = locator<OrderRepository>();

class ShippingListSuccessListView extends StatefulWidget {
  final List<FirebaseOrder> firebaseOrders;
  ShippingListSuccessListView({Key key, @required this.firebaseOrders})
      : super(key: key);

  @override
  _ShippingListSuccessListViewState createState() =>
      _ShippingListSuccessListViewState();
}

class _ShippingListSuccessListViewState
    extends State<ShippingListSuccessListView> {
  SlidableController _slidableController = SlidableController();
  final List<FirebaseOrder> _successOrders = [];
  final List<FirebaseOrder> _directSuccessOrders = [];
  final List<FirebaseOrder> _crossSuccessOrders = [];
  final String _collection = 'orders';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  LazyLoadProvider _lazyLoadProviderLF;
  @override
  void initState() {
    super.initState();
    _lazyLoadProviderLF = Provider.of<LazyLoadProvider>(context, listen: false);
    for (var _order in widget.firebaseOrders) {
      if (_order.isCross) {
        _crossSuccessOrders.add(_order);
      } else {
        _directSuccessOrders.add(_order);
      }
    }

    _lazyLoadProviderLF.directSuccessOrdersLength = _directSuccessOrders.length;
    _lazyLoadProviderLF.crossSuccessOrdersLength = _crossSuccessOrders.length;
    _successOrders.addAll(widget.firebaseOrders);
    _orderRepository.setSuccessOrders(_successOrders);
  }

  @override
  Widget build(BuildContext context) {
    LazyLoadProvider _lazyLoadProvider = Provider.of<LazyLoadProvider>(context);

    final _size = MediaQuery.of(context).size;

    return Column(
      children: [
        _directSuccessOrders.length > 0
            ? _buildDirectExpansionTile(
                _size,
                _directSuccessOrders,
                "Direkt okutmalı kargolar",
                Icon(Icons.arrow_upward),
                _lazyLoadProvider,
              )
            : Container(),
        _crossSuccessOrders.length > 0
            ? _buildDirectExpansionTile(
                _size,
                _crossSuccessOrders,
                "Çapraz okutmalı kargolar",
                Icon(Icons.call_split),
                _lazyLoadProvider,
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
    LazyLoadProvider lf,
  ) {
    return ExpansionTile(
      maintainState: true,
      leading: IconButton(
        icon: Icon(
          Icons.picture_as_pdf,
          color: Colors.blue,
        ),
        onPressed: () async {
          await _extractExcel(_orders);
        },
      ),
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
          itemCount: lf.directSuccessOrdersCount,
          itemBuilder: (ctx, index) {
            final _directSuccessOrder = _orders[index];
            if (!_directSuccessOrder.shippingBarcode
                .contains(Provider.of<OrderProvider>(context).filterText)) {
              return Container();
            }
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
                        _directSuccessOrder,
                        index,
                        !_directSuccessOrder.isCross,
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: _size.height * 0.0375,
                    ),
                  ),
                ),
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
                ],
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
          _directSuccessOrders.removeAt(index);
        } else {
          _crossSuccessOrders.removeAt(index);
        }
        _successOrders.removeAt(index);
        _orderRepository.setSuccessOrders(_successOrders);
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

  Future<void> _showAreYouSureDialog(
      FirebaseOrder _order, int index, bool isDirect) async {
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
                            _order, index, isDirect);
                        _slidableController.activeState.close();

                        Navigator.pop(ctx);
                        Provider.of<LazyLoadProvider>(context)
                            .directSuccessOrdersCount -= 1;
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

  Future _extractExcel(List<FirebaseOrder> extractOrder) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];
      List<String> dataList = [
        "Sıra numarası",
        "Sipariş numarası",
        "Sipariş tarihi",
        "Tam isim",
        "Kargo ismi",
        "Barkod",
        "Kargo kodu",
        "Platform",
      ];
      sheetObject.insertRowIterables(dataList, 0);
      for (var i = 0; i < extractOrder.length; i++) {
        List<String> dataList = [
          "${i + 1}",
          "${extractOrder[i].orderNumber}",
          "${extractOrder[i].orderDate}",
          "${extractOrder[i].fullName}",
          "${extractOrder[i].shipperName}",
          "${extractOrder[i].shippingBarcode}",
          "${extractOrder[i].shipperCode}",
          "${extractOrder[i].platform}",
        ];
        sheetObject.insertRowIterables(dataList, i + 1);
      }

      Directory appDocDir = await getExternalStorageDirectory();
      String appDocPath = appDocDir.path;
      excel.encode().then((onValue) {
        File(myPath.join(
            "$appDocPath/${DateTime.now().millisecondsSinceEpoch.toString()}.xlsx"))
          ..createSync(recursive: true)
          ..writeAsBytes(onValue).then((path) {
            print("path: ${path.path}");
            OpenFile.open(path.path);
          });
      });

      print("1");
    } catch (e) {
      print("hata: $e");
    }
  }
}

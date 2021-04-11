import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporthink/constants/shared_prefs_const.dart';
import 'package:sporthink/helper/eralp_helper.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/cargo.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/models/order.dart';
import 'package:sporthink/providers/lazy_load_provider.dart';
import 'package:sporthink/providers/order_provider.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/order/order_repository.dart';
import 'package:sporthink/requests/requests.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();
OrderRepository _orderRepository = locator<OrderRepository>();

class QueryTypePage extends StatefulWidget {
  QueryTypePage({Key key}) : super(key: key);

  @override
  _QueryTypePageState createState() => _QueryTypePageState();
}

class _QueryTypePageState extends State<QueryTypePage> {
  final String _collection = 'orders';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  final assetsAudioPlayer = AssetsAudioPlayer();
  OrderProvider _orderProviderLF;
  final _barcodeController = TextEditingController();
  final _crossFirstBarcodeController = TextEditingController();
  final _crossSecondBarcodeController = TextEditingController();
  int _second = 5;
  @override
  void initState() {
    super.initState();
    _orderProviderLF = Provider.of<OrderProvider>(context, listen: false);
    setTime();
  }

  Future<void> setTime() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    _second = _sharedPreferences.getInt(SharedPrefsConst.COUNT_DOWN_SECOND);
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    final _myCargo =
        _cargoRepository.cargoList[_cargoRepository.choosedCargoIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_myCargo.cargoName}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                await _openBarcodeScreen(_myCargo.cargoName);
              },
              onLongPress: () async {
                await _showDirectDialog(context, _myCargo);
              },
              child: Center(
                child: Text(
                  "Direkt\nokutmalı",
                  style: TextStyle(
                    fontSize: _size.height * 0.05,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: InkWell(
              onTap: () async {
                await _openCrossBarcodeScreen(_myCargo.cargoName);
              },
              onLongPress: () async {
                await _showCrossDialog(context, _myCargo);
              },
              child: Center(
                child: Text(
                  "Çapraz\nkontrollü",
                  style: TextStyle(
                    fontSize: _size.height * 0.05,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            color: Colors.blue,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FlatButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, "/shippingListArchivePage");
                    },
                    icon: Icon(
                      Icons.archive,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Arşiv",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                VerticalDivider(
                  color: Colors.black,
                ),
                Expanded(
                  child: FlatButton.icon(
                    onPressed: () {
                      Provider.of<LazyLoadProvider>(context, listen: false)
                          .clearAll();
                      Navigator.pushNamed(context, "/shippingListFirebasePage");
                    },
                    icon: Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Kargolarım",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _showDirectDialog(BuildContext context, Cargo _myCargo) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Barkod numarasını giriniz",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _barcodeController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Barkod numarası",
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        print("validated");
                        if (_barcodeController.text.length > 1) {
                          Navigator.pop(ctx);
                          await _barcodeControl(
                            _barcodeController.text,
                            _myCargo.cargoName,
                            isCross: false,
                          );
                        }
                      },
                      child: Text(
                        "Tamam",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 16),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text("Vazgeç"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _showCrossDialog(BuildContext context, Cargo _myCargo) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Barkod numarasını giriniz",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _crossFirstBarcodeController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Birinci barkod numarası",
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _crossSecondBarcodeController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "İkinci barkod numarası",
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        if (_crossFirstBarcodeController.text.length > 1 &&
                            _crossSecondBarcodeController.text.length > 1) {
                          Navigator.pop(ctx);
                          if (_crossFirstBarcodeController.text ==
                              _crossSecondBarcodeController.text) {
                            await _barcodeControl(
                              _crossFirstBarcodeController.text,
                              _myCargo.cargoName,
                              isCross: true,
                            );
                          } else {
                            FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
                              errorReason:
                                  "Çapraz kontrollü barkodlar eşleşmedi",
                              partyNumber: _cargoRepository.partyNumber,
                              isSuccess: false,
                              firstBarcodeNumber:
                                  _crossFirstBarcodeController.text,
                              secondBarcodeNumber:
                                  _crossSecondBarcodeController.text,
                              date: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              checkDate: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              fullName: "",
                              orderDate: "",
                              orderNumber: "",
                              shippingBarcode: "",
                              platform: "",
                              shipperCode: "",
                              shipperName:
                                  "${_cargoRepository.cargoList[_cargoRepository.choosedCargoIndex].cargoName}",
                              isCross: true,
                              username: _cargoRepository.username,
                              deleterName: _cargoRepository.username,
                            );
                            _fireStore
                                .collection(_collection)
                                .doc(
                                    "${_crossFirstBarcodeController.text},${_crossSecondBarcodeController.text}  - barkodlar uyusmadi")
                                .set(
                                  _errorFirebaseOrder.toJson(),
                                )
                                .then((value) {
                                  print("eklendi?????");
                                })
                                .timeout(Duration(seconds: 5))
                                .catchError((error) {
                                  print("HATA: HATA: HATA: $error");
                                  throw error;
                                });
                            _showErrorDialog(
                                "Çapraz kontrollü barkodlar eşleşmedi.");
                          }
                        }
                      },
                      child: Text(
                        "Tamam",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text("Vazgeç"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future _openBarcodeScreen(String myCargoName) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      true,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes == "-1") {
      print("okumadim eksi bir dondum");
    } else {
      await _barcodeControl(barcodeScanRes, myCargoName, isCross: false);
    }
  }

  Future _openCrossBarcodeScreen(String myCargoName) async {
    String firstBarcode = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Birinci barkod",
      true,
      ScanMode.BARCODE,
    );
    assetsAudioPlayer.open(
      Audio("assets/sounds/success.mp3"),
    );

    if (firstBarcode == "-1") {
      print("okumadim eksi bir dondum");
    } else {
      _crossFirstBarcodeController.text = firstBarcode;
      EralpHelper.startProgress();
      try {
        await Future.delayed(
          Duration(seconds: _second),
        );
      } finally {
        EralpHelper.stopProgress();
      }
      String secondBarcode = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "İkinci barkod",
        true,
        ScanMode.BARCODE,
      );
      if (secondBarcode == "-1") {
        print("okumadim eksi bir dondum");
      } else {
        if (firstBarcode == secondBarcode) {
          await _barcodeControl(firstBarcode, myCargoName, isCross: true);
        } else {
          FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
            errorReason: "Çapraz kontrollü barkodlar eşleşmedi",
            partyNumber: _cargoRepository.partyNumber,
            isSuccess: false,
            firstBarcodeNumber: _crossFirstBarcodeController.text,
            secondBarcodeNumber: _crossSecondBarcodeController.text,
            date: DateTime.now().millisecondsSinceEpoch.toString(),
            checkDate: DateTime.now().millisecondsSinceEpoch.toString(),
            fullName: "",
            orderDate: "",
            orderNumber: "",
            shippingBarcode: "",
            platform: "",
            shipperCode: "",
            shipperName:
                "${_cargoRepository.cargoList[_cargoRepository.choosedCargoIndex].cargoName}",
            isCross: true,
            username: _cargoRepository.username,
            deleterName: _cargoRepository.username,
          );
          _fireStore
              .collection(_collection)
              .doc(
                  "${_crossFirstBarcodeController.text},${_crossSecondBarcodeController.text}  - barkodlar uyusmadi")
              .set(_errorFirebaseOrder.toJson())
              .then((value) {
                print("eklendi?????");
              })
              .timeout(Duration(seconds: 5))
              .catchError((error) {
                print("HATA: HATA: HATA: $error");
                throw error;
              });
          _showErrorDialog("Çapraz kontrollü barkodlar eşleşmedi.");
        }
      }
    }
  }

  Future _barcodeControl(
    String barcodeScanRes,
    String myCargoName, {
    bool isCross = false,
  }) async {
    bool _isBarcodeExist = false;
    print("yurtici kargo length: ${barcodeScanRes.length}");
    if (barcodeScanRes.length > 13) {
      barcodeScanRes = barcodeScanRes.substring(0, 13);
    }
    // for (var order in _orderRepository.orders) {
    for (int i = 0; i < _orderRepository.orders.length; i++) {
      final _order = _orderRepository.orders[i];
      if (_order.shippingBarcode.replaceAll(new RegExp(r'[^0-9]'), '') ==
              barcodeScanRes.replaceAll(new RegExp(r'[^0-9]'), '') ||
          getTrimmed(_order.shippingBarcode) == getTrimmed(barcodeScanRes) ||
          (getTrimmed(_order.shippingBarcode).length ==
                  getTrimmed(barcodeScanRes).length &&
              getTrimmed(_order.shippingBarcode)
                  .contains(getTrimmed(barcodeScanRes)))) {
        _isBarcodeExist = true;
        if (_order.shipperName
                .toUpperCase()
                .contains(myCargoName.toUpperCase()) ||
            _order.shipperName
                .toLowerCase()
                .contains(myCargoName.toLowerCase()) ||
            _order.shipperName.contains(myCargoName)) {
          FirebaseOrder _myFirebaseOrder = FirebaseOrder(
            errorReason: "yok",
            partyNumber: _cargoRepository.partyNumber,
            isSuccess: true,
            firstBarcodeNumber: "",
            secondBarcodeNumber: "",
            date: DateTime.now().millisecondsSinceEpoch.toString(),
            checkDate: DateTime.now().millisecondsSinceEpoch.toString(),
            fullName: _order.fullName,
            orderDate: _order.orderDate,
            orderNumber: _order.orderNumber.toString(),
            shippingBarcode: _order.shippingBarcode,
            platform: _order.platform,
            shipperCode: _order.shipperCode,
            shipperName: _order.shipperName,
            isCross: isCross,
            username: _cargoRepository.username,
            deleterName: _cargoRepository.username,
          );
          if (await Requests.checkIfOrderExist(
              _order.shippingBarcode.toString())) {
            FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
              errorReason: "Mükerrer ürün hatası",
              partyNumber: _cargoRepository.partyNumber,
              isSuccess: false,
              firstBarcodeNumber: _order.shippingBarcode,
              secondBarcodeNumber: _order.shippingBarcode,
              date: DateTime.now().millisecondsSinceEpoch.toString(),
              checkDate: DateTime.now().millisecondsSinceEpoch.toString(),
              fullName: "",
              orderDate: "",
              orderNumber: "",
              shippingBarcode: "",
              platform: "",
              shipperCode: "",
              shipperName:
                  "${_cargoRepository.cargoList[_cargoRepository.choosedCargoIndex].cargoName}",
              isCross: isCross,
              username: _cargoRepository.username,
              deleterName: _cargoRepository.username,
            );
            _fireStore
                .collection(_collection)
                .doc("${_order.shippingBarcode} - Mükerrer")
                .set(
                  _errorFirebaseOrder.toJson(),
                )
                .then((value) {})
                .timeout(Duration(seconds: 5))
                .catchError((error) {
              print(error);
              throw error;
            });
            _showErrorDialog(
                "Mükerrer ürün hatası, barkod numarası: ${_order.shippingBarcode.toString()}");

            return;
          }

          _putToFirestore(
            _order,
            _myFirebaseOrder,
            isCross,
            myCargoName,
          );

          return;
        } else {
          FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
            errorReason:
                "Barkod kargo şirketi veritabaninda ${_order.shipperName} olarak kayıtlı. Okutma yapılan kargo şirketi ise $myCargoName",
            partyNumber: _cargoRepository.partyNumber,
            isSuccess: false,
            firstBarcodeNumber: _order.shippingBarcode,
            secondBarcodeNumber: _order.shippingBarcode,
            date: DateTime.now().millisecondsSinceEpoch.toString(),
            checkDate: DateTime.now().millisecondsSinceEpoch.toString(),
            fullName: "",
            orderDate: "",
            orderNumber: "",
            shippingBarcode: "",
            platform: "",
            shipperCode: "",
            shipperName:
                "${_cargoRepository.cargoList[_cargoRepository.choosedCargoIndex].cargoName}",
            isCross: isCross,
            username: _cargoRepository.username,
            deleterName: _cargoRepository.username,
          );
          _fireStore
              .collection(_collection)
              .doc(
                  "${_order.shippingBarcode} - veritabani kargo sirketi hatasi")
              .set(
                _errorFirebaseOrder.toJson(),
              )
              .then((value) {})
              .timeout(Duration(seconds: 5))
              .catchError((error) {
            print(error);
            throw error;
          });

          _showErrorDialog(
              "Barkod kargo şirketi veritabaninda ${_order.shipperName} olarak kayıtlı. Okutma yapılan kargo şirketi ise $myCargoName");

          print("barkod veritabaninda var ama kargolar eslesmedi");
          return;
        }
      }
    }
    if (!_isBarcodeExist) {
      FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
        errorReason: "Barkod kaydı bulunamadı",
        partyNumber: _cargoRepository.partyNumber,
        isSuccess: false,
        firstBarcodeNumber: barcodeScanRes,
        secondBarcodeNumber: barcodeScanRes,
        date: DateTime.now().millisecondsSinceEpoch.toString(),
        checkDate: DateTime.now().millisecondsSinceEpoch.toString(),
        fullName: "",
        orderDate: "",
        orderNumber: "",
        shippingBarcode: "",
        platform: "",
        shipperCode: "",
        shipperName:
            "${_cargoRepository.cargoList[_cargoRepository.choosedCargoIndex].cargoName}",
        isCross: isCross,
        username: _cargoRepository.username,
        deleterName: _cargoRepository.username,
      );
      _fireStore
          .collection(_collection)
          .doc("$barcodeScanRes - kayit yok")
          .set(
            _errorFirebaseOrder.toJson(),
          )
          .then((value) {})
          .timeout(Duration(seconds: 5))
          .catchError((error) {
        print(error);
        throw error;
      });
      _showErrorDialog(
          "Barkod kaydı bulunamadı. Okutulan barkod: $barcodeScanRes");

      print("barkod veritabaninda yok");
      return;
    }
  }

  void _putToFirestore(Order order, FirebaseOrder _myFirebaseOrder,
      bool isCross, String myCargoName) {
    EralpHelper.startProgress();
    _fireStore
        .collection(_collection)
        .doc(order.shippingBarcode)
        .set(
          _myFirebaseOrder.toJson(),
        )
        .then((value) {
          EralpHelper.stopProgress();

          debugPrint("Veri eklendi");
          assetsAudioPlayer.open(
            Audio("assets/sounds/success.mp3"),
          );

          if (isCross == true) {
            _openCrossBarcodeScreen(myCargoName);
          } else {
            _openBarcodeScreen(myCargoName);
          }
        })
        .timeout(Duration(seconds: 5))
        .catchError((error) {
          EralpHelper.stopProgress();

          _showErrorDialog(
              "Veritabanına yüklenemedi, internetinizi kontrol edin ya da Berkay Mazlumlar ile iletişime geçin");
          print(error);
          throw error;
        });
    EralpHelper.stopProgress();
  }

  void _showErrorDialog(String hata) {
    assetsAudioPlayer.open(
      Audio("assets/sounds/error.mp3"),
    );

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

  String getTrimmed(String str) {
    return str
        .trimRight()
        .trimLeft()
        .trim()
        .trimRight()
        .trimLeft()
        .replaceAll(" ", "");
  }
}

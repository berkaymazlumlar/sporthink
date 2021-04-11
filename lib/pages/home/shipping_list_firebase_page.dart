import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sporthink/blocs/firebase_order/firebase_order_bloc.dart';
import 'package:sporthink/helper/eralp_helper.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/models/order.dart';
import 'package:sporthink/pages/home/shipping_list_success_list_view.dart';
import 'package:sporthink/pages/home/shipping_list_failure_list_view.dart';
import 'package:sporthink/providers/lazy_load_provider.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/date/date_repository.dart';
import 'package:sporthink/repositories/order/order_repository.dart';
import 'package:sporthink/requests/requests.dart';
import 'package:sporthink/helper/debouncer.dart';
import 'package:provider/provider.dart';
import 'package:sporthink/providers/order_provider.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();
OrderRepository _orderRepository = locator<OrderRepository>();
DateRepository _dateRepository = locator<DateRepository>();

class ShippingListFirebasePage extends StatefulWidget {
  ShippingListFirebasePage({Key key}) : super(key: key);

  @override
  _ShippingListFirebasePageState createState() =>
      _ShippingListFirebasePageState();
}

class _ShippingListFirebasePageState extends State<ShippingListFirebasePage> {
  TextEditingController _partyController = TextEditingController();
  TextEditingController _barcodeController = TextEditingController();
  TextEditingController _crossFirstBarcodeController = TextEditingController();
  TextEditingController _crossSecondBarcodeController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  FirebaseOrderBloc _firebaseOrderBloc;
  ScrollController _scrollController;
  final String _collection = 'orders';
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final assetsAudioPlayer = AssetsAudioPlayer();
  OrderRepository _orderRepository = locator<OrderRepository>();

  bool _showSearch = false;
  final _debouncer = Debouncer(milliseconds: 500);
  LazyLoadProvider _lazyLoadProviderLF;
  @override
  void initState() {
    super.initState();
    _lazyLoadProviderLF = Provider.of<LazyLoadProvider>(context, listen: false);

    _searchController.text = "";
    _firebaseOrderBloc = BlocProvider.of<FirebaseOrderBloc>(context);
    _firebaseOrderBloc.add(ClearFirebaseOrderEvent());
    _showSearch = false;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_lazyLoadProviderLF.directReachedMax) {
        if (_scrollController.position.extentAfter < 50) {
          _lazyLoadProviderLF.addDirectSuccessOrder();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: _buildFab(context),
      backgroundColor: Colors.white,
      appBar: _showSearch
          ? _searchAppBar()
          : AppBar(
              title: Text('Kargolar'),
              actions: [
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () async {
                    DateTime _pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dateRepository.date,
                      firstDate: DateTime.now().subtract(
                        Duration(days: 60),
                      ),
                      lastDate: DateTime.now(),
                    );
                    if (_pickedDate != null) {
                      _dateRepository.date = _pickedDate;
                      _firebaseOrderBloc.add(ClearFirebaseOrderEvent());
                    }
                  },
                  icon: Icon(Icons.date_range),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _firebaseOrderBloc.add(ClearFirebaseOrderEvent());
                  },
                  icon: Icon(Icons.refresh),
                ),
                InkWell(
                  onLongPress: () {
                    _showPartyNumberDialog();
                  },
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      int beforeDialog = _cargoRepository.firebasePartyNumber;
                      await _showPartyNumberDialogThreeOptions();
                      int afterDialog = _cargoRepository.firebasePartyNumber;
                      if (beforeDialog != afterDialog) {
                        _firebaseOrderBloc.add(ClearFirebaseOrderEvent());
                      }
                    },
                    icon: Text(
                      "${_cargoRepository.firebasePartyNumber}",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showSearch = true;
                    setState(() {});
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _successBlocBuilder(_size),
            _failureBlocBuilder(_size),
          ],
        ),
      ),
    );
  }

  AppBar _searchAppBar() {
    return AppBar(
      title: TextField(
        controller: _searchController,
        onChanged: (value) {
          Provider.of<OrderProvider>(context, listen: false).filterText =
              _searchController.text;
        },
        decoration: InputDecoration(
          hintText: "Arama yap",
          hintStyle: TextStyle(color: Colors.white),
        ),
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.red,
      ),
      actions: [
        IconButton(
          onPressed: () {
            if (_searchController.text.length > 0) {
              _searchController.text = "";
              Provider.of<OrderProvider>(context, listen: false).filterText =
                  "";
              setState(() {});
            } else {
              Provider.of<OrderProvider>(context, listen: false).filterText =
                  "";
              _showSearch = false;
              setState(() {});
            }
          },
          icon: _searchController.text.length == 0
              ? Icon(Icons.close)
              : Icon(Icons.backspace),
        )
      ],
    );
  }

  SpeedDial _buildFab(BuildContext context) {
    return SpeedDial(
      marginRight: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(
        size: 22.0,
        color: Colors.white,
      ),
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.blue,
      foregroundColor: Colors.black,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(Icons.arrow_upward),
            backgroundColor: Colors.red,
            label: 'Direkt okutmalı',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () => _showDirectDialog(context)),
        SpeedDialChild(
          child: Icon(Icons.call_split),
          backgroundColor: Colors.blue,
          label: 'Çapraz kontrollü',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => _showCrossDialog(context),
        ),
      ],
    );
  }

  BlocBuilder<FirebaseOrderBloc, FirebaseOrderState> _successBlocBuilder(
      Size _size) {
    return BlocBuilder(
      cubit: _firebaseOrderBloc,
      builder: (context, successState) {
        if (successState is FirebaseOrderInitialState) {
          print("ben initial birim");
          _firebaseOrderBloc.add(
            GetFirebaseOrderEvent(isSuccess: true),
          );
        }
        if (successState is FirebaseOrderFailureState) {}
        if (successState is FirebaseOrderLoadedState) {
          final List<FirebaseOrder> _successOrders = [];
          for (var order in _orderRepository.myFirebaseOrders) {
            if (order.isSuccess) {
              if (_checkDate(order)) {
                if (order.shipperName
                    .contains(_cargoRepository.getCargoName())) {
                  _successOrders.add(order);
                }
              }
            }
          }
          _successOrders.sort((first, second) =>
              (first.checkDate.compareTo(second.checkDate)) * -1);
          return _successOrders.length > 0
              ? Column(
                  children: [
                    _successOrders.length > 0
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Başarılı kargolar",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    _buildListView(_successOrders, _size),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Bugüne ait ',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'başarılı',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' kargo bulunamadı'),
                        ],
                      ),
                    ),
                  ),
                );
        }
        return Container();
      },
    );
  }

  Widget _buildListView(List<FirebaseOrder> _successOrders, Size _size) {
    return ShippingListSuccessListView(
      firebaseOrders: _successOrders,
    );
  }

  BlocBuilder<FirebaseOrderBloc, FirebaseOrderState> _failureBlocBuilder(
      Size _size) {
    return BlocBuilder(
      cubit: _firebaseOrderBloc,
      builder: (context, successState) {
        if (successState is FirebaseOrderInitialState) {
          print("ben initial ikiyim");
        }
        if (successState is FirebaseOrderFailureState) {
          return Center(
            child: Text("${successState.error}"),
          );
        }
        if (successState is FirebaseOrderLoadedState) {
          final List<FirebaseOrder> _failureOrders = [];
          for (var order in _orderRepository.myFirebaseOrders) {
            if (!order.isSuccess) {
              if (_checkDate(order)) {
                if (order.shipperName
                    .contains(_cargoRepository.getCargoName())) {
                  _failureOrders.add(order);
                }
              }
            }
          }
          _failureOrders.sort((first, second) =>
              (first.checkDate.compareTo(second.checkDate)) * -1);

          return _failureOrders.length > 0
              ? Column(
                  children: [
                    _failureOrders.length > 0
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Başarısız kargolar",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    ShippingListFailureListView(
                      firebaseOrders: _failureOrders,
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Bugüne ait ',
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                              text: 'başarısız',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: ' kargo bulunamadı'),
                        ],
                      ),
                    ),
                  ),
                );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  bool _checkDate(FirebaseOrder order) {
    return DateTime.fromMillisecondsSinceEpoch(int.parse(order.date)).month ==
            _dateRepository.date.month &&
        DateTime.fromMillisecondsSinceEpoch(int.parse(order.date)).day ==
            _dateRepository.date.day &&
        DateTime.fromMillisecondsSinceEpoch(int.parse(order.date)).year ==
            _dateRepository.date.year;
  }

  _showPartyNumberDialogThreeOptions() async {
    return showDialog(
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
                  "Parti numarasını seçin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: RaisedButton(
                        onPressed: () async {
                          _cargoRepository.firebasePartyNumber = 1;
                          setState(() {});
                          Provider.of<LazyLoadProvider>(context, listen: false)
                              .clearWhenPartyNumberChanged();
                          Navigator.pop(ctx);
                        },
                        child: Text("1"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: RaisedButton(
                        onPressed: () async {
                          _cargoRepository.firebasePartyNumber = 2;
                          Provider.of<LazyLoadProvider>(context, listen: false)
                              .clearWhenPartyNumberChanged();

                          setState(() {});
                          Navigator.pop(ctx);
                        },
                        child: Text("2"),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: RaisedButton(
                        onPressed: () async {
                          _cargoRepository.firebasePartyNumber = 3;
                          Provider.of<LazyLoadProvider>(context, listen: false)
                              .clearWhenPartyNumberChanged();

                          setState(() {});
                          Navigator.pop(ctx);
                        },
                        child: Text("3"),
                      ),
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

  _showPartyNumberDialog() async {
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
                  "Parti numarasını girin",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _partyController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Parti numarası",
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      onPressed: () async {
                        print(
                            "number controller text: ${_partyController.text}");
                        print(
                            "int parse hali: ${int.parse(_partyController.text)}");
                        _cargoRepository.firebasePartyNumber =
                            int.parse(_partyController.text);
                        _firebaseOrderBloc.add(ClearFirebaseOrderEvent());
                        setState(() {});
                        Provider.of<LazyLoadProvider>(context, listen: false)
                            .clearWhenPartyNumberChanged();

                        Navigator.pop(ctx);
                      },
                      child: Text("Tamam"),
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

  _showDirectDialog(BuildContext context) async {
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
                            _cargoRepository.getCargoName(),
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

  Future _barcodeControl(
    String barcodeScanRes,
    String myCargoName, {
    bool isCross = false,
  }) async {
    bool _isBarcodeExist = false;
    for (var order in _orderRepository.orders) {
      if (order.shippingBarcode == barcodeScanRes) {
        _isBarcodeExist = true;
        if (order.shipperName
                .toUpperCase()
                .contains(myCargoName.toUpperCase()) ||
            order.shipperName
                .toLowerCase()
                .contains(myCargoName.toLowerCase()) ||
            order.shipperName.contains(myCargoName)) {
          FirebaseOrder _myFirebaseOrder = FirebaseOrder(
            errorReason: "yok",
            partyNumber: _cargoRepository.firebasePartyNumber,
            isSuccess: true,
            firstBarcodeNumber: "",
            secondBarcodeNumber: "",
            date: _dateRepository.date.millisecondsSinceEpoch.toString(),
            checkDate: DateTime.now().millisecondsSinceEpoch.toString(),
            fullName: order.fullName,
            orderDate: order.orderDate,
            orderNumber: order.orderNumber.toString(),
            shippingBarcode: order.shippingBarcode,
            platform: order.platform,
            shipperCode: order.shipperCode,
            shipperName: order.shipperName,
            isCross: isCross,
            username: _cargoRepository.username,
            deleterName: _cargoRepository.username,
          );
          if (await Requests.checkIfOrderExist(
              order.shippingBarcode.toString())) {
            FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
              errorReason: "Mükerrer ürün hatası",
              partyNumber: _cargoRepository.firebasePartyNumber,
              isSuccess: false,
              firstBarcodeNumber: order.shippingBarcode,
              secondBarcodeNumber: order.shippingBarcode,
              date: _dateRepository.date.millisecondsSinceEpoch.toString(),
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
                .doc("${order.shippingBarcode} - Mükerrer")
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
                "Mükerrer ürün hatası, barkod numarası: ${order.shippingBarcode.toString()}");

            return;
          }

          _putToFirestore(
            order,
            _myFirebaseOrder,
            isCross,
            myCargoName,
          );
        } else {
          FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
            errorReason:
                "Barkod kargo şirketi veritabaninda ${order.shipperName} olarak kayıtlı. Okutma yapılan kargo şirketi ise $myCargoName",
            partyNumber: _cargoRepository.firebasePartyNumber,
            isSuccess: false,
            firstBarcodeNumber: order.shippingBarcode,
            secondBarcodeNumber: order.shippingBarcode,
            date: _dateRepository.date.millisecondsSinceEpoch.toString(),
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
              .doc("${order.shippingBarcode} - veritabani kargo sirketi hatasi")
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
              "Barkod kargo şirketi veritabaninda ${order.shipperName} olarak kayıtlı. Okutma yapılan kargo şirketi ise $myCargoName");

          print("barkod veritabaninda var ama kargolar eslesmedi");
        }
      }
    }
    if (!_isBarcodeExist) {
      FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
        errorReason: "Barkod kaydı bulunamadı",
        partyNumber: _cargoRepository.firebasePartyNumber,
        isSuccess: false,
        firstBarcodeNumber: barcodeScanRes,
        secondBarcodeNumber: barcodeScanRes,
        date: _dateRepository.date.millisecondsSinceEpoch.toString(),
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
      _showErrorDialog("Barkod kaydı bulunamadı.");

      print("barkod veritabaninda yok");
    }
  }

  void _showErrorDialog(String hata) {
    _firebaseOrderBloc.add(ClearFirebaseOrderEvent());
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
          _firebaseOrderBloc.add(ClearFirebaseOrderEvent());

          assetsAudioPlayer.open(
            Audio("assets/sounds/success.mp3"),
          );
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

  _showCrossDialog(BuildContext context) async {
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
                              _cargoRepository.getCargoName(),
                              isCross: true,
                            );
                          } else {
                            FirebaseOrder _errorFirebaseOrder = FirebaseOrder(
                              errorReason:
                                  "Çapraz kontrollü barkodlar eşleşmedi",
                              partyNumber: _cargoRepository.firebasePartyNumber,
                              isSuccess: false,
                              firstBarcodeNumber:
                                  _crossFirstBarcodeController.text,
                              secondBarcodeNumber:
                                  _crossSecondBarcodeController.text,
                              date: _dateRepository.date.millisecondsSinceEpoch
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
}

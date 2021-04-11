import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sporthink/blocs/firebase_archive/firebase_archive_bloc.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/pages/home/shipping_list_archive_failure_view.dart';
import 'package:sporthink/pages/home/shipping_list_archive_success_view.dart';
import 'package:sporthink/pages/home/shipping_list_success_list_view.dart';
import 'package:sporthink/pages/home/shipping_list_failure_list_view.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/date/date_repository.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();
DateRepository _dateRepository = locator<DateRepository>();

class ShippingListArchivePage extends StatefulWidget {
  ShippingListArchivePage({Key key}) : super(key: key);

  @override
  _ShippingListArchivePageState createState() =>
      _ShippingListArchivePageState();
}

class _ShippingListArchivePageState extends State<ShippingListArchivePage> {
  TextEditingController _partyController = TextEditingController();
  FirebaseArchiveBloc _firebaseArchiveBloc;
  ByteData cursiveFont;

  @override
  void initState() {
    super.initState();

    rootBundle.load("assets/fonts/OpenSans-Regular.ttf").then((value) {
      cursiveFont = value;
      print("cursiveFont");
    });
    _firebaseArchiveBloc = BlocProvider.of<FirebaseArchiveBloc>(context);
    _firebaseArchiveBloc.add(ClearFirebaseArchiveEvent());
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
        title: Text('Arşiv'),
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
                _firebaseArchiveBloc.add(ClearFirebaseArchiveEvent());
              }
            },
            icon: Icon(Icons.date_range),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              _firebaseArchiveBloc.add(ClearFirebaseArchiveEvent());
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
                  _firebaseArchiveBloc.add(ClearFirebaseArchiveEvent());
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
        ],
      ),
      body: SingleChildScrollView(
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

  BlocBuilder<FirebaseArchiveBloc, FirebaseArchiveState> _successBlocBuilder(
      Size _size) {
    return BlocBuilder(
      cubit: _firebaseArchiveBloc,
      builder: (context, successState) {
        if (successState is FirebaseArchiveInitialState) {
          _firebaseArchiveBloc.add(
            GetFirebaseArchiveEvent(isSuccess: true),
          );
        }
        if (successState is FirebaseArchiveFailureState) {}
        if (successState is FirebaseArchiveLoadedState) {
          if (successState.firebaseOrders[0].shipperName !=
              _cargoRepository.getCargoName()) {
            _firebaseArchiveBloc.add(
              ClearFirebaseArchiveEvent(),
            );
          }

          final List<FirebaseOrder> _successOrders = [];
          for (var order in successState.firebaseOrders) {
            if (order.isSuccess) {
              if (_checkDate(order)) {
                if (order.shipperName
                    .contains(_cargoRepository.getCargoName())) {
                  _successOrders.add(order);
                }
              }
            }
          }
          return Column(
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
          );
        }
        return Container();
      },
    );
  }

  Widget _buildListView(List<FirebaseOrder> _successOrders, Size _size) {
    return ShippingListArchiveSuccessView(
      firebaseOrders: _successOrders,
    );
  }

  BlocBuilder<FirebaseArchiveBloc, FirebaseArchiveState> _failureBlocBuilder(
      Size _size) {
    return BlocBuilder(
      cubit: _firebaseArchiveBloc,
      builder: (context, successState) {
        if (successState is FirebaseArchiveInitialState) {
          _firebaseArchiveBloc.add(
            GetFirebaseArchiveEvent(isSuccess: true),
          );
        }
        if (successState is FirebaseArchiveFailureState) {
          return Center(
            child: Text("${successState.error}"),
          );
        }
        if (successState is FirebaseArchiveLoadedState) {
          if (successState.firebaseOrders[0].shipperName !=
              _cargoRepository.getCargoName()) {
            _firebaseArchiveBloc.add(
              ClearFirebaseArchiveEvent(),
            );
          }

          final List<FirebaseOrder> _failureOrders = [];
          for (var order in successState.firebaseOrders) {
            if (!order.isSuccess) {
              if (_checkDate(order)) {
                if (order.shipperName
                    .contains(_cargoRepository.getCargoName())) {
                  _failureOrders.add(order);
                }
              }
            }
          }
          return Column(
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
              // //todo degisecek
              // ShippingListFailureListView(
              //   firebaseOrders: _failureOrders,
              // ),
              ShippingListArchiveFailureView(firebaseOrders: _failureOrders),
            ],
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
                        _firebaseArchiveBloc.add(ClearFirebaseArchiveEvent());
                        setState(() {});
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
}

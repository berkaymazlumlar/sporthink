import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporthink/blocs/order/order_bloc.dart';
import 'package:sporthink/constants/shared_prefs_const.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:provider/provider.dart';
import 'package:sporthink/providers/cargo_provider.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller;
  CargoProvider _cargoProvider;
  @override
  void initState() {
    super.initState();

    _cargoProvider = Provider.of<CargoProvider>(context, listen: false);
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      for (var i = 0; i < _cargoRepository.cargoList.length; i++) {
        SharedPreferences.getInstance().then((sharedPreferences) {
          try {
            final int partyNumber = sharedPreferences
                .getInt(_cargoRepository.cargoList[i].cargoName);
            if (partyNumber != null) {
              _cargoProvider.setPartyNumber(i, partyNumber);
              _cargoRepository.cargoList[i].partyNumber = partyNumber;
            } else {
              _cargoProvider.setPartyNumber(i, 0);
              _cargoRepository.cargoList[i].partyNumber = 0;
            }
          } catch (e) {
            _cargoProvider.setPartyNumber(i, 0);
            _cargoRepository.cargoList[i].partyNumber = 0;
            print(e);
          }
        });
      }
      _showUsernameDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
          width: _size.width * 0.33,
          child: Image.asset(
            "assets/images/logo.png",
            fit: BoxFit.fitWidth,
          ),
        ),
        // elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settingsPage");
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderInitialState) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              BlocProvider.of<OrderBloc>(context).add(GetOrderEvent());
            });
          }
          if (state is OrderFailureState) {
            return Center(
              child: Text("${state.error}"),
            );
          }
          if (state is OrderSuccessState) {
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: _cargoRepository.cargoList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          _cargoRepository.choosedCargoIndex = index;

                          Navigator.pushNamed(context, "/selectPartyNumber");
                          // Navigator.pushNamed(context, "/queryTypePage");
                        },
                        leading: Image.asset(
                          _cargoRepository.cargoList[index].assetImageUrl,
                          fit: BoxFit.fitWidth,
                          width: _size.width * 0.25,
                        ),
                        title: Text(
                            "${_cargoRepository.cargoList[index].cargoName}"),
                        subtitle: Provider.of<CargoProvider>(context)
                                    .getCargoPartyNumber(index) <
                                1
                            ? Container()
                            : Text(
                                "Son girilen parti numarası: ${Provider.of<CargoProvider>(context).getCargoPartyNumber(index)}"),
                      );
                    },
                    separatorBuilder: (context, index) => Divider(),
                  ),
                ),
                Image.asset(
                  "assets/images/Mertiva-Logo.png",
                  width: _size.width * 0.2,
                  fit: BoxFit.fitWidth,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      "v1.0.0",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Future<void> _showUsernameDialog() async {
    SharedPreferences _sp = await SharedPreferences.getInstance();
    try {
      _controller.text = _sp.getString(SharedPrefsConst.USERNAME);
    } catch (e) {
      _controller.text = "";
    }
    final _size = MediaQuery.of(context).size;
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: SimpleDialog(
            title: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Kullanıcı adı",
                      // border: InputBorder.none,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        onPressed: () async {
                          if (_controller.text.length > 1) {
                            _cargoRepository.username = _controller.text;
                            _sp.setString(
                                SharedPrefsConst.USERNAME, _controller.text);

                            Navigator.pop(ctx);
                          }
                        },
                        child: Text("Tamam"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

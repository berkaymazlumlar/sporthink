import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporthink/constants/shared_prefs_const.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _numberController = TextEditingController();
  final _partyController = TextEditingController();
  Future<SharedPreferences> futureSharedPrefs;
  TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    futureSharedPrefs = SharedPreferences.getInstance();
    _controller = TextEditingController();
    _controller.text = _cargoRepository.username;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: ListView(
        children: [
          FutureBuilder(
            future: SharedPreferences.getInstance(),
            builder: (context, AsyncSnapshot<SharedPreferences> snapshot) {
              if (snapshot.hasData) {
                return RaisedButton(
                  // color: Theme.of(context).primaryColor,
                  onPressed: () async {
                    await _showCooldownTimeDialog();
                  },
                  child: Text(
                    "Çapraz kontrollü barkod bekleme süresi: ${snapshot.data.getInt(SharedPrefsConst.COUNT_DOWN_SECOND)} saniye",
                    // style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          ),
          RaisedButton(
            onPressed: () {
              _showUsernameDialog();
            },
            onLongPress: () {},
            child: Text(
              "Kullanıdı adı: ${_cargoRepository.username}",
            ),
          ),
        ],
      ),
    );
  }

  _showCooldownTimeDialog() async {
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
                  controller: _numberController,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: "Bekleme süresi",
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      onPressed: () async {
                        print(
                            "number controller text: ${_numberController.text}");
                        print(
                            "int parse hali: ${int.parse(_numberController.text)}");
                        SharedPreferences _sharedPreferences =
                            await SharedPreferences.getInstance();
                        _sharedPreferences.setInt(
                          SharedPrefsConst.COUNT_DOWN_SECOND,
                          int.parse(_numberController.text),
                        );
                        print(
                            "${_sharedPreferences.getInt(SharedPrefsConst.COUNT_DOWN_SECOND)}");
                        futureSharedPrefs = SharedPreferences.getInstance();
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

  Future<void> _showUsernameDialog() async {
    SharedPreferences _sp = await SharedPreferences.getInstance();
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

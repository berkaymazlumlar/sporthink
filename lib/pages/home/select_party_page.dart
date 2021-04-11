import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:provider/provider.dart';
import 'package:sporthink/providers/cargo_provider.dart';
import 'package:flutter/services.dart';

CargoRepository _cargoRepository = locator<CargoRepository>();

class SelectPartyNumber extends StatefulWidget {
  SelectPartyNumber({Key key}) : super(key: key);

  @override
  _SelectPartyNumberState createState() => _SelectPartyNumberState();
}

class _SelectPartyNumberState extends State<SelectPartyNumber> {
  final _partyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_cargoRepository.getCargoName()} parti numarası seç'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _cargoRepository.getCargoPartyNumber() > 0
                ? Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 32.0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "${_cargoRepository.getCargoName()} için son seçilen parti numarası: ${_cargoRepository.getCargoPartyNumber()}",
                            style: TextStyle(fontSize: 32),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: Container(
                      child: Text(""),
                    ),
                  ),
            SizedBox(height: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildRow(
                    context,
                    first: 1,
                    second: 2,
                    third: 3,
                  ),
                  SizedBox(height: 16),
                  _buildRow(
                    context,
                    first: 4,
                    second: 5,
                    third: 6,
                  ),
                  SizedBox(height: 16),
                  _buildRow(
                    context,
                    first: 7,
                    second: 8,
                    third: 9,
                  ),
                  SizedBox(height: 16),
                  IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RaisedButton(
                              padding: EdgeInsets.all(24),
                              onPressed: () {
                                _showPartyNumberDialog();
                              },
                              color: Colors.blue,
                              child: Text(
                                "Manuel giriş",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: _cargoRepository
                                        .cargoList[
                                            _cargoRepository.choosedCargoIndex]
                                        .partyNumber <
                                    1
                                ? RaisedButton(
                                    padding: EdgeInsets.all(24),
                                    child: Text(
                                      "Devam",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: null,
                                  )
                                : RaisedButton(
                                    padding: EdgeInsets.all(24),
                                    color: Colors.blue,
                                    child: Text(
                                      "Devam",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, "/queryTypePage");
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, {int first, int second, int third}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildButton(
            context,
            first,
          ),
          _buildButton(
            context,
            second,
          ),
          _buildButton(
            context,
            third,
          ),
        ],
      ),
    );
  }

  RaisedButton _buildButton(BuildContext context, int number) {
    return RaisedButton(
      padding: EdgeInsets.all(24),
      onPressed: () async {
        if (_cargoRepository
                .cargoList[_cargoRepository.choosedCargoIndex].partyNumber ==
            number) {
          await _ser(0, context);
        } else {
          await _ser(number, context);
        }

        setState(() {});
      },
      color: _cargoRepository
                  .cargoList[_cargoRepository.choosedCargoIndex].partyNumber ==
              number
          ? Colors.blue[900]
          : Colors.blue[300],
      child: Text(
        "$number",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  Future _ser(int number, BuildContext context) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    _sharedPreferences.setInt(
        _cargoRepository
            .cargoList[_cargoRepository.choosedCargoIndex].cargoName,
        number);
    Provider.of<CargoProvider>(context, listen: false)
        .setPartyNumber(_cargoRepository.choosedCargoIndex, number);

    _cargoRepository.cargoList[_cargoRepository.choosedCargoIndex].partyNumber =
        number;
    _cargoRepository.partyNumber = number;
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
                        SharedPreferences _sharedPreferences =
                            await SharedPreferences.getInstance();
                        _sharedPreferences.setInt(
                            _cargoRepository
                                .cargoList[_cargoRepository.choosedCargoIndex]
                                .cargoName,
                            int.parse(_partyController.text));
                        Provider.of<CargoProvider>(context, listen: false)
                            .setPartyNumber(_cargoRepository.choosedCargoIndex,
                                int.parse(_partyController.text));
                        _cargoRepository
                            .cargoList[_cargoRepository.choosedCargoIndex]
                            .partyNumber = int.parse(_partyController.text);
                        _cargoRepository.partyNumber =
                            int.parse(_partyController.text);

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

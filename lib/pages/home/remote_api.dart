import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:sporthink/models/order.dart';

class RemoteApi extends StatefulWidget {
  @override
  _RemoteApiState createState() => _RemoteApiState();
}

class _RemoteApiState extends State<RemoteApi> {
  Future<List<Order>> _getOrders() async {
    var response = await http.get(
        "https://www.spormarket.com.tr/Api/PhoneOrderStatus.aspx?type=4&AuthKey=1SSqPPaa2&orderStatusId=1000&startDate=26.10.2020&finishDate=28.10.2020");
    if (response.statusCode == 200) {
      print(response.body);
      return orderFromJson(response.body);
    } else {
      throw Exception("Error ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Baslik"),
        actions: [
          IconButton(
            onPressed: () async {
              String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                  "#ff6666", "Cancel", true, ScanMode.BARCODE);
              print(barcodeScanRes);
              Eralp.showSnackBar(
                snackBar: SnackBar(
                  content: Text("$barcodeScanRes"),
                ),
              );
            },
            icon: Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: () async {
              FlutterBarcodeScanner.getBarcodeStreamReceiver(
                      "#ff6666", "Cancel", false, ScanMode.DEFAULT)
                  .listen((barcode) {
                Eralp.showSnackBar(
                  snackBar: SnackBar(
                    content: Text("$barcode"),
                  ),
                );
              });
            },
            icon: Icon(Icons.camera),
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: _getOrders(),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                print(snapshot.data.length);
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data[index].fullName),
                      subtitle: Text(snapshot.data[index].orderDate +
                          " " +
                          snapshot.data[index].platform),
                    );
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

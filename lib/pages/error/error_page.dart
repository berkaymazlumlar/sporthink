import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hata'),
      ),
      body: Container(
        child: Center(
          child: Text("Beklenmedik bir hata oluştu"),
        ),
      ),
    );
  }
}

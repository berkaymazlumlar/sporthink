import 'package:flutter/material.dart';

class ArchivePage extends StatefulWidget {
  ArchivePage({Key key}) : super(key: key);

  @override
  _ArchivePageState createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arşivlenmiş Kargolar'),
      ),
      body: Container(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Requests {
  static Future<bool> checkIfOrderExist(String barcodeNumber) async {
    final String _collection = 'orders';
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    final _response =
        await _fireStore.collection(_collection).doc("$barcodeNumber").get();

    try {
      final bool _isActive = await _response.get("isActive");
      if (!_isActive) {
        await _fireStore.collection(_collection).doc("$barcodeNumber").delete();
        return false;
      }
    } catch (e) {
      print("$e");
    }
    return _response.exists;
  }
}

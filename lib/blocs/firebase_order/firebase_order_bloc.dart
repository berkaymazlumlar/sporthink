import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/order/order_repository.dart';

part 'firebase_order_event.dart';
part 'firebase_order_state.dart';

final CargoRepository _cargoRepository = locator<CargoRepository>();
final OrderRepository _orderRepository = locator<OrderRepository>();

class FirebaseOrderBloc extends Bloc<FirebaseOrderEvent, FirebaseOrderState> {
  FirebaseOrderBloc() : super(FirebaseOrderInitialState());

  @override
  Stream<FirebaseOrderState> mapEventToState(
    FirebaseOrderEvent event,
  ) async* {
    if (event is GetFirebaseOrderEvent) {
      yield FirebaseOrderLoadingState();
      try {
        final firebaseOrders = await getFirebaseOrders(
          isSuccess: event.isSuccess,
        );
        if (firebaseOrders.length > 0) {
          print("firebase orders length on bloc: ${firebaseOrders.length}");
          _orderRepository.setFirebaseOrders(firebaseOrders);
          yield FirebaseOrderLoadedState();
        } else {
          yield FirebaseOrderFailureState(error: "Veri bulunamadı");
        }
      } on Exception catch (e) {
        yield FirebaseOrderFailureState(error: "$e");
      }
    }
    if (event is ClearFirebaseOrderEvent) {
      yield FirebaseOrderInitialState();
    }
  }

  Future<List<FirebaseOrder>> getFirebaseOrders(
      {@required bool isSuccess}) async {
    print("baslangic");
    final List<FirebaseOrder> _myFirebaseOrders = [];
    final String _collection = 'orders';
    final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
    QuerySnapshot _response = await _fireStore
        .collection(_collection)
        .where(
          "shipperName",
          isEqualTo: _cargoRepository.getCargoName(),
        )
        .where(
          "partyNumber",
          isEqualTo: _cargoRepository.firebasePartyNumber,
        )
        .where(
          "isActive",
          isEqualTo: true,
        )
        .get();

    // _response.docs.sort((a, b) {
    //   return a.get("checkDate").toString().compareTo(b.get("checkDate"));
    // });
    for (var item in _response.docs) {
      _myFirebaseOrders.add(FirebaseOrder.fromCem(item));
    }
    print("bitis");
    print("${_myFirebaseOrders.length}");
    return _myFirebaseOrders;
  }
}

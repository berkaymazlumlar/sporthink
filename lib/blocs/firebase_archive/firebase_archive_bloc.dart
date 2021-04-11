import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/firebase_order.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';

part 'firebase_archive_event.dart';
part 'firebase_archive_state.dart';

final CargoRepository _cargoRepository = locator<CargoRepository>();

class FirebaseArchiveBloc
    extends Bloc<FirebaseArchiveEvent, FirebaseArchiveState> {
  FirebaseArchiveBloc() : super(FirebaseArchiveInitialState());

  @override
  Stream<FirebaseArchiveState> mapEventToState(
    FirebaseArchiveEvent event,
  ) async* {
    if (event is GetFirebaseArchiveEvent) {
      yield FirebaseArchiveLoadingState();
      try {
        final firebaseOrders = await getFirebaseOrders(
          isSuccess: event.isSuccess,
        );
        if (firebaseOrders.length > 0) {
          yield FirebaseArchiveLoadedState(firebaseOrders: firebaseOrders);
        } else {
          yield FirebaseArchiveFailureState(error: "Veri bulunamadı");
        }
      } on Exception catch (e) {
        yield FirebaseArchiveFailureState(error: "$e");
      }
    }
    if (event is ClearFirebaseArchiveEvent) {
      yield FirebaseArchiveInitialState();
    }
  }

  Future<List<FirebaseOrder>> getFirebaseOrders(
      {@required bool isSuccess}) async {
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
          isEqualTo: false,
        )
        .get();

    for (var item in _response.docs) {
      _myFirebaseOrders.add(FirebaseOrder.fromCem(item));
    }
    return _myFirebaseOrders;
  }
}

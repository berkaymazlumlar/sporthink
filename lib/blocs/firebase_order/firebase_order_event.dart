part of 'firebase_order_bloc.dart';

abstract class FirebaseOrderEvent extends Equatable {
  const FirebaseOrderEvent();

  @override
  List<Object> get props => [];
}

class GetFirebaseOrderEvent extends FirebaseOrderEvent {
  final bool isSuccess;
  GetFirebaseOrderEvent({
    @required this.isSuccess,
  });
}

class ClearFirebaseOrderEvent extends FirebaseOrderEvent {}

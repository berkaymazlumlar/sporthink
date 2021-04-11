part of 'firebase_order_bloc.dart';

abstract class FirebaseOrderState extends Equatable {
  const FirebaseOrderState();

  @override
  List<Object> get props => [];
}

class FirebaseOrderInitialState extends FirebaseOrderState {}

class FirebaseOrderLoadingState extends FirebaseOrderState {}

class FirebaseOrderLoadedState extends FirebaseOrderState {}

class FirebaseOrderFailureState extends FirebaseOrderState {
  final String error;
  FirebaseOrderFailureState({@required this.error});
}

part of 'firebase_archive_bloc.dart';

abstract class FirebaseArchiveState extends Equatable {
  const FirebaseArchiveState();

  @override
  List<Object> get props => [];
}

class FirebaseArchiveInitialState extends FirebaseArchiveState {}

class FirebaseArchiveLoadingState extends FirebaseArchiveState {}

class FirebaseArchiveLoadedState extends FirebaseArchiveState {
  final List<FirebaseOrder> firebaseOrders;
  FirebaseArchiveLoadedState({@required this.firebaseOrders});
}

class FirebaseArchiveFailureState extends FirebaseArchiveState {
  final String error;
  FirebaseArchiveFailureState({@required this.error});
}

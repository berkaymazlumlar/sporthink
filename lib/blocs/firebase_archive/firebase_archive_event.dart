part of 'firebase_archive_bloc.dart';

abstract class FirebaseArchiveEvent extends Equatable {
  const FirebaseArchiveEvent();

  @override
  List<Object> get props => [];
}

class GetFirebaseArchiveEvent extends FirebaseArchiveEvent {
  final bool isSuccess;
  GetFirebaseArchiveEvent({
    @required this.isSuccess,
  });
}

class ClearFirebaseArchiveEvent extends FirebaseArchiveEvent {}

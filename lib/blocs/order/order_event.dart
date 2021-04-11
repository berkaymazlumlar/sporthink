part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class GetOrderEvent extends OrderEvent {}

class ClearOrderEvent extends OrderEvent {}

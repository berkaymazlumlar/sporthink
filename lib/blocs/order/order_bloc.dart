import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sporthink/helper/eralp_helper.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/models/order.dart';
import 'package:sporthink/repositories/order/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitialState());
  OrderRepository _orderRepository = locator<OrderRepository>();
  @override
  Stream<OrderState> mapEventToState(
    OrderEvent event,
  ) async* {
    if (event is GetOrderEvent) {
      try {
        // EralpHelper.startProgress();
        final _orderList = await _orderRepository.getOrders(
          DateTime.now().subtract(Duration(days: 30)),
          DateTime.now().add(Duration(days: 2)),
        );
        if (_orderList is List<Order>) {
          yield OrderSuccessState();
        } else {
          yield OrderFailureState(error: "Siparişler alınamadı");
        }
      } catch (e) {
        print("there is an error on GetOrderEvent: $e");
      } finally {
        // EralpHelper.stopProgress();
      }
    }
    if (event is ClearOrderEvent) {
      yield OrderInitialState();
    }
  }
}

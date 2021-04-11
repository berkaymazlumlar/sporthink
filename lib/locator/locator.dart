import 'package:get_it/get_it.dart';
import 'package:sporthink/repositories/cargo/cargo_repository.dart';
import 'package:sporthink/repositories/date/date_repository.dart';
import 'package:sporthink/repositories/order/order_repository.dart';

GetIt locator = GetIt.I;

class MyLocator {
  static void setupLocator() {
    locator.registerLazySingleton(() => OrderRepository());

    locator.registerLazySingleton(() => CargoRepository());

    locator.registerLazySingleton(() => DateRepository());
  }
}

import 'package:eralpsoftware/eralpsoftware.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporthink/blocs/firebase_archive/firebase_archive_bloc.dart';
import 'package:sporthink/blocs/firebase_order/firebase_order_bloc.dart';
import 'package:sporthink/constants/shared_prefs_const.dart';
import 'package:sporthink/locator/locator.dart';
import 'package:sporthink/providers/lazy_load_provider.dart';
import 'package:sporthink/providers/order_provider.dart';
import 'package:sporthink/providers/cargo_provider.dart';
import 'package:sporthink/route_generator/route_generator.dart';

import 'blocs/order/order_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  MyLocator.setupLocator();
  await Firebase.initializeApp();

  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  int _second = _sharedPreferences.getInt(SharedPrefsConst.COUNT_DOWN_SECOND);
  if (_second == null) {
    _sharedPreferences.setInt(SharedPrefsConst.COUNT_DOWN_SECOND, 5);
  }
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
          create: (context) => OrderBloc(),
        ),
        BlocProvider<FirebaseOrderBloc>(
          create: (context) => FirebaseOrderBloc(),
        ),
        BlocProvider<FirebaseArchiveBloc>(
          create: (context) => FirebaseArchiveBloc(),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => OrderProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => CargoProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => LazyLoadProvider(),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Eralp.builder(
      context: context,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sporthink',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('tr', 'TR'),
        ],
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: "/",
      ),
    );
  }
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(Cubit cubit) {
    super.onCreate(cubit);
    print('onCreate -- cubit: ${cubit.runtimeType}');
  }

  @override
  void onChange(Cubit cubit, Change change) {
    super.onChange(cubit, change);
    print('onChange -- cubit: ${cubit.runtimeType}, change: $change');
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    print('onError -- cubit: ${cubit.runtimeType}, error: $error');
    super.onError(cubit, error, stackTrace);
  }

  @override
  void onClose(Cubit cubit) {
    super.onClose(cubit);
    print('onClose -- cubit: ${cubit.runtimeType}');
  }
}

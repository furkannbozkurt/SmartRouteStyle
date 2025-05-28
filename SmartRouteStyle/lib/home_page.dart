import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_routes/app_logo.dart';
import 'package:smart_routes/blocs/auth_bloc/auth_bloc.dart';
import 'package:smart_routes/blocs/route_bloc/route_bloc.dart';
import 'package:smart_routes/colors.dart';
import 'package:smart_routes/map_page.dart';
import 'package:smart_routes/models/city_model.dart';
import 'package:smart_routes/restartable_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    initializeNotif();
    super.initState();
  }

  Future<void> initializeNotif() async {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings(
        "@mipmap/ic_launcher",
      ),
      iOS: DarwinInitializationSettings(),
    );
    await FlutterLocalNotificationsPlugin().initialize(initializationSettings);
  }

  Future<void> showCityPickerDialog(
    BuildContext context, {
    required List<City> cities,
    required Function(City) onSelected,
  }) async {
    return showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
              actions: [
                SizedBox(
                  height: 350,
                  child: CupertinoPicker(
                    itemExtent: 42,
                    scrollController:
                        FixedExtentScrollController(initialItem: 0),
                    onSelectedItemChanged: (index) {
                      onSelected(cities[index]);
                    },
                    children: cities.map((e) => Text(e.name)).toList(),
                  ),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RouteBloc, RouteState>(listener: (context, state) {}),
        BlocListener<AuthBloc, AuthState>(listener: (context, state) {
          state.userOrFailure.fold(
              () => null,
              (a) => a.fold((l) {
                    RestartableApp.restartApp(context);
                  }, (r) => null));
        }),
      ],
      child: Scaffold(
        backgroundColor: appPrimaryColor,
        body: SafeArea(child: BlocBuilder<RouteBloc, RouteState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 36),
                          const AppLogo(),
                          const SizedBox(height: 36),
                          const Text(
                            "Yeni bir yolculuğa başla!",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              final cities = state.availableCities;
                              context
                                  .read<RouteBloc>()
                                  .add(RouteFirstCitySelected(cities.first));
                              showCityPickerDialog(
                                context,
                                cities: cities,
                                onSelected: (city) {
                                  context
                                      .read<RouteBloc>()
                                      .add(RouteFirstCitySelected(city));
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Text(
                              state.firstCity?.name ?? "Nereden ?",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: appPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              final cities = state.availableCities;
                              context
                                  .read<RouteBloc>()
                                  .add(RouteSecondCitySelected(cities.first));
                              showCityPickerDialog(
                                context,
                                cities: cities,
                                onSelected: (city) {
                                  context
                                      .read<RouteBloc>()
                                      .add(RouteSecondCitySelected(city));
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: Text(
                              state.secondCity?.name ?? "Nereye ?",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: appPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (state.isReadyToNavigate) {
                        context.read<RouteBloc>().add(RouteNavigate());
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const MapPage();
                        }));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Center(
                              child: Text("Lütfen şehirleri seçiniz."),
                            ),
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          state.isReadyToNavigate ? Colors.white : Colors.grey,
                      minimumSize:
                          Size(MediaQuery.sizeOf(context).width / 2, 48),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Yola Çık",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: state.isReadyToNavigate
                                ? appPrimaryColor
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: state.isReadyToNavigate
                              ? appPrimaryColor
                              : Colors.white,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogout());
                    },
                    child: Text(
                      "Çıkış Yap",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: appPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        )),
      ),
    );
  }
}

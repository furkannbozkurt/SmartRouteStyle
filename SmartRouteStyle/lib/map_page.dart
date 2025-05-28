import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_routes/blocs/route_bloc/route_bloc.dart';
import 'package:smart_routes/colors.dart';
import 'package:smart_routes/comments_popup.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  bool showWeather = true;
  int selectedIndex = 0;

  @override
  void initState() {
    mapController.mapEventStream.listen((event) {
      if (event.zoom > 12) {
        setState(() {
          showWeather = false;
        });
      } else {
        setState(() {
          showWeather = true;
        });
      }
    });
    super.initState();
  }

  Icon getWeatherIcon(String weather) {
    if (weather.contains("bulut")) {
      return const Icon(
        Icons.cloud,
        color: Colors.grey,
        size: 24,
      );
    } else if (weather.contains("güneş") || weather.contains("açık")) {
      return const Icon(
        Icons.wb_sunny,
        color: Colors.yellow,
        size: 24,
      );
    } else if (weather.contains("yağmur")) {
      return const Icon(
        Icons.cloudy_snowing,
        color: Colors.blue,
        size: 24,
      );
    } else if (weather.contains("kar")) {
      return const Icon(
        Icons.ac_unit,
        color: Colors.white,
        size: 24,
      );
    } else if (weather.contains("kapalı")) {
      return const Icon(
        Icons.cloud,
        color: Colors.grey,
        size: 24,
      );
    } else {
      return const Icon(
        Icons.cloud,
        color: Colors.grey,
        size: 24,
      );
    }
  }

  String getCloth(String weather) {
    if (weather.contains("bulut")) {
      return "Bulutlu hava, hafif mont önerilir.";
    } else if (weather.contains("güneş") || weather.contains("açık")) {
      return "Güneşli hava, şapka ve güneş gözlüğü kullanın.";
    } else if (weather.contains("yağmur")) {
      return "Yağmurlu hava, şemsiye ve yağmurluk alın.";
    } else if (weather.contains("kar")) {
      return "Karlı hava, kalın mont ve eldiven alın.";
    } else if (weather.contains("kapalı")) {
      return "Kapalı hava, hafif mont önerilir.";
    } else {
      return "Kapalı hava, hafif mont önerilir.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: appPrimaryColor,
        body: SafeArea(
          child: BlocConsumer<RouteBloc, RouteState>(
            listener: (context, state) {
              if (state.routeCities.isNotEmpty &&
                  state.routeCoordinates.isNotEmpty) {
                for (int i = 0; i < state.routeCities.length; i++) {
                  FlutterLocalNotificationsPlugin().show(
                    i,
                    "${state.routeCities[i].name} Hava Durumu",
                    "${state.routeCities[i].name} şehrinde hava ${state.routeCities[i].weather}, sıcaklık: ${(state.routeCities[i].temperature - 273).toInt()}°C. ${getCloth(state.routeCities[i].weather)}",
                    NotificationDetails(
                      android: AndroidNotificationDetails(
                        'channel id',
                        'channel name',
                      ),
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state.routeCoordinates.isEmpty || state.routeCities.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        "Veriler yükleniyor...",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                  ),
                );
              }

              final temps =
                  state.routeCities.map((e) => e.temperature).toList();
              double total = temps.reduce((a, b) => a + b);
              double averageTemp = total / temps.length;

              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      height: MediaQuery.sizeOf(context).height / 1.5,
                      child: FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          zoom: 9,
                          center: state.routeCoordinates
                              .map((e) => LatLng(e[1], e[0]))
                              .first,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'dev.fleaflet.flutter_map.example',
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: state.routeCoordinates
                                    .map((e) => LatLng(e[1], e[0]))
                                    .toList(),
                                strokeWidth: 4.0,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(
                                  state.routeCoordinates.first[1],
                                  state.routeCoordinates.first[0],
                                ),
                                builder: (context) => const Icon(
                                  Icons.circle,
                                  color: Colors.blue,
                                  size: 12.0,
                                ),
                              ),
                              Marker(
                                width: 80.0,
                                height: 80.0,
                                point: LatLng(
                                  state.routeCoordinates.last[1],
                                  state.routeCoordinates.last[0],
                                ),
                                builder: (context) => const Icon(
                                  Icons.circle,
                                  color: Colors.red,
                                  size: 12.0,
                                ),
                              ),
                            ],
                          ),
                          if (showWeather)
                            for (final city in state.routeCities)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    height: 120,
                                    width: MediaQuery.sizeOf(context).width / 4,
                                    point: LatLng(
                                      double.parse(city.lat),
                                      double.parse(city.lon),
                                    ),
                                    builder: (context) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              city.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              "Hava ${city.weather}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            getWeatherIcon(city.weather),
                                            Text(
                                              "${(city.temperature - 273).toInt()}°C",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: MediaQuery.sizeOf(context).height / 10,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: appPrimaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                context.read<RouteBloc>().add(RouteInitial());
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Center(
                            child: Text(
                              'Rotan için Hava Durumları',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: appPrimaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 12),
                              Container(
                                height: 5,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                              ),
                              SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            "Başlangıç: ${state.firstCity!.name}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Varış: ${state.secondCity!.name}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Ortalama sıcaklık\n${(averageTemp - 273).toInt()}°C",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              showCommentsPopup(
                                                context,
                                                commentsName:
                                                    "${state.firstCity!.name} - ${state.secondCity!.name}",
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.message),
                                                Expanded(
                                                  child: Text(
                                                    "Rota hakkında yorum yap",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final data in state.routeCities) ...[
                                    InkWell(
                                      onTap: () {
                                        mapController.move(
                                          LatLng(
                                            double.parse(data.lat),
                                            double.parse(data.lon),
                                          ),
                                          9,
                                        );
                                        setState(() {
                                          selectedIndex =
                                              state.routeCities.indexOf(data);
                                        });
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        padding: EdgeInsets.all(4),
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                3.5,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: selectedIndex ==
                                                    state.routeCities
                                                        .indexOf(data)
                                                ? Colors.purple
                                                : Colors.transparent,
                                            width: 4,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              data.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            getWeatherIcon(data.weather),
                                            SizedBox(height: 4),
                                            Text(
                                              "Hava ${data.weather}",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "${(data.temperature - 273).toInt()}°C",
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

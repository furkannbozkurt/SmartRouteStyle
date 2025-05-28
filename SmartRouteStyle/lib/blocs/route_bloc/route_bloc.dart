import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_routes/models/city_model.dart';
import 'package:http/http.dart' as http;

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  RouteBloc() : super(RouteState.initial()) {
    on<RouteInitial>(
      (event, emit) async {
        final fileData = await rootBundle.loadString('datas/cities.json');
        final jsonData = json.decode(fileData) as List;

        final List<City> cities =
            jsonData.map((e) => City.fromJson(e)).toList();

        emit(RouteState.initial());
        emit(state.copyWith(cities: cities));
      },
    );
    on<RouteFirstCitySelected>(
      (event, emit) async {
        emit(state.copyWith(firstCity: event.city));
      },
    );
    on<RouteSecondCitySelected>(
      (event, emit) async {
        emit(state.copyWith(secondCity: event.city));
      },
    );
    on<RouteNavigate>(
      (event, emit) async {
        assert(state.isReadyToNavigate);

        final startLat = state.firstCity!.lat;
        final startLng = state.firstCity!.lon;

        final endLat = state.secondCity!.lat;
        final endLng = state.secondCity!.lon;
        final routesUrl =
            "https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf6248150c2c456d8f4265a20cfdb000ca4c20&start=$startLng,$startLat&end=$endLng,$endLat";

        final response = await http.get(Uri.parse(routesUrl));
        if (response.statusCode != 200) {
          return;
        }

        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final coordinates =
            jsonData['features'][0]['geometry']['coordinates'] as List;

        emit(state.copyWith(routeCoordinates: coordinates));

        final lenght = coordinates.length;
        final middleIndex = lenght ~/ 2;
        final midMidIndex = middleIndex ~/ 2;
        final newCoordinates = [
          coordinates[0],
          coordinates[midMidIndex],
          coordinates[middleIndex],
          coordinates[lenght - midMidIndex],
          coordinates.last,
        ];

        List<RouteCity> routeCities = [];

        for (var i = 0; i < newCoordinates.length; i++) {
          final lat = newCoordinates[i][1];
          final lon = newCoordinates[i][0];

          final url =
              "https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json";

          final response = await http.get(Uri.parse(url));

          if (response.statusCode != 200) {
            continue;
          }

          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          final residential = jsonData['address']['province'] as String?;

          if (residential == null) continue;

          final weatherUrl =
              "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&lang=tr&appid=40b092947e9de20865e9bdca106095bf";

          final weatherResponse = await http.get(Uri.parse(weatherUrl));

          if (weatherResponse.statusCode != 200) {
            continue;
          }

          final weatherJsonData =
              json.decode(weatherResponse.body) as Map<String, dynamic>;
          final temperature = weatherJsonData['main']['temp'] as double;
          final weather =
              weatherJsonData['weather'][0]['description'] as String;

          routeCities.add(
            RouteCity(
              name: residential,
              lat: lat.toString(),
              lon: lon.toString(),
              temperature: temperature,
              weather: weather,
            ),
          );
        }

        emit(state.copyWith(routeCities: routeCities));
      },
    );
  }
}

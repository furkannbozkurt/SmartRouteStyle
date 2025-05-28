part of 'route_bloc.dart';

class RouteState extends Equatable {
  const RouteState({
    required this.cities,
    required this.firstCity,
    required this.secondCity,
    required this.routeCities,
    required this.routeCoordinates,
  });

  final List<City> cities;
  final City? firstCity;
  final City? secondCity;

  final List<RouteCity> routeCities;
  final List routeCoordinates;

  factory RouteState.initial() {
    return const RouteState(
      cities: [],
      firstCity: null,
      secondCity: null,
      routeCities: [],
      routeCoordinates: [],
    );
  }

  RouteState copyWith({
    List<City>? cities,
    City? firstCity,
    City? secondCity,
    List<RouteCity>? routeCities,
    List? routeCoordinates,
  }) {
    return RouteState(
      cities: cities ?? this.cities,
      firstCity: firstCity ?? this.firstCity,
      secondCity: secondCity ?? this.secondCity,
      routeCities: routeCities ?? this.routeCities,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
    );
  }

  List<City> get availableCities {
    final selectedCities = [firstCity, secondCity];
    return cities
        .where((element) => !selectedCities.contains(element))
        .toList();
  }

  bool get isReadyToNavigate {
    return firstCity != null && secondCity != null;
  }

  @override
  List<Object?> get props => [
        cities,
        firstCity,
        secondCity,
        routeCities,
        routeCoordinates,
      ];
}

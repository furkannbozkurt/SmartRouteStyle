part of 'route_bloc.dart';

class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object> get props => [];
}

class RouteInitial extends RouteEvent {}

class RouteFirstCitySelected extends RouteEvent {
  final City city;

  const RouteFirstCitySelected(this.city);

  @override
  List<Object> get props => [city];
}

class RouteSecondCitySelected extends RouteEvent {
  final City city;

  const RouteSecondCitySelected(this.city);

  @override
  List<Object> get props => [city];
}

class RouteNavigate extends RouteEvent {}

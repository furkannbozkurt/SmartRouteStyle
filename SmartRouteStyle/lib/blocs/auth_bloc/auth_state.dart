part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState({
    required this.userOrFailure,
  });
  final Option<Either<Unit, User>> userOrFailure;

  factory AuthState.initial() => AuthState(
        userOrFailure: none(),
      );

  AuthState copyWith({
    Option<Either<Unit, User>>? userOrFailure,
  }) {
    return AuthState(
      userOrFailure: userOrFailure ?? this.userOrFailure,
    );
  }

  @override
  List<Object> get props => [
        userOrFailure,
      ];
}

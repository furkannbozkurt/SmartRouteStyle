import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  AuthBloc(
    this._firebaseAuth,
  ) : super(AuthState.initial()) {
    on<AuthInit>((event, emit) async {
      emit(state.copyWith(userOrFailure: none()));
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(state.copyWith(userOrFailure: some(right(user))));
      } else {
        emit(state.copyWith(userOrFailure: some(left(unit))));
      }
    });
    on<AuthLogin>((event, emit) async {
      emit(state.copyWith(userOrFailure: none()));
      try {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(state.copyWith(userOrFailure: some(right(userCredential.user!))));
      } catch (e) {
        emit(state.copyWith(userOrFailure: some(left(unit))));
      }
    });
    on<AuthRegister>((event, emit) async {
      emit(state.copyWith(userOrFailure: none()));
      try {
        final userCredential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(state.copyWith(userOrFailure: some(right(userCredential.user!))));
      } catch (e) {
        emit(state.copyWith(userOrFailure: some(left(unit))));
      }
    });
    on<AuthLogout>((event, emit) async {
      emit(state.copyWith(userOrFailure: none()));
      try {
        await _firebaseAuth.signOut();
        emit(state.copyWith(userOrFailure: some(left(unit))));
      } catch (e) {
        emit(state.copyWith(
            userOrFailure: some(right(_firebaseAuth.currentUser!))));
      }
    });
  }
}

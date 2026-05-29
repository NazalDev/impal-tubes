import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:volync/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/core/common/entities/user.dart';
import 'package:volync/features/auth/domain/usecase/current_user.dart';
import 'package:volync/features/auth/domain/usecase/edit_profile_usecase.dart';
import 'package:volync/features/auth/domain/usecase/user_login.dart';
import 'package:volync/features/auth/domain/usecase/user_sign_up.dart';
import 'package:volync/features/auth/domain/usecase/reset_password_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  final EditProfileUsecase _editProfile;
  final ResetPasswordUsecase _resetPassword;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required EditProfileUsecase editProfile,
    required ResetPasswordUsecase resetPassword,
  }) : _userLogin = userLogin,
       _userSignUp = userSignUp,
       _currentUser = currentUser,
       _appUserCubit = appUserCubit,
       _editProfile = editProfile,
       _resetPassword = resetPassword,
       super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthEditProfile>(_onEditProfile);
    on<AuthResetPassword>(_onResetPassword);
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _currentUser(NoParams());
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(
        username: event.username,
        email: event.email,
        password: event.password,
      ),
    );
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onEditProfile(AuthEditProfile event, Emitter<AuthState> emit) async {
    emit(AuthEditProfileLoading());
    final res = await _editProfile(
      EditProfileParams(
        username: event.username,
        avatarFile: event.avatarFile,
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ),
    );
    res.fold(
      (l) => emit(AuthEditProfileFailure(l.message)),
      (_) async {
        emit(AuthEditProfileSuccess());
        final userRes = await _currentUser(NoParams());
        userRes.fold((_) {}, (user) => _appUserCubit.updateUser(user));
      },
    );
  }

  void _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthResetPasswordLoading());
    final res = await _resetPassword(
      ResetPasswordParams(
        username: event.username,
        email: event.email,
        newPassword: event.newPassword,
      ),
    );
    res.fold(
      (l) => emit(AuthResetPasswordFailure(l.message)),
      (_) => emit(AuthResetPasswordSuccess()),
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}

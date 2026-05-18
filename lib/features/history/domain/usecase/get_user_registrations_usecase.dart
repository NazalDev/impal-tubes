import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/history/domain/entity/user_registration_entity.dart';
import 'package:volync/features/history/domain/repository/history_repository.dart';

// ── Get user registrations ────────────────────────────────────────────────────
class GetUserRegistrationsUseCase
    implements UseCase<List<UserRegistrationEntity>, GetUserRegistrationsParams> {
  final HistoryRepository _repository;
  GetUserRegistrationsUseCase(this._repository);

  @override
  Future<Either<Failure, List<UserRegistrationEntity>>> call(
    GetUserRegistrationsParams params,
  ) {
    return _repository.getUserRegistrations(userId: params.userId);
  }
}

class GetUserRegistrationsParams {
  final String userId;
  const GetUserRegistrationsParams({required this.userId});
}

// ── Cancel registration ───────────────────────────────────────────────────────
class CancelRegistrationUseCase
    implements UseCase<void, CancelRegistrationParams> {
  final HistoryRepository _repository;
  CancelRegistrationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(CancelRegistrationParams params) {
    return _repository.cancelRegistration(
      registrationId: params.registrationId,
    );
  }
}

class CancelRegistrationParams {
  final String registrationId;
  const CancelRegistrationParams({required this.registrationId});
}

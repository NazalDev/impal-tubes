import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/core/usercase/usecase.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class UpdateEventUseCase implements UseCase<void, UpdateEventParams> {
  final ProfileRepository _profileRepository;

  UpdateEventUseCase(this._profileRepository);

  @override
  Future<Either<Failure, void>> call(UpdateEventParams params) {
    return _profileRepository.updateEvent(
      eventId: params.eventId,
      data: params.data,
      imageFile: params.imageFile,
    );
  }
}

class UpdateEventParams {
  final String eventId;
  final Map<String, dynamic> data;
  /// Optional local image file.  If set, it is uploaded to Storage and the
  /// resulting URL is automatically added to [data] before the DB update.
  final File? imageFile;

  const UpdateEventParams({
    required this.eventId,
    required this.data,
    this.imageFile,
  });
}

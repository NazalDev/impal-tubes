import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/domain/entity/profile_member_entity.dart';

abstract interface class ProfileRepository {
  // Events
  Future<Either<Failure, List<ProfileEventEntity>>> getUserEvents({
    required String userId,
  });

  /// [imageFile] — if provided, uploads to Storage and includes the URL in
  /// the update payload automatically.
  Future<Either<Failure, void>> updateEvent({
    required String eventId,
    required Map<String, dynamic> data,
    File? imageFile,
  });

  Future<Either<Failure, void>> deleteEvent({required String eventId});

  Future<Either<Failure, void>> cancelEvent({required String eventId});

  // Members
  Future<Either<Failure, List<ProfileMemberEntity>>> getEventMembers({
    required String eventId,
  });

  Future<Either<Failure, void>> updateMemberStatus({
    required String registrationId,
    required String status,
  });

  // Auth
  Future<Either<Failure, void>> signOut();
}

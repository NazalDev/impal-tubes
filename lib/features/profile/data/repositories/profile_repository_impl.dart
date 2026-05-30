import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/core/errors/failure.dart';
import 'package:volync/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/domain/entity/profile_member_entity.dart';
import 'package:volync/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ProfileEventEntity>>> getUserEvents({
    required String userId,
  }) async {
    try {
      final events = await _remoteDataSource.getUserEvents(userId: userId);
      return right(events);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateEvent({
    required String eventId,
    required Map<String, dynamic> data,
    File? imageFile,
  }) async {
    try {
      // 1. Upload image if provided, then inject the URL into the data map
      final imageUrl = await _remoteDataSource.uploadEventImage(
        eventId: eventId,
        imageFile: imageFile,
      );

      final payload = Map<String, dynamic>.from(data);
      if (imageUrl != null) payload['image_url'] = imageUrl;

      // 2. Persist all fields in one DB update
      await _remoteDataSource.updateEvent(eventId: eventId, data: payload);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent({required String eventId}) async {
    try {
      await _remoteDataSource.deleteEvent(eventId: eventId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelEvent({required String eventId}) async {
    try {
      await _remoteDataSource.cancelEvent(eventId: eventId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ProfileMemberEntity>>> getEventMembers({
    required String eventId,
  }) async {
    try {
      final members = await _remoteDataSource.getEventMembers(eventId: eventId);
      return right(members);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateMemberStatus({
    required String registrationId,
    required String status,
  }) async {
    try {
      await _remoteDataSource.updateMemberStatus(
        registrationId: registrationId,
        status: status,
      );
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}

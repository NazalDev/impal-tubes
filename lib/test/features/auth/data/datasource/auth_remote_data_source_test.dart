import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/auth/data/datasource/auth_remote_data_source.dart';

// 1. Setup Mock Instan untuk Client Utama
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// 2. FAKE CLASS KHUSUS: Menggantikan filter & transform builder Supabase secara natural
class FakePostgrestBuilder extends Fake
    implements
        PostgrestFilterBuilder<PostgrestList>,
        PostgrestTransformBuilder<PostgrestList> {
  @override
  PostgrestFilterBuilder<PostgrestList> eq(String column, Object value) => this;

  @override
  Future<U> then<U>(
    FutureOr<U> Function(PostgrestList value) onValue, {
    Function? onError,
  }) {
    // Menyuplai list kosong [] sebagai representasi database sukses, lalu di-cast ke tipe U yang diminta
    return Future.value(onValue([]));
  }
}

// Mock untuk respons objek auth internal Supabase
class MockUserResponse extends Mock implements UserResponse {}

class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late FakePostgrestBuilder fakePostgrestBuilder;
  late AuthRemoteDataSourceImpl dataSource;

  const targetUserId = '235753d3-37f7-47ad-b0e1-7a0e20b9c52a';

  setUpAll(() {
    registerFallbackValue(UserAttributes());
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    fakePostgrestBuilder = FakePostgrestBuilder();

    dataSource = AuthRemoteDataSourceImpl(mockClient);

    // Menyusun mock chain database menggunakan gabungan Mock dan Fake Class
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockClient.from(any())).thenAnswer((_) => mockQueryBuilder);
    when(
      () => mockQueryBuilder.update(any()),
    ).thenAnswer((_) => fakePostgrestBuilder);
  });

  User createMockUser({required String? email}) {
    return User(
      id: targetUserId,
      appMetadata: const {
        "provider": "email",
        "providers": ["email"],
      },
      userMetadata: const {
        "sub": targetUserId,
        "role": "Pengguna",
        "username": "datatestBaru2",
        "avatar_url":
            "https://tmdizufmxohantddmstq.supabase.co/storage/v1/object/public/avatars/235753d3-37f7-47ad-b0e1-7a0e20b9c52a/profiles",
        "email_verified": true,
        "phone_verified": false,
      },
      aud: 'authenticated',
      email: email,
      createdAt: DateTime.now().toIso8601String(),
    );
  }

  group(
    'editProfile - 11 Skenario Jalur Pengujian Lengkap (Basis Path Testing)',
    () {
      test('Path 1', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: null,
            newPassword: null,
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('Path 2', () async {
        final userWithEmail = createMockUser(email: 'test@mail.com');
        final userWithoutEmail = createMockUser(email: null);
        final mockAuthResponse = MockAuthResponse();

        when(() => mockAuthResponse.user).thenReturn(userWithoutEmail);
        when(() => mockAuth.currentUser).thenReturn(userWithEmail);
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => mockAuthResponse);

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: 'password',
            newPassword: 'passwordnew',
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('Path 3', () async {
        final user = createMockUser(email: 'datatest@gmail.com');
        when(() => mockAuth.currentUser).thenReturn(user);
        final mockAuthResponse = MockAuthResponse();
        when(() => mockAuthResponse.user).thenReturn(user);

        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => mockAuthResponse);

        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(const AuthException('Invalid credentials'));

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: 'passwordsalah',
            newPassword: 'passwordnew',
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('Path 4', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        final mockRefreshResponse = MockAuthResponse();
        when(() => mockRefreshResponse.user).thenReturn(user);
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => mockRefreshResponse);

        final mockSignInResponse = MockAuthResponse();
        when(() => mockSignInResponse.user).thenReturn(null);

        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockSignInResponse);

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: 'passwordsalah',
            newPassword: 'passwordnew',
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('Path 5', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        final mockRefreshResponse = MockAuthResponse();
        when(() => mockRefreshResponse.user).thenReturn(user);
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => mockRefreshResponse);

        final mockSignInResponse = MockAuthResponse();
        when(() => mockSignInResponse.user).thenReturn(user);
        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockSignInResponse);

        final mockUserResponse = MockUserResponse();
        when(() => mockUserResponse.user).thenReturn(null);
        when(
          () => mockAuth.updateUser(any()),
        ).thenAnswer((_) async => mockUserResponse);

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: 'password',
            newPassword: 'passwordnew',
          ),
          throwsA(isA<ServerException>()),
        );
      });

      test('Path 6', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        final mockRefreshResponse = MockAuthResponse();
        when(() => mockRefreshResponse.user).thenReturn(user);
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => mockRefreshResponse);

        final mockSignInResponse = MockAuthResponse();
        when(() => mockSignInResponse.user).thenReturn(user);
        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => mockSignInResponse);

        final mockUserResponse = MockUserResponse();
        when(() => mockUserResponse.user).thenReturn(user);
        when(
          () => mockAuth.updateUser(any()),
        ).thenAnswer((_) async => mockUserResponse);

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: 'password',
            newPassword: 'passwordNew',
          ),
          completes,
        );
      });

      test('Path 7', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: null,
            oldPassword: null,
            newPassword: null,
          ),
          completes,
        );
      });

      test('Path 8', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        final mockUserResponse = MockUserResponse();
        when(() => mockUserResponse.user).thenReturn(user);
        when(
          () => mockAuth.updateUser(any()),
        ).thenAnswer((_) async => mockUserResponse);

        await expectLater(
          dataSource.editProfile(
            username: 'datatestNew',
            avatarUrl: null,
            oldPassword: null,
            newPassword: null,
          ),
          completes,
        );

        verify(() => mockClient.from('user')).called(1);
        verify(
          () => mockQueryBuilder.update({'username': 'datatestNew'}),
        ).called(1);
      });

      test('Path 9', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        final mockUserResponse = MockUserResponse();
        when(() => mockUserResponse.user).thenReturn(user);
        when(
          () => mockAuth.updateUser(any()),
        ).thenAnswer((_) async => mockUserResponse);

        const newAvatar =
            'https://tmdizufmxohantddmstq.supabase.co/storage/v1/object/public/avatars/235753d3-37f7-47ad-b0e1-7a0e20b9c52a/profiles';

        await expectLater(
          dataSource.editProfile(
            username: null,
            avatarUrl: newAvatar,
            oldPassword: null,
            newPassword: null,
          ),
          completes,
        );

        verify(
          () => mockQueryBuilder.update({'avatar_url': newAvatar}),
        ).called(1);
      });

      test('Path 10', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        final mockUserResponse = MockUserResponse();
        when(() => mockUserResponse.user).thenReturn(user);
        when(
          () => mockAuth.updateUser(any()),
        ).thenAnswer((_) async => mockUserResponse);

        const newAvatar =
            'https://tmdizufmxohantddmstq.supabase.co/storage/v1/object/public/avatars/235753d3-37f7-47ad-b0e1-7a0e20b9c52a/profiles';

        await expectLater(
          dataSource.editProfile(
            username: 'datatestNew',
            avatarUrl: newAvatar,
            oldPassword: null,
            newPassword: null,
          ),
          completes,
        );

        verify(
          () => mockQueryBuilder.update({
            'username': 'datatestNew',
            'avatar_url': newAvatar,
          }),
        ).called(1);
      });

      test('Path 11', () async {
        final user = createMockUser(email: 'datatest@mail.com');
        when(() => mockAuth.currentUser).thenReturn(user);

        when(
          () => mockClient.from('user'),
        ).thenThrow(Exception('Connection timeout'));

        expect(
          () => dataSource.editProfile(
            username: 'datatestNew',
            avatarUrl: null,
            oldPassword: null,
            newPassword: null,
          ),
          throwsA(isA<ServerException>()),
        );
      });
    },
  );
}

// ignore_for_file: subtype_of_sealed_class
//
// ═══════════════════════════════════════════════════════════════════════════════
// WHITE BOX TEST — AuthRemoteDataSourceImpl.editProfile()
// Dokumen Referensi : DUPL-001 VOLYNC — Kelompok 1
// Nama Class        : AuthRemoteDataSourceImpl
// Nama Method       : editProfile({String? username, String? avatarUrl,
//                       String? oldPassword, String? newPassword})
// Lokasi File       : lib/features/auth/data/datasource/auth_remote_data_source.dart
//
// Cyclomatic Complexity V(G) = 11
// Decision Nodes            : N3, N4, N7, N9, N10, N12, N14, N15, N16, N19
// Total Path Diuji          : 11 (P1 – P11)
//
// Dependency:
//   flutter_test: ^1.0.0
//   mocktail: ^1.0.0
//   supabase_flutter: ^2.x  (postgrest ^2.7.0, gotrue ^2.x)
//
// Cara menjalankan:
//   flutter test test/features/auth/data/datasource/auth_remote_data_source_test.dart
//
// CHANGELOG FIXES:
//   v1 — Initial
//   v2 — UserResponse pakai fromJson(), .eq() stub pakai thenReturn
//   v3 — registerFallbackValue(UserAttributes) di setUpAll()
//        .update() mengembalikan Future → pakai thenAnswer bukan thenReturn
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/errors/exceptions.dart';
import 'package:volync/features/auth/data/datasource/auth_remote_data_source.dart';

// ─── Mock Classes ─────────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

// ─── Fake untuk registerFallbackValue ────────────────────────────────────────
// mocktail memerlukan fallback value untuk setiap custom type yang dipakai
// dengan any() / captureAny(). UserAttributes adalah custom type dari gotrue.

class FakeUserAttributes extends Fake implements UserAttributes {}

// ─── Helper: Membuat dummy Supabase User ─────────────────────────────────────

/// Membuat objek [User] palsu untuk keperluan mock / stub.
User _fakeUser({required String id, String? email}) {
  return User(
    id: id,
    appMetadata: {},
    userMetadata: {'username': 'datatest', 'role': 'Pengguna'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
    email: email,
  );
}

// ─── Konstanta Data Uji (sesuai tabel path di dokumen DUPL) ──────────────────

const String _kUserId = '235753d3-37f7-47ad-b0e1-7a0e20b9c52a';
const String _kEmail = 'datatest@gmail.com';
const String _kOldPassword = 'password';
const String _kWrongPassword = 'passwordsalah';
const String _kNewPassword = 'passwordnew';
const String _kUsername = 'datatestNew';
const String _kAvatarUrl =
    'https://tmdizufmxohantddmstq.supabase.co/storage/v1/object'
    '/public/avatars/$_kUserId/profiles';

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN TEST SUITE
// ═══════════════════════════════════════════════════════════════════════════════

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;

  // FIX v3: Daftarkan fallback value untuk UserAttributes SEBELUM semua test.
  // mocktail membutuhkan ini agar any<UserAttributes>() bisa bekerja
  // di sound null-safe mode.
  setUpAll(() {
    registerFallbackValue(FakeUserAttributes());
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    dataSource = AuthRemoteDataSourceImpl(mockSupabase);
  });

  tearDown(() => resetMocktailState());

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP: editProfile() — White Box Basis Path Testing
  // ═══════════════════════════════════════════════════════════════════════════
  group('editProfile() — White Box Basis Path Testing (DUPL-001)', () {
    // ── Shared helper: stub DB update chain (.from → .update → .eq) ──────────
    //
    // Supabase query builder menggunakan fluent/chaining API:
    //   supabase.from('user').update({...}).eq('id', userId)
    //
    // FIX v3: .update() mengembalikan PostgrestFilterBuilder yang JUGA
    // mengimplementasikan Future<T>. mocktail mendeteksi ini dan melarang
    // thenReturn() untuk tipe Future. Solusi: gunakan thenAnswer() dengan
    // nilai sync agar chain tetap bisa dilanjutkan.
    void stubDbUpdateSuccess(
      MockSupabaseQueryBuilder mockBuilder,
      MockPostgrestFilterBuilder mockFilter,
    ) {
      when(() => mockSupabase.from('user')).thenReturn(mockBuilder);

      // FIX v3: .update() → thenAnswer (bukan thenReturn) karena
      // PostgrestFilterBuilder implements Future
      when(
        () => mockBuilder.update(any<Map<String, dynamic>>()),
      ).thenAnswer((_) => mockFilter);

      // .eq() juga returns PostgrestFilterBuilder → thenAnswer
      when(
        () => mockFilter.eq('id', any<String>()),
      ).thenAnswer((_) => mockFilter);

      // Stub Future interface agar `await mockFilter` resolve tanpa error
      when(
        () => mockFilter.then<dynamic>(any(), onError: any(named: 'onError')),
      ).thenAnswer((inv) {
        final onValue = inv.positionalArguments[0] as dynamic Function(dynamic);
        return Future.value(onValue(<dynamic>[]));
      });
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 1
    // Jalur  : N1 → N2 → N3(ya) → N19 → N20 → N21
    // Kondisi: userId == null → pengguna tidak login / sesi habis
    // Input  : semua null
    // Output : throw ServerException('Not authenticated')
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P1] userId null → throw ServerException("Not authenticated")',
      () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        await expectLater(
          () => dataSource.editProfile(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              'Not authenticated',
            ),
          ),
        );

        // Verifikasi: tidak ada operasi lanjutan
        verifyNever(() => mockAuth.refreshSession());
        verifyNever(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
        verifyNever(() => mockAuth.updateUser(any<UserAttributes>()));
        verifyNever(() => mockSupabase.from(any()));
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 2
    // Jalur  : N1 → N2 → N3(tdk) → N4(ya) → N5 → N6 → N7(ya) → N19 → N20 → N21
    // Kondisi: userId ada, ganti password diminta, email null setelah refreshSession
    // Input  : oldPassword='password', newPassword='passwordnew'
    // Mock   : currentUser.email = null
    // Output : throw ServerException('Tidak dapat mengambil email pengguna.')
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P2] email null setelah refreshSession '
      '→ throw ServerException("Tidak dapat mengambil email pengguna.")',
      () async {
        // Arrange
        final fakeUser = _fakeUser(id: _kUserId, email: null);
        when(() => mockAuth.currentUser).thenReturn(fakeUser);
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => AuthResponse(session: null));

        // Act & Assert
        await expectLater(
          () => dataSource.editProfile(
            oldPassword: _kOldPassword,
            newPassword: _kNewPassword,
          ),
          throwsA(
            isA<ServerException>().having(
              (e) => e.message,
              'message',
              contains('Tidak dapat mengambil email pengguna'),
            ),
          ),
        );

        verify(() => mockAuth.refreshSession()).called(1);
        verifyNever(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 3
    // Jalur  : N1 → N2 → N3(tdk) → N4(ya) → N5 → N6 → N7(tdk) → N8
    //          → N10(catch AuthException) → N19 → N20 → N21
    // Kondisi: signInWithPassword melempar AuthException (password lama salah)
    // Input  : oldPassword='passwordsalah', newPassword='passwordnew'
    // Mock   : signInWithPassword → throw AuthException('Invalid credentials')
    // Output : throw ServerException('Password lama tidak sesuai: Invalid credentials')
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test('[P3] signInWithPassword throw AuthException '
        '→ ServerException("Password lama tidak sesuai: ...")', () async {
      // Arrange
      final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(
        () => mockAuth.refreshSession(),
      ).thenAnswer((_) async => AuthResponse(session: null));
      when(
        () => mockAuth.signInWithPassword(
          email: _kEmail,
          password: _kWrongPassword,
        ),
      ).thenThrow(const AuthException('Invalid credentials'));

      // Act & Assert
      await expectLater(
        () => dataSource.editProfile(
          oldPassword: _kWrongPassword,
          newPassword: _kNewPassword,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Password lama tidak sesuai'),
          ),
        ),
      );

      verify(
        () => mockAuth.signInWithPassword(
          email: _kEmail,
          password: _kWrongPassword,
        ),
      ).called(1);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 4
    // Jalur  : N1 → N2 → N3(tdk) → N4(ya) → N5 → N6 → N7(tdk) → N8
    //          → N9(ya: reAuth.user==null) → N19 → N20 → N21
    // Kondisi: signInWithPassword berhasil tapi AuthResponse.user == null
    // Input  : oldPassword='passwordsalah', newPassword='passwordnew'
    // Mock   : signInWithPassword → AuthResponse(user: null)
    // Output : throw ServerException('Password lama tidak sesuai.')
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test('[P4] reAuth.user == null '
        '→ throw ServerException("Password lama tidak sesuai.")', () async {
      // Arrange
      final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(
        () => mockAuth.refreshSession(),
      ).thenAnswer((_) async => AuthResponse(session: null));
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: null, session: null));

      // Act & Assert
      await expectLater(
        () => dataSource.editProfile(
          oldPassword: _kWrongPassword,
          newPassword: _kNewPassword,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Password lama tidak sesuai.',
          ),
        ),
      );

      // updateUser tidak boleh dipanggil karena gagal di N9
      verifyNever(() => mockAuth.updateUser(any<UserAttributes>()));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 5
    // Jalur  : N1 → N2 → N3(tdk) → N4(ya) → N5 → N6 → N7(tdk) → N8
    //          → N9(tdk) → N11 → N12(ya: result.user==null) → N19 → N20 → N21
    // Kondisi: reAuth berhasil, tapi updateUser(password) → user==null
    // Input  : oldPassword='password', newPassword='passwordnew'
    // Mock   : updateUser → UserResponse.fromJson({}) → user == null
    // Output : throw ServerException('Gagal memperbarui password.')
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test('[P5] updateUser(password) → result.user == null '
        '→ throw ServerException("Gagal memperbarui password.")', () async {
      // Arrange
      final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(
        () => mockAuth.refreshSession(),
      ).thenAnswer((_) async => AuthResponse(session: null));
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: fakeUser, session: null));
      // fromJson({}) → user field kosong → UserResponse.user == null
      when(
        () => mockAuth.updateUser(any<UserAttributes>()),
      ).thenAnswer((_) async => UserResponse.fromJson({}));

      // Act & Assert
      await expectLater(
        () => dataSource.editProfile(
          oldPassword: _kOldPassword,
          newPassword: _kNewPassword,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Gagal memperbarui password.',
          ),
        ),
      );

      verify(() => mockAuth.updateUser(any<UserAttributes>())).called(1);
      verifyNever(() => mockSupabase.from(any()));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 6
    // Jalur  : N1 → N2 → N3(tdk) → N4(ya) → N5 → N6 → N7(tdk) → N8
    //          → N9(tdk) → N11 → N12(tdk) → N13 → N14(tdk) → N15(tdk)
    //          → N16(ya: kosong) → N21
    // Kondisi: Ganti password sukses, username & avatarUrl null → updates kosong
    // Input  : oldPassword='password', newPassword='passwordnew'
    // Output : void, DB tidak disentuh
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P6] Ganti password sukses, updates kosong (username & avatarUrl null) '
      '→ void, DB tidak disentuh',
      () async {
        // Arrange
        final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
        when(() => mockAuth.currentUser).thenReturn(fakeUser);
        when(
          () => mockAuth.refreshSession(),
        ).thenAnswer((_) async => AuthResponse(session: null));
        when(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => AuthResponse(user: fakeUser, session: null));
        // fromJson({'user': ...}) → UserResponse.user != null (sukses)
        when(() => mockAuth.updateUser(any<UserAttributes>())).thenAnswer(
          (_) async => UserResponse.fromJson({'user': fakeUser.toJson()}),
        );

        // Act & Assert
        await expectLater(
          dataSource.editProfile(
            oldPassword: _kOldPassword,
            newPassword: _kNewPassword,
          ),
          completes,
        );

        verify(() => mockAuth.updateUser(any<UserAttributes>())).called(1);
        verifyNever(() => mockSupabase.from(any()));
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 7
    // Jalur  : N1 → N2 → N3(tdk) → N4(tdk) → N13 → N14(tdk)
    //          → N15(tdk) → N16(ya: kosong) → N21
    // Kondisi: Semua parameter null — tidak ada operasi apapun
    // Input  : semua null
    // Output : void, tidak ada call ke DB atau auth
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P7] Semua parameter null → void, tidak ada DB atau auth call',
      () async {
        // Arrange
        final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
        when(() => mockAuth.currentUser).thenReturn(fakeUser);

        // Act & Assert
        await expectLater(dataSource.editProfile(), completes);

        verifyNever(() => mockAuth.refreshSession());
        verifyNever(
          () => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
        verifyNever(() => mockAuth.updateUser(any<UserAttributes>()));
        verifyNever(() => mockSupabase.from(any()));
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 8
    // Jalur  : N1 → N2 → N3(tdk) → N4(tdk) → N13 → N14(ya) → N15(tdk)
    //          → N16(tdk: tidak kosong) → N17 → N18 → N21
    // Kondisi: Hanya update username, avatarUrl null
    // Input  : username='datatestNew', avatarUrl=null
    // Output : void (hanya username diupdate)
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P8] Update username saja (avatarUrl null) → void, DB diupdate',
      () async {
        // Arrange
        final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
        final mockBuilder = MockSupabaseQueryBuilder();
        final mockFilter = MockPostgrestFilterBuilder();
        stubDbUpdateSuccess(mockBuilder, mockFilter);
        when(() => mockAuth.currentUser).thenReturn(fakeUser);
        when(() => mockAuth.updateUser(any<UserAttributes>())).thenAnswer(
          (_) async => UserResponse.fromJson({'user': fakeUser.toJson()}),
        );

        // Act & Assert
        await expectLater(
          dataSource.editProfile(username: _kUsername),
          completes,
        );

        verify(() => mockBuilder.update({'username': _kUsername})).called(1);
        verify(() => mockAuth.updateUser(any<UserAttributes>())).called(1);
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 9
    // Jalur  : N1 → N2 → N3(tdk) → N4(tdk) → N13 → N14(tdk)
    //          → N15(ya) → N16(tdk: tidak kosong) → N17 → N18 → N21
    // Kondisi: Hanya update avatarUrl, username null
    // Input  : username=null, avatarUrl='https://...supabase.co/.../profiles'
    // Output : void (hanya avatar_url diupdate)
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test(
      '[P9] Update avatar saja (username null) → void, DB diupdate',
      () async {
        // Arrange
        final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
        final mockBuilder = MockSupabaseQueryBuilder();
        final mockFilter = MockPostgrestFilterBuilder();
        stubDbUpdateSuccess(mockBuilder, mockFilter);
        when(() => mockAuth.currentUser).thenReturn(fakeUser);
        when(() => mockAuth.updateUser(any<UserAttributes>())).thenAnswer(
          (_) async => UserResponse.fromJson({'user': fakeUser.toJson()}),
        );

        // Act & Assert
        await expectLater(
          dataSource.editProfile(avatarUrl: _kAvatarUrl),
          completes,
        );

        verify(() => mockBuilder.update({'avatar_url': _kAvatarUrl})).called(1);
        verify(() => mockAuth.updateUser(any<UserAttributes>())).called(1);
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 10
    // Jalur  : N1 → N2 → N3(tdk) → N4(ya) → N5 → N6 → N7(tdk) → N8
    //          → N9(tdk) → N11 → N12(tdk) → N13 → N14(ya) → N15(ya)
    //          → N16(tdk: tidak kosong) → N17 → N18 → N21
    // Kondisi: Ganti password + update username + avatar sekaligus
    // Input  : username='datatestNew', avatarUrl='https://...',
    //          oldPassword='password', newPassword='passwordnew'
    // Output : void (berhasil total)
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test('[P10] Ganti password + update username + avatar sekaligus '
        '→ void (berhasil total)', () async {
      // Arrange
      final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
      final mockBuilder = MockSupabaseQueryBuilder();
      final mockFilter = MockPostgrestFilterBuilder();
      stubDbUpdateSuccess(mockBuilder, mockFilter);
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(
        () => mockAuth.refreshSession(),
      ).thenAnswer((_) async => AuthResponse(session: null));
      when(
        () => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => AuthResponse(user: fakeUser, session: null));
      when(() => mockAuth.updateUser(any<UserAttributes>())).thenAnswer(
        (_) async => UserResponse.fromJson({'user': fakeUser.toJson()}),
      );

      // Act & Assert
      await expectLater(
        dataSource.editProfile(
          username: _kUsername,
          avatarUrl: _kAvatarUrl,
          oldPassword: _kOldPassword,
          newPassword: _kNewPassword,
        ),
        completes,
      );

      // Verifikasi urutan operasi:
      verify(() => mockAuth.refreshSession()).called(1);
      verify(
        () => mockAuth.signInWithPassword(
          email: _kEmail,
          password: _kOldPassword,
        ),
      ).called(1);
      // updateUser dipanggil 2x: untuk password (N11) dan metadata (N18)
      verify(() => mockAuth.updateUser(any<UserAttributes>())).called(2);
      // DB update dipanggil dengan username + avatar_url (N17)
      verify(
        () => mockBuilder.update({
          'username': _kUsername,
          'avatar_url': _kAvatarUrl,
        }),
      ).called(1);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // PATH 11
    // Jalur  : N1 → N2 → N3(tdk) → N4(tdk) → N13 → N14(ya) → N15(ya)
    //          → N16(tdk: tidak kosong) → N17 → N19(catch Exception umum) → N20 → N21
    // Kondisi: DB update melempar Exception umum (bukan ServerException)
    //          → ditangkap catch(e) → dibungkus ServerException
    // Input  : username='datatestNew', avatarUrl='https://...'
    // Mock   : mockSupabase.from('user') → throw Exception('Connection timeout')
    // Output : throw ServerException('Exception: Connection timeout')
    // DUPL   : DITERIMA
    // ─────────────────────────────────────────────────────────────────────────
    test('[P11] DB update throw Exception umum '
        '→ throw ServerException wrapping original error', () async {
      // Arrange
      final fakeUser = _fakeUser(id: _kUserId, email: _kEmail);
      when(() => mockAuth.currentUser).thenReturn(fakeUser);
      when(
        () => mockSupabase.from('user'),
      ).thenThrow(Exception('Connection timeout'));

      // Act & Assert
      await expectLater(
        () => dataSource.editProfile(
          username: _kUsername,
          avatarUrl: _kAvatarUrl,
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Connection timeout'),
          ),
        ),
      );

      verify(() => mockSupabase.from('user')).called(1);
      verifyNever(() => mockAuth.updateUser(any<UserAttributes>()));
    });
  }); // end group

  // ═══════════════════════════════════════════════════════════════════════════
  // SUMMARY PENGUJIAN (lihat juga dokumen DUPL-001 Tabel Path)
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // ┌──────┬──────────────────────────────────────────────────┬─────────────┐
  // │ Path │ Skenario                                         │ Kesimpulan  │
  // ├──────┼──────────────────────────────────────────────────┼─────────────┤
  // │  P1  │ userId null                                      │ DITERIMA    │
  // │  P2  │ Ganti password, email null setelah refresh       │ DITERIMA    │
  // │  P3  │ signInWithPassword throw AuthException           │ DITERIMA    │
  // │  P4  │ reAuth.user == null                              │ DITERIMA    │
  // │  P5  │ result.user == null setelah updateUser password  │ DITERIMA    │
  // │  P6  │ Ganti password sukses, updates kosong            │ DITERIMA    │
  // │  P7  │ Semua null, tidak ada operasi                    │ DITERIMA    │
  // │  P8  │ Update username saja                             │ DITERIMA    │
  // │  P9  │ Update avatar saja                               │ DITERIMA    │
  // │  P10 │ Ganti password + username + avatar sekaligus     │ DITERIMA    │
  // │  P11 │ DB update throw Exception umum                   │ DITERIMA    │
  // └──────┴──────────────────────────────────────────────────┴─────────────┘
}

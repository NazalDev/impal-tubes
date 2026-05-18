import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';

// ─────────────────────────────────────────────
// Genre list — add new genres here easily
// ─────────────────────────────────────────────
const List<String> kEventGenres = [
  'Seminar',
  'Penggalangan Dana',
  'Olahraga',
  'Lingkungan',
  'Seni & Budaya',
  'Pendidikan',
  'Sosial',
  'Kesehatan',
  'Teknologi',
  'Lainnya',
];

// ─────────────────────────────────────────────
// Validation helpers  (pure Dart, no framework)
// ─────────────────────────────────────────────
class _Validators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }
    return null;
  }

  static String? quota(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kuota anggota tidak boleh kosong.';
    }
    final n = int.tryParse(value.trim());
    if (n == null) return 'Kuota harus berupa angka.';
    if (n <= 0) return 'Kuota harus lebih dari 0.';
    if (n > 10000) return 'Kuota maksimal 10.000 anggota.';
    return null;
  }

  static String? day(String? value) {
    if (value == null || value.trim().isEmpty) return 'Isi hari.';
    final d = int.tryParse(value.trim());
    if (d == null || d < 1 || d > 31) return 'Hari tidak valid (1–31).';
    return null;
  }

  static String? month(String? value) {
    if (value == null || value.trim().isEmpty) return 'Isi bulan.';
    final m = int.tryParse(value.trim());
    if (m == null || m < 1 || m > 12) return 'Bulan tidak valid (1–12).';
    return null;
  }

  static String? year(String? value) {
    if (value == null || value.trim().isEmpty) return 'Isi tahun.';
    final y = int.tryParse(value.trim());
    final now = DateTime.now().year;
    if (y == null || y < now || y > now + 5) {
      return 'Tahun tidak valid ($now–${now + 5}).';
    }
    return null;
  }

  static String? hour(String? value) {
    if (value == null || value.trim().isEmpty) return 'Isi jam.';
    final h = int.tryParse(value.trim());
    if (h == null || h < 0 || h > 23) return 'Jam tidak valid (0–23).';
    return null;
  }

  static String? minute(String? value) {
    if (value == null || value.trim().isEmpty) return 'Isi menit.';
    final m = int.tryParse(value.trim());
    if (m == null || m < 0 || m > 59) return 'Menit tidak valid (0–59).';
    return null;
  }

  static String? durationDays(String? value) {
    if (value == null || value.trim().isEmpty) return 'Isi durasi.';
    final d = int.tryParse(value.trim());
    if (d == null || d < 1) return 'Durasi minimal 1 hari.';
    if (d > 30) return 'Durasi maksimal 30 hari.';
    return null;
  }

  static String? dateCombo(String day, String month, String year) {
    final d = int.tryParse(day.trim());
    final m = int.tryParse(month.trim());
    final y = int.tryParse(year.trim());
    if (d == null || m == null || y == null) return null;
    try {
      final date = DateTime(y, m, d);
      if (date.month != m) return 'Tanggal tidak valid untuk bulan tersebut.';
      if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
        return 'Tanggal kegiatan tidak boleh di masa lalu.';
      }
    } catch (_) {
      return 'Tanggal tidak valid.';
    }
    return null;
  }
}

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────

class PostEventPage extends StatefulWidget {
  const PostEventPage({super.key});

  @override
  State<PostEventPage> createState() => _PostEventPageState();
}

class _PostEventPageState extends State<PostEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _orgNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _quotaController = TextEditingController();

  // Start date/time
  final _startDayController = TextEditingController();
  final _startMonthController = TextEditingController();
  final _startYearController = TextEditingController();
  final _startHourController = TextEditingController();
  final _startMinuteController = TextEditingController();

  // Duration in days
  final _durationDaysController = TextEditingController();

  String? _selectedGenre;
  bool _agreedToTerms = false;
  bool _termsError = false;
  bool _hasAttemptedSubmit = false;
  String? _dateComboError;

  @override
  void dispose() {
    _titleController.dispose();
    _orgNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _quotaController.dispose();
    _startDayController.dispose();
    _startMonthController.dispose();
    _startYearController.dispose();
    _startHourController.dispose();
    _startMinuteController.dispose();
    _durationDaysController.dispose();
    super.dispose();
  }

  // ── Submit ───────────────────────────────────
  void _submitEvent() {
    setState(() {
      _hasAttemptedSubmit = true;
      _termsError = !_agreedToTerms;
      _dateComboError = _Validators.dateCombo(
        _startDayController.text,
        _startMonthController.text,
        _startYearController.text,
      );
    });

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _termsError || _dateComboError != null || _selectedGenre == null) {
      _showErrorSnackbar('Harap perbaiki kesalahan pada form terlebih dahulu.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showErrorSnackbar('Sesi Anda telah berakhir. Silakan login kembali.');
      return;
    }

    final day = int.parse(_startDayController.text.trim());
    final month = int.parse(_startMonthController.text.trim());
    final year = int.parse(_startYearController.text.trim());
    final hour = int.tryParse(_startHourController.text.trim()) ?? 0;
    final minute = int.tryParse(_startMinuteController.text.trim()) ?? 0;
    final durationDays = int.parse(_durationDaysController.text.trim());

    final startAt = DateTime(year, month, day, hour, minute);
    final endAt = startAt.add(Duration(days: durationDays));
    final now = DateTime.now();

    final event = EventEntity(
      userId: user.id,
      title: _titleController.text.trim(),
      description:
          '${_orgNameController.text.trim()}\n${_descriptionController.text.trim()}',
      location: _locationController.text.trim(),
      status: 'published',
      startAt: startAt,
      endAt: endAt,
      createdAt: now,
      updatedAt: now,
      id: 0,
      genre: _selectedGenre,
    );

    context.read<EventBloc>().add(CreateEvent(event));
  }

  // ── BLoC listener ────────────────────────────
  void _onBlocState(BuildContext context, EventBlocState state) {
    if (state is EventCreated) {
      context.read<EventBloc>().add(LoadEvents(reset: true));
      _showSuccessDialog();
    } else if (state is EventCreateError) {
      _showErrorSnackbar(state.message);
    }
  }

  // ── Feedback helpers ─────────────────────────
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.teal[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.teal[700],
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kegiatan Berhasil Diunggah!',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Kegiatan Anda sedang dalam proses peninjauan.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // back to list
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Oke'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Decoration helpers ───────────────────────
  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.teal, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[600]!, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  Widget _buildLabel(String label, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  AutovalidateMode get _autovalidate =>
      _hasAttemptedSubmit ? AutovalidateMode.always : AutovalidateMode.disabled;

  // ── Genre dropdown ───────────────────────────
  Widget _buildGenreDropdown() {
    final hasError = _hasAttemptedSubmit && _selectedGenre == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? Colors.red[400]! : Colors.grey[300]!,
              width: hasError ? 1.2 : 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGenre,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  'Pilih Genre',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              borderRadius: BorderRadius.circular(8),
              items: kEventGenres.map((genre) {
                return DropdownMenuItem(
                  value: genre,
                  child: Text(genre, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedGenre = val),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Genre tidak boleh kosong.',
              style: TextStyle(color: Colors.red[700], fontSize: 11),
            ),
          ),
      ],
    );
  }

  // ── Start date + time field ──────────────────
  Widget _buildStartDateTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date row: DD / MM / YYYY
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDayController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                textAlign: TextAlign.center,
                decoration: _fieldDecoration('DD').copyWith(counterText: ''),
                validator: _Validators.day,
                autovalidateMode: _autovalidate,
                onChanged: (_) => setState(() => _dateComboError = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _startMonthController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                textAlign: TextAlign.center,
                decoration: _fieldDecoration('MM').copyWith(counterText: ''),
                validator: _Validators.month,
                autovalidateMode: _autovalidate,
                onChanged: (_) => setState(() => _dateComboError = null),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _startYearController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                decoration: _fieldDecoration('YYYY').copyWith(counterText: ''),
                validator: _Validators.year,
                autovalidateMode: _autovalidate,
                onChanged: (_) => setState(() => _dateComboError = null),
              ),
            ),
          ],
        ),
        if (_dateComboError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _dateComboError!,
              style: TextStyle(color: Colors.red[700], fontSize: 11),
            ),
          ),
        const SizedBox(height: 8),
        // Time row: HH : MM
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _startHourController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                textAlign: TextAlign.center,
                decoration: _fieldDecoration('HH').copyWith(counterText: ''),
                validator: _Validators.hour,
                autovalidateMode: _autovalidate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _startMinuteController,
                keyboardType: TextInputType.number,
                maxLength: 2,
                textAlign: TextAlign.center,
                decoration: _fieldDecoration('MM').copyWith(counterText: ''),
                validator: _Validators.minute,
                autovalidateMode: _autovalidate,
              ),
            ),
            const Expanded(flex: 2, child: SizedBox()),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 2),
          child: Text(
            'Format 24 jam (contoh: 09:30 atau 14:00)',
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ── Duration days field ──────────────────────
  Widget _buildDurationField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: _durationDaysController,
            keyboardType: TextInputType.number,
            maxLength: 2,
            textAlign: TextAlign.center,
            decoration: _fieldDecoration('1').copyWith(counterText: ''),
            validator: _Validators.durationDays,
            autovalidateMode: _autovalidate,
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            'hari  (maks. 30 hari)',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventBlocState>(
      listener: _onBlocState,
      listenWhen: (_, current) =>
          current is EventCreating ||
          current is EventCreated ||
          current is EventCreateError,
      child: BlocBuilder<EventBloc, EventBlocState>(
        buildWhen: (_, current) =>
            current is EventCreating ||
            current is EventCreated ||
            current is EventCreateError,
        builder: (context, state) {
          final isLoading = state is EventCreating;

          return Scaffold(
            backgroundColor: const Color(0xFFE8F6F3),
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Colors.teal[900]),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Tambah Kegiatan',
                style: TextStyle(
                  color: Colors.teal[900],
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Kegiatan'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: _fieldDecoration('Nama Kegiatan'),
                      validator: (v) =>
                          _Validators.required(v, 'Nama kegiatan'),
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Nama Organisasi Asal'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _orgNameController,
                      decoration: _fieldDecoration('Nama Organisasi Asal'),
                      validator: (v) =>
                          _Validators.required(v, 'Nama organisasi'),
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Genre Kegiatan'),
                    const SizedBox(height: 6),
                    _buildGenreDropdown(),
                    const SizedBox(height: 16),

                    _buildLabel('Deskripsi Kegiatan'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _fieldDecoration('Deskripsi Kegiatan'),
                      maxLines: 4,
                      minLines: 4,
                      validator: (v) =>
                          _Validators.required(v, 'Deskripsi kegiatan'),
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Lokasi Kegiatan'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _locationController,
                      decoration: _fieldDecoration(
                        'Lokasi Kegiatan',
                        suffixIcon: Icon(
                          Icons.location_on_outlined,
                          color: Colors.grey[500],
                        ),
                      ),
                      validator: (v) =>
                          _Validators.required(v, 'Lokasi kegiatan'),
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Tanggal & Jam Mulai'),
                    const SizedBox(height: 6),
                    _buildStartDateTimeField(),
                    const SizedBox(height: 16),

                    _buildLabel('Durasi Kegiatan'),
                    const SizedBox(height: 6),
                    _buildDurationField(),
                    const SizedBox(height: 16),

                    _buildLabel('Kuota Anggota'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _quotaController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration('0'),
                      validator: _Validators.quota,
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 20),

                    // ── Terms & Conditions ─────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _termsError
                            ? Colors.red[50]
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _termsError
                              ? Colors.red[300]!
                              : Colors.orange[200]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _agreedToTerms,
                                  onChanged: (val) => setState(() {
                                    _agreedToTerms = val ?? false;
                                    if (_agreedToTerms) _termsError = false;
                                  }),
                                  activeColor: Colors.teal,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Saya bertanggung jawab dan menyatakan bahwa kegiatan ini '
                                  'mendukung tridharma universitas, tidak bertentangan dengan aturan/'
                                  'kebijakan Universitas Telkom, serta tidak mengganggu ketertiban dan '
                                  'keamanan kampus. Apabila dikemudian hari kegiatan ini tidak memenuhi '
                                  'syarat tersebut, saya bertanggung jawab dan bersedia menerima sanksi '
                                  'sesuai dengan aturan/kebijakan Universitas Telkom.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_termsError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 28),
                              child: Text(
                                'Anda harus menyetujui pernyataan ini untuk melanjutkan.',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Submit button ──────────────
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submitEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.teal[200],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan & Unggah',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

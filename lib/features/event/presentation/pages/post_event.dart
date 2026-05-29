import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/domain/entity/event.dart';
import 'package:volync/features/event/presentation/bloc/event_bloc.dart';

// ─────────────────────────────────────────────
// Genre list
// ─────────────────────────────────────────────
const List<String> kEventGenres = [
  'seminar',
  'penggalangan dana',
  'olahraga',
  'lingkungan',
  'seni & budaya',
  'pendidikan',
  'sosial',
  'kesehatan',
  'teknologi',
  'lainnya',
];

// ─────────────────────────────────────────────
// Validation helpers
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
  DateTime? _startDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);

  // End date/time
  DateTime? _endDate;
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  bool _endDateSetByUser = false;

  String? _selectedGenre;
  bool _agreedToTerms = false;
  bool _termsError = false;
  bool _hasAttemptedSubmit = false;
  String? _dateError;

  @override
  void dispose() {
    _titleController.dispose();
    _orgNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  // ── Date/time helpers ─────────────────────
  String _formatDate(DateTime? date) {
    if (date == null) return 'Pilih Tanggal';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('id', 'ID'),
    );
    if (picked == null) return;

    setState(() {
      _dateError = null;
      final previousStart = _startDate;
      _startDate = picked;

      if (previousStart == null) {
        _endDate = picked;
        _endDateSetByUser = false;
        return;
      }

      if (!_endDateSetByUser) {
        _endDate = picked;
      } else if (_endDate != null && picked.isAfter(_endDate!)) {
        _endDate = picked;
        _endDateSetByUser = false;
      }
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _endDate ?? _startDate ?? now;
    final firstDate = _startDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('id', 'ID'),
    );
    if (picked == null) return;

    setState(() {
      _endDate = picked;
      _endDateSetByUser = true;
      _dateError = null;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  // ── Submit ──────────────────────────────────
  void _submitEvent() {
    setState(() {
      _hasAttemptedSubmit = true;
      _termsError = !_agreedToTerms;
    });

    if (_startDate == null || _endDate == null) {
      setState(() => _dateError = 'Tanggal mulai dan selesai harus diisi.');
    } else {
      final startDt = _combine(_startDate!, _startTime);
      final endDt = _combine(_endDate!, _endTime);
      if (endDt.isBefore(startDt) || endDt.isAtSameMomentAs(startDt)) {
        setState(() => _dateError = 'Waktu selesai harus setelah waktu mulai.');
      } else {
        setState(() => _dateError = null);
      }
    }

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid ||
        _termsError ||
        _dateError != null ||
        _startDate == null ||
        _endDate == null ||
        _selectedGenre == null) {
      _showErrorSnackbar('Harap perbaiki kesalahan pada form terlebih dahulu.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showErrorSnackbar('Sesi Anda telah berakhir. Silakan login kembali.');
      return;
    }

    final startAt = _combine(_startDate!, _startTime);
    final endAt = _combine(_endDate!, _endTime);
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
      quota: int.tryParse(_quotaController.text.trim()),
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
            const Icon(Icons.error_outline, color: AppPallete.whiteColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: AppPallete.errorColor,
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
                color: AppPallete.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppPallete.focusedColor,
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
              style: TextStyle(color: AppPallete.borderColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppPallete.focusedColor,
                foregroundColor: AppPallete.whiteColor,
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
      hintStyle: TextStyle(color: AppPallete.borderColor, fontSize: 13),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppPallete.whiteColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppPallete.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppPallete.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppPallete.focusedColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppPallete.errorColor, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppPallete.errorColor, width: 1.5),
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
          color: AppPallete.defaultTextColor,
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppPallete.errorColor),
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
            color: AppPallete.whiteColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError ? AppPallete.errorColor : AppPallete.borderColor,
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
                  style: TextStyle(color: AppPallete.borderColor, fontSize: 13),
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
              style: TextStyle(color: AppPallete.errorColor, fontSize: 11),
            ),
          ),
      ],
    );
  }

  // ── Date+Time picker row ─────────────────────
  Widget _buildDateTimeRow({
    required String label,
    required DateTime? date,
    required TimeOfDay time,
    required VoidCallback onPickDate,
    required VoidCallback onPickTime,
    bool showError = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: onPickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppPallete.whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: showError ? AppPallete.errorColor : AppPallete.borderColor,
                  width: showError ? 1.2 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: date == null
                        ? AppPallete.borderColor
                        : AppPallete.focusedColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 13,
                        color: date == null
                            ? AppPallete.borderColor
                            : AppPallete.defaultTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onPickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppPallete.whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppPallete.borderColor),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppPallete.focusedColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(time),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppPallete.defaultTextColor,
                    ),
                  ),
                ],
              ),
            ),
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
            backgroundColor: AppPallete.backgroundColor,
            appBar: AppBar(
              surfaceTintColor: AppPallete.transparentColor,
              shadowColor: AppPallete.transparentColor,
              backgroundColor: AppPallete.transparentColor,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: AppPallete.backButtonColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Tambah Kegiatan',
                style: TextStyle(
                  color: AppPallete.backButtonColor,
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
                          color: AppPallete.borderColor,
                        ),
                      ),
                      validator: (v) =>
                          _Validators.required(v, 'Lokasi kegiatan'),
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    // ── Start date + time ─────────────────────────
                    _buildLabel('Tanggal & Jam Mulai'),
                    const SizedBox(height: 6),
                    _buildDateTimeRow(
                      label: 'Mulai',
                      date: _startDate,
                      time: _startTime,
                      onPickDate: _pickStartDate,
                      onPickTime: _pickStartTime,
                      showError: _hasAttemptedSubmit && _startDate == null,
                    ),
                    if (_hasAttemptedSubmit && _startDate == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Tanggal mulai harus diisi.',
                          style: TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // ── End date + time ───────────────────────────
                    _buildLabel('Tanggal & Jam Selesai'),
                    const SizedBox(height: 6),
                    _buildDateTimeRow(
                      label: 'Selesai',
                      date: _endDate,
                      time: _endTime,
                      onPickDate: _pickEndDate,
                      onPickTime: _pickEndTime,
                      showError: _hasAttemptedSubmit && _endDate == null,
                    ),
                    if (_hasAttemptedSubmit && _endDate == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          'Tanggal selesai harus diisi.',
                          style: TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    if (_dateError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4),
                        child: Text(
                          _dateError!,
                          style: TextStyle(
                            color: AppPallete.errorColor,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 2),
                      child: Text(
                        'Tanggal selesai otomatis sama dengan tanggal mulai',
                        style: TextStyle(
                          color: AppPallete.borderColor,
                          fontSize: 11,
                        ),
                      ),
                    ),
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

                    // ── Terms & Conditions ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _termsError
                            ? AppPallete.errorColor.withOpacity(0.05)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _termsError
                              ? AppPallete.errorColor.withOpacity(0.5)
                              : Colors.orange.shade200,
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
                                  activeColor: AppPallete.focusedColor,
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
                                    color: AppPallete.blackColor,
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
                                  color: AppPallete.errorColor,
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
                          backgroundColor: AppPallete.focusedColor,
                          foregroundColor: AppPallete.whiteColor,
                          disabledBackgroundColor:
                              AppPallete.buttonColor.withOpacity(0.5),
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
                                  color: AppPallete.whiteColor,
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

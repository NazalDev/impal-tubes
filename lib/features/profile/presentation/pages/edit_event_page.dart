import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/presentation/pages/post_event.dart'
    show kEventGenres;
import 'package:volync/features/profile/domain/entity/profile_event_entity.dart';
import 'package:volync/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:volync/features/profile/presentation/pages/event_report_page.dart';
import 'package:volync/features/profile/presentation/pages/manage_members_page.dart';
import 'package:volync/features/profile/presentation/widgets/manage_event_card.dart';

class KelolaEventPage extends StatefulWidget {
  final String userId;

  const KelolaEventPage({super.key, required this.userId});

  @override
  State<KelolaEventPage> createState() => _KelolaEventPageState();
}

class _KelolaEventPageState extends State<KelolaEventPage> {
  List<ProfileEventEntity> _cachedEvents = [];
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    context.read<ProfileBloc>().add(
          ProfileLoadUserEvents(userId: widget.userId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPallete.cardBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppPallete.backButtonColor,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelola Event',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppPallete.errorColor,
              ),
            );
          }
          if (state is ProfileActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppPallete.focusedColor,
              ),
            );
            _loadEvents();
          }
          if (state is ProfileUserEventsLoaded) {
            setState(() {
              _cachedEvents = state.events;
              _initialLoadDone = true;
            });
          }
        },
        builder: (context, state) {
          if (!_initialLoadDone && state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_initialLoadDone && _cachedEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 72,
                    color: AppPallete.borderColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada event yang dibuat',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppPallete.borderColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cachedEvents.length,
                itemBuilder: (context, index) {
                  final event = _cachedEvents[index];
                  return ManageEventCard(
                    event: event,
                    onEdit: () => _showEditPage(context, event),
                    onDelete: () => _confirmDelete(context, event.id),
                    onReport: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ProfileBloc>(),
                          child: EventReportPage(event: event),
                        ),
                      ),
                    ),
                    onManageMembers: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ProfileBloc>(),
                            child: ManageMembersPage(event: event),
                          ),
                        ),
                      );
                      if (context.mounted) _loadEvents();
                    },
                    onCancel: () => _confirmCancel(context, event.id),
                  );
                },
              ),
              if (state is ProfileLoading && _initialLoadDone)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    backgroundColor: AppPallete.transparentColor,
                    color: AppPallete.buttonColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Event'),
        content: const Text(
          'Yakin ingin menghapus event ini? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppPallete.focusedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.errorColor,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(
                    ProfileDeleteEvent(eventId: eventId),
                  );
            },
            child: const Text('Hapus', style: TextStyle(color: AppPallete.whiteColor)),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, String eventId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Event'),
        content: const Text(
          'Yakin ingin membatalkan event ini? Status tidak dapat dikembalikan ke Published.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tidak', style: TextStyle(color: AppPallete.focusedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(
                    ProfileCancelEvent(eventId: eventId),
                  );
            },
            child: const Text(
              'Batalkan Event',
              style: TextStyle(color: AppPallete.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPage(BuildContext context, ProfileEventEntity event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: _EditEventPage(event: event),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dedicated full-page Edit Event form (matches PostEventPage style)
// ─────────────────────────────────────────────────────────────────────────────
class _EditEventPage extends StatefulWidget {
  final ProfileEventEntity event;
  const _EditEventPage({required this.event});

  @override
  State<_EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<_EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _orgNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _quotaController;

  String? _selectedGenre;
  bool _hasAttemptedSubmit = false;

  File? _pickedImage;
  String? _imageError;
  static const int _maxImageBytes = 2 * 1024 * 1024; // 2 MB

  @override
  void initState() {
    super.initState();
    final parts = widget.event.description.split('\n');
    final orgName = parts.isNotEmpty ? parts.first : '';
    final desc = parts.length > 1 ? parts.sublist(1).join('\n') : '';

    _titleController = TextEditingController(text: widget.event.title);
    _orgNameController = TextEditingController(text: orgName);
    _descriptionController = TextEditingController(text: desc);
    _locationController = TextEditingController(text: widget.event.location);
    _quotaController = TextEditingController(
      text: widget.event.quota?.toString() ?? '',
    );
    _selectedGenre = kEventGenres.contains(widget.event.genre)
        ? widget.event.genre
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orgNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _quotaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final bytes = await file.length();

    if (bytes > _maxImageBytes) {
      setState(() {
        _pickedImage = null;
        _imageError = 'Ukuran gambar maksimal 2 MB.';
      });
      return;
    }
    setState(() {
      _pickedImage = file;
      _imageError = null;
    });
  }

  void _removeImage() => setState(() {
        _pickedImage = null;
        _imageError = null;
      });

  void _submit() {
    setState(() => _hasAttemptedSubmit = true);

    final formValid = _formKey.currentState?.validate() ?? false;
    final genreValid = _selectedGenre != null;

    if (!formValid || !genreValid) {
      _showErrorSnackbar('Harap perbaiki kesalahan pada form terlebih dahulu.');
      return;
    }

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description':
          '${_orgNameController.text.trim()}\n${_descriptionController.text.trim()}',
      'location': _locationController.text.trim(),
      'genre': _selectedGenre,
    };

    final quota = int.tryParse(_quotaController.text.trim());
    if (quota != null) data['quota'] = quota;

    context.read<ProfileBloc>().add(
          ProfileUpdateEvent(
            eventId: widget.event.id,
            data: data,
            imageFile: _pickedImage,
          ),
        );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppPallete.whiteColor, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(message, style: const TextStyle(fontSize: 13))),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Gambar Kegiatan', required: false),
        const SizedBox(height: 6),
        if (_pickedImage != null) ...[
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _pickedImage!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppPallete.blackColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: AppPallete.whiteColor, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppPallete.whiteColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _imageError != null
                      ? AppPallete.errorColor
                      : AppPallete.borderColor,
                  width: _imageError != null ? 1.2 : 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: AppPallete.focusedColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ketuk untuk pilih gambar',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppPallete.focusedColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maksimal 2 MB',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppPallete.borderColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (_imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _imageError!,
              style: TextStyle(color: AppPallete.errorColor, fontSize: 11),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          Navigator.pop(context);
        } else if (state is ProfileFailure) {
          _showErrorSnackbar(state.message);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        buildWhen: (_, s) =>
            s is ProfileLoading || s is ProfileActionSuccess || s is ProfileFailure,
        builder: (context, state) {
          final isLoading = state is ProfileLoading;

          return Scaffold(
            backgroundColor: AppPallete.backgroundColor,
            appBar: AppBar(
              surfaceTintColor: AppPallete.transparentColor,
              shadowColor: AppPallete.transparentColor,
              backgroundColor: AppPallete.transparentColor,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: AppPallete.backButtonColor),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Edit Kegiatan',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Nama Kegiatan'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleController,
                      decoration: _fieldDecoration('Nama Kegiatan'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama kegiatan tidak boleh kosong.'
                          : null,
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Nama Organisasi Asal'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _orgNameController,
                      decoration: _fieldDecoration('Nama Organisasi Asal'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama organisasi tidak boleh kosong.'
                          : null,
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Deskripsi kegiatan tidak boleh kosong.'
                          : null,
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Lokasi kegiatan tidak boleh kosong.'
                          : null,
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Kuota Anggota', required: false),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _quotaController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration('0'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final n = int.tryParse(v.trim());
                        if (n == null) return 'Kuota harus berupa angka.';
                        if (n <= 0) return 'Kuota harus lebih dari 0.';
                        if (n > 10000) return 'Kuota maksimal 10.000 anggota.';
                        return null;
                      },
                      autovalidateMode: _autovalidate,
                    ),
                    const SizedBox(height: 16),

                    _buildImagePicker(),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPallete.focusedColor,
                          foregroundColor: AppPallete.whiteColor,
                          disabledBackgroundColor:
                              AppPallete.buttonColor.withValues(alpha: 0.5),
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
                                'Simpan Perubahan',
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
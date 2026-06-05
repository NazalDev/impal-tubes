import 'dart:io';
import 'package:flutter/material.dart';
import 'package:volync/core/theme/app_pallete.dart';
import 'package:volync/features/event/presentation/pages/post_event.dart'
    show kEventGenres;

/// Widget label form dengan tanda wajib (*).
/// Diekstrak dari _EditEventPageState untuk mengurangi WMC.
class FormFieldLabel extends StatelessWidget {
  final String label;
  final bool required;

  const FormFieldLabel(this.label, {super.key, this.required = true});

  @override
  Widget build(BuildContext context) {
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
}

/// Dekorasi input field yang konsisten untuk semua form.
InputDecoration buildFieldDecoration(String hint, {Widget? suffixIcon}) {
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

/// Dropdown genre event. Diekstrak agar _EditEventPageState tidak perlu
/// menyimpan logika render sendiri (menurunkan WMC & LCOM).
class GenreDropdown extends StatelessWidget {
  final String? selectedGenre;
  final bool hasAttemptedSubmit;
  final ValueChanged<String?> onChanged;

  const GenreDropdown({
    super.key,
    required this.selectedGenre,
    required this.hasAttemptedSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = hasAttemptedSubmit && selectedGenre == null;
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
              value: selectedGenre,
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
              onChanged: onChanged,
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
}

/// Widget image picker untuk form event.
/// Diekstrak dari _EditEventPageState untuk menurunkan WMC dari 11 → 6.
class EventImagePicker extends StatelessWidget {
  final File? pickedImage;
  final String? imageError;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const EventImagePicker({
    super.key,
    required this.pickedImage,
    required this.imageError,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel('Gambar Kegiatan', required: false),
        const SizedBox(height: 6),
        if (pickedImage != null) ...[
          _SelectedImagePreview(image: pickedImage!, onRemove: onRemove),
        ] else ...[
          _ImagePickerPlaceholder(
            onTap: onPick,
            hasError: imageError != null,
          ),
        ],
        if (imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              imageError!,
              style: TextStyle(color: AppPallete.errorColor, fontSize: 11),
            ),
          ),
      ],
    );
  }
}

class _SelectedImagePreview extends StatelessWidget {
  final File image;
  final VoidCallback onRemove;

  const _SelectedImagePreview({
    required this.image,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            image,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppPallete.blackColor.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppPallete.whiteColor,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePickerPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasError;

  const _ImagePickerPlaceholder({
    required this.onTap,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppPallete.whiteColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasError ? AppPallete.errorColor : AppPallete.borderColor,
            width: hasError ? 1.2 : 1.0,
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
              style: TextStyle(fontSize: 13, color: AppPallete.focusedColor),
            ),
            const SizedBox(height: 4),
            Text(
              'Maksimal 2 MB',
              style: TextStyle(fontSize: 11, color: AppPallete.borderColor),
            ),
          ],
        ),
      ),
    );
  }
}
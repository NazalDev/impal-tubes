import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  final Icon icon;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureIcon;
  final bool autoFocus;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureIcon = false,
    this.autoFocus = false,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureIcon;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      autofocus: widget.autoFocus,
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        hintText: widget.hintText,
        suffixIcon: widget.obscureIcon
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black38,
                ),
                onPressed: _togglePasswordVisibility,
              )
            : null,
      ),
      validator:
          widget.validator ??
          (value) {
            if (value?.isEmpty ?? true) {
              return 'Field tidak boleh kosong';
            }
            return null;
          },
    );
  }

  void _togglePasswordVisibility() {
    setState(() => _obscureText = !_obscureText);
  }
}

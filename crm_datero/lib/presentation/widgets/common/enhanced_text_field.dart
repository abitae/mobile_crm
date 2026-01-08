import 'package:flutter/material.dart';

/// Campo de texto mejorado con validación visual en tiempo real
class EnhancedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLength;
  final bool enabled;
  final int? maxLines;
  final InputDecoration? decoration;

  const EnhancedTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.enabled = true,
    this.maxLines = 1,
    this.decoration,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  bool _isFocused = false;
  String? _errorText;
  bool _isValid = false;
  bool _hasInteracted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
          if (!hasFocus && widget.validator != null && _hasInteracted) {
            _validate();
          }
        });
      },
      child: TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        decoration: (widget.decoration ?? InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon)
              : null,
          suffixIcon: _buildSuffixIcon(colorScheme),
          counterText: widget.maxLength != null
              ? '${widget.controller?.text.length ?? 0}/${widget.maxLength}'
              : null,
        )).copyWith(
          errorText: _errorText,
          errorStyle: _errorText != null
              ? TextStyle(
                  color: colorScheme.error,
                  fontSize: 12,
                )
              : null,
        ),
        validator: (value) {
          _hasInteracted = true;
          return _validate(value);
        },
        onChanged: (value) {
          _hasInteracted = true;
          if (widget.validator != null && _isFocused) {
            _validate(value);
          }
          widget.onChanged?.call(value);
        },
      ),
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme) {
    if (widget.suffixIcon != null) {
      return Icon(widget.suffixIcon);
    }

    if (!_hasInteracted) {
      return null;
    }

    if (_errorText != null) {
      return Icon(
        Icons.error_outline,
        color: colorScheme.error,
        size: 20,
      );
    }

    if (_isValid && widget.controller?.text.isNotEmpty == true) {
      return Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 20,
      );
    }

    return null;
  }

  String? _validate([String? value]) {
    if (widget.validator == null) {
      setState(() {
        _errorText = null;
        _isValid = false;
      });
      return null;
    }

    final error = widget.validator!(value ?? widget.controller?.text);
    setState(() {
      _errorText = error;
      _isValid = error == null && (value ?? widget.controller?.text)?.isNotEmpty == true;
    });
    return error;
  }
}

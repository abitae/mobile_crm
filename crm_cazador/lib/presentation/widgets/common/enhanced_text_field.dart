import 'package:flutter/material.dart';
import '../animations/fade_in_animation.dart';
import '../animations/slide_animation.dart';
import '../../utils/animation_utils.dart';

class EnhancedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<String>? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;

  const EnhancedTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isValid = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _validate();
    }
  }

  void _validate() {
    if (widget.validator != null) {
      final errors = widget.validator!(widget.controller?.text);
      setState(() {
        _isValid = errors == null || errors.isEmpty;
        _errorMessage = errors?.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: colorScheme.onSurfaceVariant)
                : null,
            suffixIcon: _isValid
                ? widget.suffixIcon
                : Icon(Icons.error_outline, color: colorScheme.error),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid ? colorScheme.outline : colorScheme.error,
                width: _focusNode.hasFocus ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid ? colorScheme.outline : colorScheme.error,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isValid ? colorScheme.primary : colorScheme.error,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: (value) {
            _validate();
            widget.onChanged?.call(value);
          },
          validator: (value) {
            _validate();
            return _errorMessage;
          },
        ),
        if (_errorMessage != null && !_isValid)
          FadeInAnimation(
            child: SlideAnimation(
              beginOffset: const Offset(0, -0.1),
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

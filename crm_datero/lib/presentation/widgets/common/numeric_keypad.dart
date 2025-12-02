import 'package:flutter/material.dart';

/// Widget de panel numérico para entrada de PIN
class NumericKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback? onDeletePressed;
  final bool showDeleteButton;

  const NumericKeypad({
    super.key,
    required this.onNumberPressed,
    this.onDeletePressed,
    this.showDeleteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 1: 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton(context, '1'),
              _buildNumberButton(context, '2'),
              _buildNumberButton(context, '3'),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 2: 4, 5, 6
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton(context, '4'),
              _buildNumberButton(context, '5'),
              _buildNumberButton(context, '6'),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 3: 7, 8, 9
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNumberButton(context, '7'),
              _buildNumberButton(context, '8'),
              _buildNumberButton(context, '9'),
            ],
          ),
          const SizedBox(height: 8),
          // Fila 4: espacio, 0, borrar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 60, height: 60), // Espacio vacío
              _buildNumberButton(context, '0'),
              if (showDeleteButton)
                _buildDeleteButton(context)
              else
                const SizedBox(width: 60, height: 60), // Espacio vacío
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(BuildContext context, String number) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: () => onNumberPressed(number),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
          elevation: 1,
        ),
        child: Text(
          number,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ElevatedButton(
        onPressed: onDeletePressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.zero,
          elevation: 1,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        ),
        child: Icon(
          Icons.backspace_outlined,
          color: Theme.of(context).colorScheme.onErrorContainer,
          size: 22,
        ),
      ),
    );
  }
}


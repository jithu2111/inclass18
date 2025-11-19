import 'package:flutter/material.dart';

class AnswerButton extends StatefulWidget {
  final String answer;
  final VoidCallback onPressed;
  final bool? isCorrect;
  final bool isSelected;
  final bool isDisabled;

  const AnswerButton({
    super.key,
    required this.answer,
    required this.onPressed,
    this.isCorrect,
    required this.isSelected,
    required this.isDisabled,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getButtonColor() {
    if (widget.isSelected && widget.isCorrect != null) {
      // Show correct/incorrect color after selection
      return widget.isCorrect! ? Colors.green : Colors.red;
    } else if (widget.isSelected) {
      // Button is selected but not yet validated
      return Colors.blue.shade300;
    } else {
      // Default state
      return Colors.white;
    }
  }

  Color _getTextColor() {
    if (widget.isSelected && widget.isCorrect != null) {
      return Colors.white;
    } else if (widget.isSelected) {
      return Colors.white;
    } else {
      return Colors.purple.shade700;
    }
  }

  IconData? _getIcon() {
    if (widget.isSelected && widget.isCorrect != null) {
      return widget.isCorrect! ? Icons.check_circle : Icons.cancel;
    }
    return null;
  }

  void _handleTap() {
    if (!widget.isDisabled) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          onPressed: widget.isDisabled ? null : _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getButtonColor(),
            foregroundColor: _getTextColor(),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: widget.isSelected ? 8 : 4,
            shadowColor: widget.isSelected
                ? _getButtonColor().withOpacity(0.5)
                : Colors.black26,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (_getIcon() != null)
                Icon(
                  _getIcon(),
                  color: Colors.white,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
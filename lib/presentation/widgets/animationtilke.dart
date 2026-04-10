import 'package:flutter/material.dart';
import 'package:sidi/constant/constants.dart';

class AnimatedInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool obscureText;
  final TextInputType inputType;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const AnimatedInputField(
    String s,
    String e, {
    super.key,
    required this.label,
    required this.placeholder,
    this.obscureText = false,
    this.inputType = TextInputType.text,
    this.controller,
    this.onChanged,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: kLabelTextStyle),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _isFocused
                    ? opacity(kEspressoColor, 0.4)
                    : opacity(kEspressoColor, 0.1),
                width: 1.5,
              ),
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.inputType,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: kInputHintStyle,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

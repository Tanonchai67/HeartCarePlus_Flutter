import 'package:flutter/material.dart';

class PassOnOff extends StatefulWidget {
  final Function(String?)? onSaved;
  final String label;

  const PassOnOff({super.key, this.onSaved, this.label = "รหัสผ่าน"});

  @override
  State<PassOnOff> createState() => _PassOnOffState();
}

class _PassOnOffState extends State<PassOnOff> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) =>
          value == null || value.isEmpty ? "กรุณาป้อนรหัสผ่าน" : null,
      onSaved: widget.onSaved,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey[600],
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}

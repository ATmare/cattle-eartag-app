import 'package:flutter/material.dart';

/*
    Class returns a Checkbox with a label on the right side of it
 */
class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    this.label,
    this.contentPadding,
    this.value,
    this.onTap,
    this.activeColor,
    this.fontSize,
    this.gap = 4.0,
    this.bold = false,
  });

  final String label;
  final EdgeInsets contentPadding;
  final bool value;
  final Function onTap;
  final Color activeColor;
  final double fontSize;
  final double gap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(!value),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              height: 20.0,
              width: 20.0,
              child: Checkbox(
                value: value,
                activeColor: activeColor,
                visualDensity: VisualDensity.compact,
                onChanged: (val) => onTap(val),
              ),
            ),
            SizedBox(
              width: gap,
            ),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

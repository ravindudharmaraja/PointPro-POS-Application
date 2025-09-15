import 'package:flutter/material.dart';
import '../../utils/media_query_values.dart';

class SearchFormField extends StatelessWidget {
  const SearchFormField({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onSurface.withOpacity(0.8);
    final borderColor = colorScheme.outline.withOpacity(0.5);
    final fillColor = colorScheme.surfaceContainerHighest.withOpacity(0.4);

    return SizedBox(
      width: context.width * 0.2,
      height: context.height * 0.05,
      child: TextField(
        cursorColor: colorScheme.primary,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
        decoration: InputDecoration(
          fillColor: fillColor,
          filled: true,
          contentPadding: EdgeInsets.zero,
          prefixIcon: Icon(Icons.search, size: 18.0, color: textColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorScheme.error, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          hintText: 'Search',
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor.withOpacity(0.6),
                fontSize: 14.0,
              ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

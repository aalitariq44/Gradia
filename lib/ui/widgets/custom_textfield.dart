import 'package:fluent_ui/fluent_ui.dart';
import '../themes/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String? placeholder;
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;

  const CustomTextField({
    Key? key,
    this.placeholder,
    this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.bodyStrongStyle),
          const SizedBox(height: 8),
        ],
        TextBox(
          controller: controller,
          placeholder: placeholder,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          obscureText: obscureText,
          keyboardType: keyboardType,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          prefix: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    prefixIcon,
                    size: 16,
                    color: enabled ? Colors.grey[120] : Colors.grey[80],
                  ),
                )
              : null,
          suffix: suffix,
          style: AppTheme.bodyStyle,
          placeholderStyle: TextStyle(color: Colors.grey[120], fontSize: 14),
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final void Function(T?)? onChanged;
  final String? placeholder;
  final bool enabled;
  final String? Function(T?)? validator;

  const CustomDropdown({
    Key? key,
    this.label,
    this.value,
    required this.items,
    required this.itemBuilder,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.bodyStrongStyle),
          const SizedBox(height: 8),
        ],
        ComboBox<T>(
          value: value,
          items: items
              .map(
                (item) => ComboBoxItem<T>(
                  value: item,
                  child: Text(itemBuilder(item)),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          placeholder: placeholder != null ? Text(placeholder!) : null,
          isExpanded: true,
        ),
      ],
    );
  }
}

class CustomDatePicker extends StatelessWidget {
  final String? label;
  final DateTime? value;
  final void Function(DateTime)? onChanged;
  final String? placeholder;
  final bool enabled;

  const CustomDatePicker({
    Key? key,
    this.label,
    this.value,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.bodyStrongStyle),
          const SizedBox(height: 8),
        ],
        DatePicker(selected: value, onChanged: enabled ? onChanged : null),
      ],
    );
  }
}

class CustomTimePicker extends StatelessWidget {
  final String? label;
  final DateTime? value;
  final void Function(DateTime)? onChanged;
  final String? placeholder;
  final bool enabled;

  const CustomTimePicker({
    Key? key,
    this.label,
    this.value,
    this.onChanged,
    this.placeholder,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppTheme.bodyStrongStyle),
          const SizedBox(height: 8),
        ],
        TimePicker(selected: value, onChanged: enabled ? onChanged : null),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DatePickerField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final DateTime? minimumDate;
  final DateTime? maximumDate;

  const DatePickerField({
    super.key,
    required this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.minimumDate,
    this.maximumDate,
  });

  void _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final min = minimumDate ?? DateTime(now.year - 100);
    final max = maximumDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime(now.year - 25),
      firstDate: min,
      lastDate: max,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryViolet,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.surfacePlum,
              onSurface: AppColors.textPrimary,
            ),
            dialogBackgroundColor: AppColors.surfacePlum,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showDatePicker(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null ? _formatDate(value!) : (placeholder ?? ''),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: value != null
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                ),
                const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:fintrack/core/constants/constants.dart';
import 'package:fintrack/features/statistic/controllers/date_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StatFilterSection extends StatelessWidget {
  final DateFilterController controller;

  const StatFilterSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Period Selector
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorPallete.blackLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSegment(context, StatPeriod.weekly, 'Mingguan'),
              _buildSegment(context, StatPeriod.monthly, 'Bulanan'),
              _buildSegment(context, StatPeriod.yearly, 'Tahunan'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Date Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: controller.previous,
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 180,
              child: Text(
                _formatDateRange(controller.period, controller.currentRange),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: controller.next,
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSegment(BuildContext context, StatPeriod period, String label) {
    final isSelected = controller.period == period;
    return GestureDetector(
      onTap: () => controller.setPeriod(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorPallete.green : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? ColorPallete.black : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _formatDateRange(StatPeriod period, DateTimeRange range) {
    switch (period) {
      case StatPeriod.weekly:
        final start = DateFormat('d MMM').format(range.start);
        final end = DateFormat('d MMM').format(range.end);
        return '$start - $end';
      case StatPeriod.monthly:
        return DateFormat('MMMM yyyy', 'id_ID').format(range.start);
      case StatPeriod.yearly:
        return DateFormat('yyyy').format(range.start);
    }
  }
}

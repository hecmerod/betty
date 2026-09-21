import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocationsDateFilter extends StatelessWidget {
  final DateTime? from;
  final DateTime? to;
  final ValueChanged<DateTime> onFromSelected;
  final ValueChanged<DateTime> onToSelected;
  final VoidCallback onCleared;

  const LocationsDateFilter({
    super.key,
    required this.from,
    required this.to,
    required this.onFromSelected,
    required this.onToSelected,
    required this.onCleared,
  });

  bool get _hasFilter => from != null || to != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          Expanded(
            child: _DateChip(
              label: 'Desde',
              date: from,
              onTap: () => _pickDate(context, isFrom: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _DateChip(
              label: 'Hasta',
              date: to,
              onTap: () => _pickDate(context, isFrom: false),
            ),
          ),
          if (_hasFilter) ...[
            const SizedBox(width: 8),
            _ClearChip(onTap: onCleared),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isFrom}) async {
    final now = DateTime.now();
    final current = isFrom ? from : to;
    final firstDate = isFrom ? DateTime(2020) : (from ?? DateTime(2020));
    final lastDate = isFrom ? (to ?? now) : now;

    final picked = await showDatePicker(
      context: context,
      initialDate: _clamp(current ?? lastDate, firstDate, lastDate),
      firstDate: firstDate,
      lastDate: lastDate.isBefore(firstDate) ? firstDate : lastDate,
      helpText: isFrom ? 'Fecha desde' : 'Fecha hasta',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF43e97b),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;
    if (isFrom) {
      onFromSelected(picked);
    } else {
      onToSelected(picked);
    }
  }

  DateTime _clamp(DateTime value, DateTime min, DateTime max) {
    if (value.isBefore(min)) return min;
    if (value.isAfter(max)) return max;
    return value;
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateChip({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = date != null;
    final text = isActive ? DateFormat('dd/MM/yyyy').format(date!.toLocal()) : label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF43e97b).withValues(alpha: 0.12)
                : const Color(0xFF1E1E1E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? const Color(0xFF43e97b) : const Color(0xFF1E1E1E).withValues(alpha: 0.1),
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFF1E1E1E).withValues(alpha: 0.45),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? const Color(0xFF1E1E1E) : const Color(0xFF1E1E1E).withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearChip extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.1)),
          ),
          child: Icon(Icons.close_rounded, size: 18, color: const Color(0xFF1E1E1E).withValues(alpha: 0.55)),
        ),
      ),
    );
  }
}

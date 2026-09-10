import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../models/location_record.dart';

class LocationListItem extends StatelessWidget {
  final LocationRecord location;
  final bool isSelected;
  final VoidCallback onTap;

  const LocationListItem({super.key, required this.location, required this.isSelected, required this.onTap});

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  String _formatCoordinates() {
    return '${location.position.latitude.toStringAsFixed(5)}, ${location.position.longitude.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withValues(alpha: isSelected ? 0.08 : 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF43e97b) : const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF43e97b).withValues(alpha: 0.2)
                            : const Color(0xFF1E1E1E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.place_rounded,
                        color: isSelected ? const Color(0xFF43e97b) : const Color(0xFF666666),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(location.timestamp),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E1E1E),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location.altitude != null
                                ? '${_formatCoordinates()}  ·  ${location.altitude!.toStringAsFixed(0)} m'
                                : _formatCoordinates(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF666666),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isSelected ? const Color(0xFF43e97b) : const Color(0xFF1E1E1E).withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

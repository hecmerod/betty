import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/location_record.dart';
import 'location_list_item.dart';

class LocationsList extends StatelessWidget {
  final List<LocationRecord> locations;
  final bool isLoading;
  final int? selectedIndex;
  final ScrollController? scrollController;
  final ValueChanged<int> onLocationSelected;

  const LocationsList({
    super.key,
    required this.locations,
    required this.isLoading,
    required this.onLocationSelected,
    this.selectedIndex,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: const Color(0xFF1E1E1E).withValues(alpha: 0.08), width: 1.5),
          ),
          child: ListView.builder(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: 1 + _bodyItemCount,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader();
              return _buildBodyItem(index - 1);
            },
          ),
        ),
      ),
    );
  }

  int get _bodyItemCount {
    if (isLoading || locations.isEmpty) return 1;
    return locations.length;
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'UBICACIONES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              if (!isLoading)
                Text(
                  '${locations.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1E1E).withValues(alpha: 0.4),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyItem(int index) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF43e97b), strokeWidth: 3)),
      );
    }

    if (locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(
          children: [
            Icon(Icons.location_off_rounded, size: 48, color: const Color(0xFF1E1E1E).withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No hay ubicaciones registradas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return LocationListItem(
      location: locations[index],
      isSelected: selectedIndex == index,
      onTap: () => onLocationSelected(index),
    );
  }
}

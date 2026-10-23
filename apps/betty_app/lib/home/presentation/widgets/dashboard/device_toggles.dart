import 'package:flutter/material.dart';

class DeviceToggles extends StatefulWidget {
  const DeviceToggles({super.key});

  @override
  State<DeviceToggles> createState() => _DeviceTogglesState();
}

class _DeviceSpec {
  const _DeviceSpec(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const LinearGradient _onGradient = LinearGradient(
  colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
);

class _DeviceTogglesState extends State<DeviceToggles> {
  static const List<_DeviceSpec> _devices = [
    _DeviceSpec('Luces', Icons.lightbulb_outlined, Icons.lightbulb),
    _DeviceSpec('Exterior', Icons.highlight_outlined, Icons.highlight),
    _DeviceSpec('Calentador', Icons.whatshot_outlined, Icons.whatshot),
    _DeviceSpec('Panel Solar', Icons.solar_power_outlined, Icons.solar_power),
    _DeviceSpec(
      'Cargador',
      Icons.electrical_services_outlined,
      Icons.electrical_services,
    ),
    _DeviceSpec('Starlink', Icons.satellite_alt_outlined, Icons.satellite_alt),
  ];

  final List<bool> _enabled = List<bool>.filled(_devices.length, false);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _ToggleRow(
            devices: _devices.sublist(0, 3),
            enabled: _enabled.sublist(0, 3),
            onToggle: (index) => _toggle(index),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            devices: _devices.sublist(3),
            enabled: _enabled.sublist(3),
            onToggle: (index) => _toggle(index + 3),
          ),
        ],
      ),
    );
  }

  void _toggle(int index) => setState(() => _enabled[index] = !_enabled[index]);
}

class _ToggleRow extends StatelessWidget {
  final List<_DeviceSpec> devices;
  final List<bool> enabled;
  final ValueChanged<int> onToggle;

  const _ToggleRow({
    required this.devices,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int index = 0; index < devices.length; index++)
          Expanded(
            child: _ToggleButton(
              device: devices[index],
              isOn: enabled[index],
              onTap: () => onToggle(index),
            ),
          ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final _DeviceSpec device;
  final bool isOn;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.device,
    required this.isOn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Icon icon = Icon(
      isOn ? device.selectedIcon : device.icon,
      size: 28,
      color: isOn ? Colors.white : const Color(0xFF666666),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          isOn
              ? ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => _onGradient.createShader(bounds),
                  child: icon,
                )
              : icon,
          const SizedBox(height: 6),
          Text(
            device.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}

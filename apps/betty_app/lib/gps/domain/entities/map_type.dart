enum MapType { standard, satellite }

extension MapTypeExtension on MapType {
  String get displayName {
    switch (this) {
      case MapType.standard:
        return 'Vista Estándar';
      case MapType.satellite:
        return 'Vista Satélite';
    }
  }

  String get tileUrl {
    switch (this) {
      case MapType.standard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
  }
}

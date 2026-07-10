import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A non-interactive Google Map preview that displays a pin at the given location.
/// Uses a static Google Maps image URL to avoid requiring a full map controller.
class StaticMapPreview extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;
  final double zoom;

  const StaticMapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 180,
    this.zoom = 15,
  });

  /// Whether the coordinates are valid (not zero/null island).
  bool get hasValidCoordinates =>
      latitude != 0.0 && longitude != 0.0;

  @override
  Widget build(BuildContext context) {
    if (!hasValidCoordinates) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: zoom,
          ),
          zoomControlsEnabled: false,
          scrollGesturesEnabled: false,
          tiltGesturesEnabled: false,
          rotateGesturesEnabled: false,
          myLocationButtonEnabled: false,
          markers: {
            Marker(
              markerId: const MarkerId('location'),
              position: LatLng(latitude, longitude),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 48,
            color: Color(0xFF9AA1B4),
          ),
          SizedBox(height: 8),
          Text(
            'Location not set',
            style: TextStyle(
              color: Color(0xFF9AA1B4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

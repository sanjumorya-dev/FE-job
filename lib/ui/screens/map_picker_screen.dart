import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Full-screen map where the user drags a pin to set the exact job location.
/// Returns the selected LatLng to the caller.
class MapPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const MapPickerScreen({
    super.key,
    this.initialLatitude = 28.6139, // Default: New Delhi
    this.initialLongitude = 77.2090,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLocation;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLatitude, widget.initialLongitude);
    _updateMarker();
  }

  void _updateMarker() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedLocation = position.target;
      _updateMarker();
    });
  }

  void _confirmLocation() {
    Navigator.pop(context, _selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _confirmLocation,
            child: const Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          // Center pin indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Bottom confirm button
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2182F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Coordinates display
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}, '
                'Lng: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6D7487),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

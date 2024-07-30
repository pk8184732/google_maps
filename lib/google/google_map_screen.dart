// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class GoogleMapScreen extends StatefulWidget {
//   @override
//   _GoogleMapScreenState createState() => _GoogleMapScreenState();
// }
//
// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   final Completer<GoogleMapController> _controller = Completer();
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//   final List<Marker> _markers = [];
//
//   void _addMarker(LatLng position) {
//     final String markerId = 'marker_${_markers.length + 1}';
//     final marker = Marker(
//       markerId: MarkerId(markerId),
//       position: position,
//       infoWindow: InfoWindow(title: markerId),
//       onTap: () => print('$markerId tapped'),
//     );
//     setState(() {
//       _markers.add(marker);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Google Map Example')),
//       body: GoogleMap(
//         mapType: MapType.normal,
//         initialCameraPosition: _kGooglePlex,
//         markers: Set<Marker>.of(_markers),
//         onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//         onTap: (LatLng position) {
//           _addMarker(position);
//         },
//       ),
//     );
//   }
// }






//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
//
// class GoogleMapScreen extends StatefulWidget {
//   const GoogleMapScreen({Key? key}) : super(key: key);
//
//   @override
//   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// }
//
// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
//
//   static const CameraPosition _kGooglePlex = CameraPosition(
//     target: LatLng(37.42796133580664, -122.085749655962),
//     zoom: 14.4746,
//   );
//
//   final List<Marker> markarList = [];
//   int _markerIdCounter = 1;
//   LocationData? _currentLocation;
//   late Location _location;
//
//   @override
//   void initState() {
//     super.initState();
//     _location = Location();
//     _requestLocationPermission();
//   }
//
//   Future<void> _requestLocationPermission() async {
//     bool _serviceEnabled;
//     PermissionStatus _permissionGranted;
//
//     _serviceEnabled = await _location.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _location.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }
//
//     _permissionGranted = await _location.hasPermission();
//     if (_permissionGranted == PermissionStatus.denied) {
//       _permissionGranted = await _location.requestPermission();
//       if (_permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }
//
//     _currentLocation = await _location.getLocation();
//
//     _location.onLocationChanged.listen((LocationData currentLocation) {
//       setState(() {
//         _currentLocation = currentLocation;
//       });
//       _updateCameraPosition();
//     });
//   }
//
//   Future<void> _updateCameraPosition() async {
//     if (_currentLocation != null) {
//       final GoogleMapController controller = await _controller.future;
//       controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//         target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//         zoom: 14.4746,
//       )));
//     }
//   }
//
//   void _addMarker(LatLng position , String locationName) {
//     final String markerIdVal = '$_markerIdCounter';
//     _markerIdCounter++;
//     final Marker marker = Marker(
//       markerId: MarkerId(markerIdVal),
//       position: position,
//       infoWindow: const InfoWindow(
//        // title: 'My position',
//         title: "locationName",
//       ),
//       onTap: () {
//         print('$markerIdVal clicked');
//       },
//     );
//     setState(() {
//       markarList.add(marker);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final bool canDrawPolygon = markarList.length >= 1;
//     final Set<Polygon> polygons = canDrawPolygon
//         ? {
//       Polygon(
//         polygonId: PolygonId('polygon_1'),
//         points: markarList.map((marker) => marker.position).toList(),
//         strokeWidth: 2,
//         strokeColor: Colors.red,
//         fillColor: Colors.purple.withOpacity(0.15),
//       ),
//     }
//         : {};
//
//     return Scaffold(
//         body: _currentLocation == null
//             ? const Center(child: CircularProgressIndicator())
//             : GoogleMap(
//             mapType: MapType.normal,
//             initialCameraPosition: _kGooglePlex,
//             markers: Set<Marker>.of(markarList),
//             polygons: polygons,
//             onMapCreated: (GoogleMapController controller) {
//               _controller.complete(controller);
//               _updateCameraPosition();
//             },
//             onTap: (LatLng position) {
//               _addMarker(position,"");
//             },
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             ),
//         );
//     }
//}










import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final List<Marker> markerList = [];
  int markerIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    await Permission.locationWhenInUse.request();

    if (await Permission.locationWhenInUse.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _moveCameraToPosition(position.latitude, position.longitude);
      String locationName = await _getLocationName(position.latitude, position.longitude);
      addMarker(LatLng(position.latitude, position.longitude), locationName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission denied')),
      );
    }
  }

  Future<void> _moveCameraToPosition(double latitude, double longitude) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      ),
    ));
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.locality}, ${placemark.country}';
    }
    return 'Unknown location';
  }

  void addMarker(LatLng position, String locationName) {
    final String markerIdVal = '$markerIdCounter';
    markerIdCounter++;
    final Marker marker = Marker(
      markerId: MarkerId(markerIdVal),
      position: position,
      infoWindow: InfoWindow(
        title: locationName,
      ),
      onTap: () {
        print('$markerIdVal clicked');
      },
    );
    setState(() {
      markerList.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canDrawPolygon = markerList.length >= 1;
    final Set<Polygon> polygons = canDrawPolygon
        ? {
      Polygon(
        polygonId: PolygonId('polygon_1'),
        points: markerList.map((marker) => marker.position).toList(),
        strokeWidth: 2,
        strokeColor: Colors.black,
        fillColor: Colors.black.withOpacity(0.15),
      ),
    }
        : {};

    return Scaffold(
        body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: Set<Marker>.of(markerList),
            polygons: polygons,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            onTap: (LatLng position) async {
              String locationName = await _getLocationName(position.latitude, position.longitude);
              addMarker(position, locationName);
            },
            ),
        );
    }
}
import 'package:flutter/material.dart';
import 'package:fluttermaps/models/directions.dart';
import 'package:fluttermaps/modules/repository/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  static const _initialCameraPosition = CameraPosition(
      target: LatLng(-1.286389, 36.817223),
      zoom: 11.5
  );


  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Google maps"),
        actions: [
          if(_origin!=null)
          TextButton(onPressed: ()=>_googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(CameraPosition(
              target: _origin!.position,
              zoom: 14.5,
              tilt: 50
            ))
          ), child: const Text("Origin"),style: TextButton.styleFrom(
            primary: Colors.green,
            textStyle: TextStyle(fontWeight: FontWeight.w600)
          ),),
          if(_destination!=null)
            TextButton(onPressed: ()=>_googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(CameraPosition(
                    target: _destination!.position,
                    zoom: 14.5,
                    tilt: 50
                ))
            ), child: const Text("Destination"),style: TextButton.styleFrom(
                primary: Colors.green,
                textStyle: TextStyle(fontWeight: FontWeight.w600)
            ),),

        ],
      ),
        body: Stack(
      alignment: Alignment.center,
      children: [
        GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (controller) => _googleMapController = controller,
          markers: {
            if (_origin != null) _origin!,
            if (_destination != null) _destination!
          },
          polylines: {
            if (_info != null)
              Polyline(
                polylineId: const PolylineId('overview_polyline'),
                color: Colors.red,
                width: 5,
                points: _info!.polylinePoints
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList(),
              ),
          },
          onLongPress: _addMarker,
        ),
        if (_info != null)
          Positioned(
            top: 20.0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 12.0,
              ),
              decoration: BoxDecoration(
                color: Colors.yellowAccent,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 2),
                    blurRadius: 6.0,
                  )
                ],
              ),
              child: Text(
                '${_info!.totalDistance}, ${_info!.totalDuration}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    ),
        floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
    foregroundColor: Colors.black,
    onPressed: ()=> _googleMapController.animateCamera(
      _info!=null?
          CameraUpdate.newLatLngBounds(_info!.bounds, 100):
          CameraUpdate.newCameraPosition(_initialCameraPosition)

    ),
    child: const Icon(Icons.center_focus_strong),

  )

  ,

  );

}
  Future<void> _addMarker(LatLng pos) async {
    if(_origin==null || (_origin!=null && _destination!=null)){
      setState(() {
        _origin = Marker(
          markerId: const MarkerId("origin"),
          infoWindow: const InfoWindow(
            title: "Origin",
          ),
            icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),position: pos

        );

        //reset desstination
        _destination =null;
        _info = null;
      });

    }else{
      setState(() {

        _destination = Marker(
            markerId: const MarkerId("destination"),
            infoWindow: const InfoWindow(
              title: "destination",
            ),
            icon:BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),position: pos

        );
      });


      //get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin!.position, destination: _destination!.position);
      setState(() {
        _info= directions;
      });

    }
  }
}


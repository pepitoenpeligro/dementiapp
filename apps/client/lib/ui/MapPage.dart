import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/models/Position.dart';
import 'package:location/requests/LocationRequests.dart';
import 'package:location/utils/Config.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.userId});

  final String? userId;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late LatLng center;
  late double zoomLevel;

  late List<PositionInterface> positions = [];
  late List<LatLng> positionsLatLong = [];

  @override
  void initState() {
    // TODO: implement initState
    // print("[Map] initState");
    super.initState();

    center = LatLng(37.19388914129713, -3.6154404732632024);
    zoomLevel = 14;
    loadLocations();
  }

  void loadLocations() {
    // print("[Map] loadLocations");
    if (this.mounted) {
      setState(() {
        positions = [];
      });
    }

    LocationRequests()
        .getLocations(context: context, widget.userId!)
        .then((value) {
      if (value != null) {
        // print("Pregunte por ${widget.userId!}");
        final decoded = jsonDecode(value)["locations"] as List;
        if (decoded != null) {
          // print("Locations decodificadas");
          // print(decoded);
          List<PositionInterface> newList = List.empty();

          for (var e in decoded) {
            // print(e);
            final invitacion = PositionInterface.fromJson(e);
            // newList.add(invitacion);

            newList = [...newList, invitacion];

            // print(invitacion);
            // invitations = [...invitations, invitacion];
          }

          if (this.mounted) {
            setState(() {
              // print("[MAP] set State");
              positions = newList;
              newList.sort((a, b) => a.compareTo(b));
              positions.forEach((element) => {
                    positionsLatLong = [
                      ...positionsLatLong,
                      LatLng(element.latitude!, element.longitude!)
                    ]
                  });
            });
          }

          // print("[MAP] La lista original deberia de tener");
          // print(positions);
          // print("[MAP] La lista deberia de tener");
          // print(positionsLatLong);
        }
      }
    });
  }

  // Ir a la api a preguntar

  @override
  Widget build(BuildContext context) {
    final notFilledPoints = <LatLng>[
      LatLng(37.184438, -3.607378),
      LatLng(37.19388914129713, -3.6154404732632024),
      LatLng(37.197248, -3.624199),
      LatLng(37.188235, -3.622518),
    ];

    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      // backgroundColor: Config().cardColor,
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(180),
          //   color: Colors.amber,
          // ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6, bottom: 6),
                child: Text('Ruta reciente'),
              ),
              Flexible(
                child: FlutterMap(
                  options: MapOptions(
                    center: center,
                    zoom: zoomLevel,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: positionsLatLong,
                          borderColor: Colors.orange,
                          color: Colors.orange,
                          borderStrokeWidth: 5,
                        )
                      ],
                    )

                    // PolygonLayer(polygons: [
                    //   Polygon(
                    //     points: notFilledPoints,
                    //     isFilled: false, // By default it's false
                    //     borderColor: Colors.red,
                    //     borderStrokeWidth: 4,
                    //   ),
                    // Polygon(
                    //   points: holeOuterPoints,
                    //   //holePointsList: [],
                    //   holePointsList: [holeInnerPoints],
                    //   borderStrokeWidth: 3,
                    //   borderColor: Colors.green,
                    //   color: Colors.pink.withOpacity(0.5),
                    // ),
                    // ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

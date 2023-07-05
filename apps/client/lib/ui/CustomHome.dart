import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/models/Notification.dart';
import 'package:location/models/Position.dart';
import 'package:location/models/User.dart';
import 'package:location/requests/LinksRequests.dart';
import 'package:location/requests/LocationRequests.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/state/LinksState.dart';
import 'package:location/state/LiveNotificationState.dart';
import 'package:location/timer/LocationTimerService.dart';
import 'package:location/ui/BouncingContainer.dart';
import 'package:location/ui/MapPage.dart';
import 'package:location/utils/Config.dart';
import 'package:location/utils/DateHelper.dart';
import 'package:location/utils/MyGlobalKeys.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:slimy_card/slimy_card.dart';

class CustomHome extends StatefulWidget {
  final Stream<int> stream;
  const CustomHome({super.key, required this.stream});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<CustomHome> createState() => _CustomHomeState();
}

class _CustomHomeState extends State<CustomHome>
    with SingleTickerProviderStateMixin {
  static final _myListKey = GlobalKey<AnimatedListState>(
      debugLabel: '[_CustomHomeState] _myListKey Key');

  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  static final GlobalKey globalKey =
      GlobalKey(debugLabel: '[_CustomHomeState] globalKey Key');
  final LayerLink _layerLink = LayerLink();

  late ScrollController _scrollController;

  Size topCard = Size(200, 200);
  Size bottomCard = Size(500, 500);

  double paddingMobileLeft = 16;
  double paddingMobileRight = 16;

  late ProgramaticTimerService lts;

  late Position? currentPosition;
  late StreamSubscription<Position>? positionStream;

  late bool hiddenNotificationList;

  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )..forward();

  late final Animation<double> _animation = Tween<double>(
    begin: 0,
    end: 1,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceIn,
    ),
  );

  // late BouncingContainer bouncingContainer;
  late OverlayState? overlayState;

  late GestureDetector gd = GestureDetector(
      onTap: () {
        print("A moveeer");

        _controller.forward();
      },
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value * 1.5,
            child: child,
          );
        },
        child: const Icon(
          Icons.notifications,
          size: 34,
        ),
      ));

  @override
  void initState() {
    hiddenNotificationList = true;

    overlayState = Overlay.of(context);

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      MyGlobalKeys.bouncingKey;
    });
    // WidgetsBinding.instance!.addPostFrameCallback((_) {
    //   globalKey;
    // });
    // if (BouncingContainer.globalKey.currentState?.mounted == false) {
    //   bouncingContainer =
    //       BouncingContainer(globalKey: BouncingContainer.globalKey);
    // } else {
    //   bouncingContainer = BouncingContainer(globalKey: GlobalKey());
    // }
    // bouncingContainer =
    //     BouncingContainer(globalKey: BouncingContainer.globalKey);

    super.initState();

    widget.stream.listen((number) {
      setState(() {
        print("ESCUCHOOOOOOO");

        List<NotificationModel> aux =
            Provider.of<LiveNotificationState>(context, listen: false)
                .liveNotificationCollection;
        print(Provider.of<LiveNotificationState>(context, listen: false)
            .liveNotificationCollection);
        Provider.of<LiveNotificationState>(context, listen: false)
            .liveNotificationCollection = [];

        print(Provider.of<LiveNotificationState>(context, listen: false)
            .liveNotificationCollection);
        Provider.of<LiveNotificationState>(context, listen: false)
            .liveNotificationCollection = aux;

        print(Provider.of<LiveNotificationState>(context, listen: false)
            .liveNotificationCollection);

        _myListKey.currentState?.insertItem(
            Provider.of<LiveNotificationState>(context, listen: false)
                    .liveNotificationCollection
                    .length -
                1,
            duration: Duration(microseconds: 3000));

        // BouncingContainer.bouncingGlobalKey.currentState?.bounce();
        BouncingContainer.miAlarmita.bounce();
        // BouncingContainer.miAlarmita
      });
    });

    _scrollController = new ScrollController();
    currentPosition = Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.utc(0),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);

    _requestLocationServicePermissions();
    listenToLocationChanges();

    // listenToLocationChanges();
    lts = ProgramaticTimerService(
        interval:
            Duration(milliseconds: Config().locationSendMillisecondsInterval),
        codeToExecute: sendLocation);

    lts.start();

    loadLinks();
  }

  OverlayEntry _createOverlay() {
    print("[createOverlay]");
    print(Provider.of<LiveNotificationState>(context, listen: false)
        .liveNotificationCollection);
    RenderBox renderBox = context.findRenderObject() as RenderBox;

    var size = renderBox.size;

    const double listWidth = 350;

    print("El renderBox es ${renderBox.size}");
    print("El layeredLink ${_layerLink.leaderSize}");
    print("El leader ${_layerLink.leader?.offset.toString()}");

    var x = (-(_layerLink.leader?.offset.dx)! + 500);
    x = (_layerLink.leader?.offset.dx)! -
        (renderBox.size.width) -
        (listWidth / 1.25);
    var y = ((_layerLink.leader?.offset.dy)! + 16);

    // x = -(size.width) / 4;
    // y = (size.height) - (size.height / 2);

    // x = 500;
    // y = 500;

    print("x: ${x} / y: ${y}");

    return OverlayEntry(
        builder: (context) => Positioned(
              // width: size.width,
              width: listWidth,
              child: CompositedTransformFollower(
                link: _layerLink,

                showWhenUnlinked: false,
                // offset: Offset(
                //     -(size.width) / 4, (size.height) - (size.height / 2)),
                // offset: Offset(
                //     -(size.width) / 4, (size.height) - 2 * (size.height / 2)),
                offset: Offset(x, y),
                child: Material(
                    color: Colors.transparent,
                    // elevation: 8.0,
                    child: Container(
                      height: 250,
                      color: Colors.transparent,
                      // child: ListView.separated(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: Provider.of<LiveNotificationState>(context,
                                  listen: true)
                              .liveNotificationCollection
                              .length,
                          itemBuilder: (context, index) {
                            NotificationModel data =
                                Provider.of<LiveNotificationState>(context,
                                        listen: false)
                                    .liveNotificationCollection[index];

                            String title = data.title ?? '';
                            String message = data.message ?? '';
                            String notificationId = data.id ?? '';
                            String timestamp = data.timestamp ?? "0";

                            int timestampInt = int.parse(timestamp);
                            String? date =
                                DateHelper.timestampToDate(timestampInt);
                            var dateContent = date ?? "";
                            return Dismissible(
                              onDismissed: (direction) {
                                Provider.of<LiveNotificationState>(context,
                                        listen: false)
                                    .liveNotificationCollection
                                    .removeAt(index);
                              },
                              key: UniqueKey(),
                              child: Card(
                                child: Container(
                                  child: (Row(
                                    children: [
                                      Expanded(
                                          child: ListTile(
                                        leading: CircleAvatar(
                                            child: Icon(Icons.message)),
                                        title: Text(title),
                                        subtitle: Text(message),
                                        trailing: Text(dateContent),
                                        // tileColor: Colors.amber.shade300,
                                      )),
                                    ],
                                  )),
                                ),
                              ),
                            );
                            // return Container(
                            //   // key: UniqueKey(),
                            //   child: (Row(
                            //     children: [
                            //       Expanded(
                            //         // width: listWidth,
                            //         // height: 32,
                            //         child: ListTile(
                            //             title: Text(Provider.of<
                            //                         LiveNotificationState>(
                            //                     context,
                            //                     listen: false)
                            //                 .liveNotificationCollection[index]
                            //                 .title!)),
                            //       )
                            //     ],
                            //   )),
                            // );
                          }),
                    )

                    // const [
                    //   ListTile(
                    //     title: Text('India'),
                    //   ),
                    //   ListTile(
                    //     title: Text('Australia'),
                    //   ),
                    //   ListTile(
                    //     title: Text('USA'),
                    //   ),
                    //   ListTile(
                    //     title: Text('Canada'),
                    //   ),

                    // ),
                    ),
              ),
            ));
  }

  void _requestLocationServicePermissions() async {
    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      /// open app settings so that user changes permissions

      if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android) {
        await Geolocator.openAppSettings();
        await Geolocator.openLocationSettings();
        return;
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    lts.stop();
    // _controller.dispose();
    // BouncingContainer.globalKey
    super.dispose();
  }

  void captureLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = position;
    });
  }

  void sendLocation() {
    // enviar datos a api gateway con el timer

    PositionInterface newPosition = PositionInterface();
    newPosition.latitude = currentPosition?.latitude;
    newPosition.longitude = currentPosition?.longitude;
    newPosition.createdAt = DateTime.now().millisecondsSinceEpoch;

    if (Provider.of<AuthState>(context, listen: false).user?.participation ==
        "cared") {
      print("[sendLocation] sending location cause timer ${DateTime.now()}");
      if (newPosition.latitude! != 0 && newPosition.longitude! != 0) {
        LocationRequests().sendLocation(
            newPosition.latitude!, newPosition.longitude!,
            context: context);
      }
    }
  }

  void listenToLocationChanges() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 100,
    );
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) {
        if (this.mounted) {
          setState(() {
            print("[listenToLocationChanges] location has changed");
            currentPosition = position;
          });
        }
      },
    );
  }

  void loadLinks() {
    // Provider.of<LinksState>(context, listen: false).linksUserCollection =
    //     List.empty();

    Provider.of<LinksState>(context, listen: false).linksUserCollection.clear();

    // var authStatus = Provider.of<AuthState>(context, listen: false)
    //     .user
    //     ?.authorizationToken
    //     ?.isNotEmpty;
    // if (authStatus ?? false) {
    LinksRequests().getLinks(context: context).then((value) {
      // print("[RAW] Hemos recibido los links");
      // print(value);
      List<User> newList = List.empty();

      if (value != null) {
        final decoded = jsonDecode(value)["links"] as List;
        // print("Links decodificados");
        // print(decoded);

        for (var e in decoded) {
          // print(e);
          final user = User.fromJson(e);
          // newList.add(invitacion);
          newList = [...newList, user];

          Provider.of<LinksState>(context, listen: false).addItem(user);

          // print(invitacion);
          // invitations = [...invitations, invitacion];
        }

        // setState(() {

        //   Provider.of<LinksState>(context, listen: false).linksUserCollection =
        //       newList;
        // });
      }
      // print("[Links] Finalmente veo: ");
      // print(
      //     Provider.of<LinksState>(context, listen: false).linksUserCollection);
      // print("-----------");
    });
    // }
  }

  Widget _left(context) {
    return Padding(
        padding: MediaQuery.of(context).size.width < 600
            ? EdgeInsets.only(left: 18, bottom: 16, top: 32, right: 18)
            : EdgeInsets.only(left: 64, bottom: 16, top: 32, right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hi ${Provider.of<AuthState>(context, listen: false).user?.displayName}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(width: 18),
                Icon(
                  Icons.waving_hand,
                  size: 24,
                  color: Colors.yellow.shade700,
                ),
              ],
            ),
            Text(
              Provider.of<AuthState>(context, listen: false)
                          .user
                          ?.participation ==
                      "cared"
                  ? "Find your catetakers"
                  : 'Find your cared people',
              style: TextStyle(
                  fontSize: 24, color: Theme.of(context).colorScheme.tertiary),
              // Theme.of(context).textTheme.headlineMedium,
            )
          ],
        ));
    // padding: EdgeInsets.only(left: 128, bottom: 16, top: 16, right: 32),
  }

  Widget _right(context) {
    return Padding(
        padding: MediaQuery.of(context).size.width < 600
            ? const EdgeInsets.only(left: 18, bottom: 16, top: 32, right: 18)
            : const EdgeInsets.only(right: 64, bottom: 16, top: 48, left: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // gd
            CompositedTransformTarget(
              link: _layerLink,
              child: GestureDetector(
                // child: Container(),
                // child: bouncingContainer,
                child: BouncingContainer.miAlarmita,
                onTap: () {
                  // setState(() {
                  //   if (hiddenNotificationList) {
                  //     _overlayEntry = _createOverlay();
                  //     overlayState!.insert(_overlayEntry!);
                  //   } else {
                  //     _overlayEntry!.remove();
                  //   }
                  //   hiddenNotificationList = !hiddenNotificationList;
                  // });
                  print(hiddenNotificationList);
                  if (hiddenNotificationList) {
                    _overlayEntry = _createOverlay();
                    overlayState?.insert(_overlayEntry!);
                  } else {
                    _overlayEntry?.remove();
                  }
                  hiddenNotificationList = !hiddenNotificationList;

                  print("Notification tocado");
                },
              ),
            )

            // const Icon(
            //   Icons.notifications,
            //   size: 34,
            // )
          ],

          // padding: EdgeInsets.only(right: 64, bottom: 16, top: 16, left: 32),
        ));
  }

  Widget _textHeader(context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_left(context), _right(context)]);
  }

  Widget _listOfUsersLinked(context) {
    return SafeArea(
        child: Padding(
      // Hacerlo responsive con el dispositvito
      padding: MediaQuery.of(context).size.width < 600
          ? const EdgeInsets.only(left: 24, top: 16, bottom: 16, right: 24)
          : const EdgeInsets.only(left: 64, top: 32, bottom: 32, right: 64),
      child: ListView.builder(
          key: UniqueKey(),
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          // controller: _scrollController,
          shrinkWrap: true,
          itemCount: Provider.of<LinksState>(context, listen: true)
              .linksUserCollection
              .length,
          itemBuilder: (context, index) {
            return Container(
                child: Row(children: [
              SlimyCard(
                color: Theme.of(context).colorScheme.secondaryContainer,
                // Theme.of(context).colorScheme.secondary[700].withOpacity(0.32),
                // color: Theme.of(context).colorScheme.secondary,
                // color: Config().cardColor,
                width: MediaQuery.of(context).size.width < 600
                    ? 300
                    : bottomCard.width,
                topCardHeight: MediaQuery.of(context).size.height < 700
                    ? 150
                    : topCard.height,
                bottomCardHeight: MediaQuery.of(context).size.height < 700
                    ? 350
                    : bottomCard.height,
                borderRadius: 15,
                topCardWidget: Text(
                    "${Provider.of<LinksState>(context, listen: true).linksUserCollection[index].userName}"),
                bottomCardWidget: Provider.of<AuthState>(context, listen: true)
                            .user
                            ?.participation ==
                        "caretaker"
                    ? MapPage(
                        key: UniqueKey(),
                        userId: Provider.of<LinksState>(context, listen: true)
                            .linksUserCollection[index]
                            .userId,
                      )
                    : Text(
                        "${Provider.of<LinksState>(context, listen: true).linksUserCollection[index].email}"),
                slimeEnabled: true,
              ),
              SizedBox(
                width: 64,
              )
            ]));
          }),
    ));
  }

  Widget _compound(context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        _textHeader(context),
        Row(
          children: [
            Expanded(
                child:
                    SizedBox(height: 900, child: _listOfUsersLinked(context)))
          ],
        ),
        Row(children: [
          // QrImage(
          //   data: "1234567890",
          //   version: QrVersions.auto,
          //   size: 200.0,
          // )
        ]),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // return _textHeader(context);
    // return _listOfUsersLinked(context);
    return _compound(context);
  }
}

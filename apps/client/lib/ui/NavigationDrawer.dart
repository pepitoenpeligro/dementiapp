import 'package:flutter/material.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/ui/about.dart';
import 'package:location/utils/AuthStatusEnum.dart';
import 'package:location/utils/Metadata.dart';
import 'package:provider/provider.dart';

class NavigationDrawerCustom extends StatefulWidget {
  const NavigationDrawerCustom({super.key});

  @override
  State<NavigationDrawerCustom> createState() => _NavigationDrawerCustomState();
}

class _NavigationDrawerCustomState extends State<NavigationDrawerCustom> {
  String? version = "";
  String buildNumber = "";
  @override
  void initState() {
    MetadataProvider.version().then((value) {
      setState(() {
        version = value;
      });
    });
    MetadataProvider.buildNumber().then((value) {
      setState(() {
        buildNumber = value;
      });
    });
    super.initState();
  }

  // method to log user out
  void logUserOut(BuildContext context) {
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Navigator.pop(context);
    // Navigator.pop(context);
    var authState = Provider.of<AuthState>(context, listen: false);
    Provider.of<AuthState>(context, listen: false).authStatus =
        AuthStatus.NOT_LOGGED_IN;
    Provider.of<AuthState>(context, listen: false).user = null;
    Provider.of<AuthState>(context, listen: false).userId = "";
    // go back to login page
    Navigator.of(context).pushNamed('/SignIn');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width < 500 ? 286 : 364,
      backgroundColor: Colors.grey[400],
      child: Column(
        children: [
          // Drawer header
          const DrawerHeader(
            child: Center(
              child: Icon(
                Icons.people,
                size: 64,
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.pop(context);
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => const AboutPage(),
          //         ),
          //       );
          //     },
          //     child: ListTile(
          //       leading: const Icon(Icons.link),
          //       title: Text(
          //         "Link Person to be cared",
          //         style: TextStyle(color: Colors.grey[700]),
          //       ),
          //     ),
          //   ),
          // ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ListTile(
              leading: const Icon(Icons.logout),
              onTap: () => logUserOut(context),
              title: Text(
                "Logout",
                style: TextStyle(color: Color.fromARGB(255, 84, 37, 37)),
              ),
            ),
          ),
          Spacer(
            flex: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 24),
            child: ListTile(
              leading: const Icon(Icons.info),
              title: Text(
                "Version $version-$buildNumber",
                style: TextStyle(color: Color.fromARGB(255, 84, 37, 37)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

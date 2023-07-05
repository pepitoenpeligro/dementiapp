import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;
  late int _pageIndex = 0;
  late bool lastPage;

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController(
      initialPage: 0,
    );
    lastPage = false;

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(children: [
        Expanded(
          child: PageView.builder(
              itemCount: data.length,
              onPageChanged: (index) {
                if (this.mounted) {
                  setState(() {
                    _pageIndex = index;
                  });
                }
              },
              controller: _pageController,
              itemBuilder: (context, index) => OnBoardingContent(
                    lottieAnimation: data[index].lottie,
                    title: data[index].title,
                    description: data[index].description,
                    height: data[index].height,
                    width: data[index].width,
                  )),
        ),
        Row(
          children: [
            ...List.generate(
                data.length,
                (index) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: DotIndicator(
                        isActive: (index == _pageIndex),
                      ),
                    )),
            const Spacer(),
            SizedBox(
                height: 60,
                width: 60,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        // backgroundColor: Theme.of(context).colorScheme.primary,
                        // foregroundColor: Theme.of(context)
                        //     .colorScheme
                        //     .tertiary
                        //     .withOpacity(0.8),
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(1),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withOpacity(0.82),
                        // backgroundColor: Theme.of(context)
                        //     .colorScheme
                        //     .tertiary
                        //     .withAlpha(50),
                        shape: CircleBorder()),
                    onPressed: () {
                      // print(
                      //     "_pageIndex: ${_pageIndex} / data.length: ${data.length}");

                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.ease);

                      if (_pageIndex == data.length - 1) {
                        lastPage = true;
                      } else {
                        lastPage = false;
                      }

                      if (_pageIndex == data.length - 1 && lastPage) {
                        // print("[Onboarding] Last Page, debemos cambiar");
                        Navigator.pop(context);

                        while (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }

                        Navigator.of(context).pushNamed('/SignIn');
                      }
                    },
                    child: Icon(
                      Icons.arrow_circle_right,
                    ))),
          ],
        )
      ]),
    )));
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
      height: isActive ? 12 * 1.5 : 4 * 1.5,
      width: 4 * 1.5,
      decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.secondary.withOpacity(1)
              : Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withOpacity(0.82),
          // color: isActive
          //     ? Theme.of(context).colorScheme.tertiary
          //     : Theme.of(context).colorScheme.tertiary.withOpacity(0.4),
          // Theme.of(context)
          //                   .colorScheme
          //                   .secondary
          //                   .withOpacity(1),
          //               backgroundColor: Theme.of(context)
          //                   .colorScheme
          //                   .secondaryContainer
          //                   .withOpacity(0.82),
          // color: isActive
          //     ? Theme.of(context).primaryColor
          //     : Theme.of(context).primaryColor.withOpacity(0.4),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
    );
  }
}

class Onboard {
  final String lottie, title, description;
  final double height, width;

  Onboard(
      {required this.lottie,
      required this.title,
      required this.description,
      required this.height,
      required this.width});
}

final List<Onboard> data = [
  Onboard(
    lottie: "assets/animations/ComposicionPepito.json",
    title: "Bienvenido a DementiApp",
    description:
        "DementiApp te da la bienvenida.\nSigue el proceso de onboarding y \nverás las funcionalidades que ofrece",
    height: 320,
    width: 320,
  ),
  Onboard(
    lottie: "assets/animations/29476-locate-gps.json",
    title: "Tracking",
    description:
        "Con un rol cuidador podrás ubicar y\n ver la historia de ubicaciones de las personas\nque más quieres.",
    height: 320,
    width: 320,
  ),
  Onboard(
    lottie: "assets/animations/28219-alert.json",
    title: "Alertas",
    description:
        "Con un rol cuidador podrás recibir alertas\ncuando alguno de tus seres queridos\nse ubique en una zona no habitual",
    height: 320,
    width: 320,
  ),
];

class OnBoardingContent extends StatelessWidget {
  const OnBoardingContent(
      {super.key,
      required this.lottieAnimation,
      required this.title,
      required this.description,
      required this.height,
      required this.width});

  final String lottieAnimation, title, description;
  final double height, width;

  @override
  Widget build(BuildContext context) {
    var lottie = Lottie.asset(lottieAnimation,
        height: height,
        width: width,
        fit: BoxFit.cover,
        frameRate: FrameRate.max);

    return Column(children: [
      const Spacer(),
      Container(
        height: height,
        width: width,
        child: lottie,
      ),
      Text(title,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.w500)),
      const SizedBox(height: 16),
      Text(
        description,
        textAlign: TextAlign.center,
      ),
      const Spacer()
    ]);
  }
}

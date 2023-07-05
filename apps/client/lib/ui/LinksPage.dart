import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:location/models/Invitation.dart';
import 'package:location/models/User.dart';

import 'package:location/requests/InvitationsRequests.dart';
import 'package:location/requests/LinksRequests.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/utils/DateHelper.dart';
import 'package:location/utils/UIButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:slimy_card/slimy_card.dart';

import '../models/Link.dart';

class LinksPage extends StatefulWidget {
  const LinksPage({super.key});

  @override
  State<LinksPage> createState() => _LinksPageState();
}

class _LinksPageState extends State<LinksPage>
    with SingleTickerProviderStateMixin {
  late LottieBuilder _animationLink;
  late TextEditingController _emailController;
  late User? user;

  late LottieBuilder successfullySent;
  late LottieBuilder errorSent;
  late LottieBuilder succesfulyDeleted;
  late LottieBuilder linkedSuccess;
  late List<Invitation> invitations = List.empty();
  late List<Link> links = List.empty();
  late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = Provider.of<AuthState>(context, listen: false).user;

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));

    _animationLink = Lottie.asset('assets/animations/link.json',
        repeat: true, controller: _animationController);

    _animationController.reverse(from: 1);
    _animationController.repeat(reverse: true);
    _animationController.addStatusListener((status) {
      // print(status);
      if (status == AnimationStatus.forward) {
        _animationController.reverse(from: 1);
      }
      if (status == AnimationStatus.dismissed) {
        _animationController.reverse(from: 1);
        _animationController.repeat(reverse: true);
      }
    });

    _emailController = TextEditingController();
    successfullySent = Lottie.asset('assets/animations/sentSuccessfully.json');
    errorSent = Lottie.asset('assets/animations/sentError.json');

    succesfulyDeleted = Lottie.asset('assets/animations/deleteInvitation.json');
    linkedSuccess = Lottie.asset('assets/animations/linkedSuccess.json');

    captureInvitations();
  }

  void captureLinks() {}

  void captureInvitations() {
    invitations = List.empty();

    InvitationsRequests()
        .getInvitations(user?.email, context: context)
        .then((value) {
      // print("[RAW] Hemos recibido las invitaciones");
      // print(value);
      List<Invitation> newList = List.empty();

      if (value != null) {
        final decoded = jsonDecode(value)["invitations"] as List;
        // print("Invitaciones decodificadas");
        // print(decoded);

        for (var e in decoded) {
          // print(e);
          final invitacion = Invitation.fromJson(e);
          // newList.add(invitacion);
          newList = [...newList, invitacion];

          // print(invitacion);
          // invitations = [...invitations, invitacion];
        }

        if (this.mounted) {
          setState(() {
            invitations = newList;
          });
        }
      }
      // print("[Invitaciones] Finalmente veo: ");
      // print(invitations);
    });
  }

  Widget _entryField(
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        // color: Colors.grey.shade200,
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.30),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.tertiary)),
          // borderSide: BorderSide(color: Colors.deepPurple)),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _createInvitationForm(context) {
    return Container(
        child: _entryField(
            "Enter the email address of the person to be cared for.",
            controller: _emailController));
  }

  void showAlert(BuildContext context, LottieBuilder lottie) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(height: 250, width: 250, child: lottie),
            ));
  }

  Widget _confirmButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      child: UIButton(
        label: "Send Invitation Care",
        onPressed: () {
          InvitationsRequests()
              .createInvitation(user?.email, _emailController.text,
                  context: context)
              .then((value) {
            if (value == true) {
              // print("La invitacion se ha creado");
              // _emailController.clear();

              Future.delayed(Duration(seconds: 0),
                  () => showAlert(context, successfullySent));
              Future.delayed(Duration(milliseconds: 3020), () {
                Navigator.of(context).pop(true);
                captureInvitations();
                if (this.mounted) {
                  setState(() {
                    _emailController.clear();
                    _emailController = TextEditingController();
                  });
                }
              });
            } else {
              print("La invitación no se ha creado");
              Future.delayed(
                  Duration(seconds: 0), () => showAlert(context, errorSent));

              _emailController.clear();
              Future.delayed(Duration(milliseconds: 1850),
                  () => Navigator.of(context).pop(true));
            }
          });
        },
        // onPressed: _doSendInvitation,
        borderRadius: 30,
      ),
    );
  }

  Widget _listInvitations(context) {
    return Padding(
        // Hacerlo responsive con el dispositvito
        padding: EdgeInsets.only(left: 8, top: 32, bottom: 32, right: 8),
        child: ListView.builder(
          key: UniqueKey(),
          scrollDirection: Axis.horizontal,
          physics: const AlwaysScrollableScrollPhysics(),
          // controller: _scrollController,
          shrinkWrap: true,
          itemCount: invitations.length,
          itemBuilder: (context, index) {
            return Container(
                child: Row(children: [
              SlimyCard(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                width: 250,
                topCardHeight: 250,
                bottomCardHeight: 200,
                borderRadius: 15,
                topCardWidget: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Pending to care: ${invitations[index].cared}"),
                    SizedBox(height: 16),
                    Text(
                        "Invitation created at: ${DateHelper.timestampToDate(invitations[index].createdAt)}")
                  ],
                ),
                bottomCardWidget: user?.participation == "cared"
                    ? UIButton(
                        label: "Confirm Invitation",
                        onPressed: () {
                          final actualInvitation = invitations[index];

                          LinksRequests()
                              .createLink(actualInvitation.invitationId,
                                  context: context)
                              .then((success) {
                            // animacion de vinculo
                            Future.delayed(Duration(seconds: 0),
                                () => showAlert(context, linkedSuccess));
                            Future.delayed(Duration(milliseconds: 2100), () {
                              Navigator.of(context).pop(true);
                              captureInvitations();
                              // captureLinks();
                            });

                            // linkedSuccess
                          });

                          // Ir a crear un link con la misma info
                        })
                    : UIButton(
                        label: "Remove Invitation",
                        onPressed: () {
                          print("Vamos a tirar");
                          print(invitations[index]);

                          InvitationsRequests()
                              .deleteInvitation(invitations[index].invitationId,
                                  context: context)
                              .then((value) {
                            if (value != null) {
                              // all go ok

                              Future.delayed(Duration(seconds: 0),
                                  () => showAlert(context, succesfulyDeleted));
                              Future.delayed(Duration(milliseconds: 1750), () {
                                Navigator.of(context).pop(true);
                                captureInvitations();
                              });
                            } else {
                              Future.delayed(Duration(seconds: 0),
                                  () => showAlert(context, errorSent));

                              Future.delayed(Duration(milliseconds: 1850),
                                  () => Navigator.of(context).pop(true));
                            }
                          });
                        }),
                slimeEnabled: true,
              ),
              SizedBox(
                width: 64,
              )
            ]));
          },
        ));
  }

  Widget _compound(context) {
    return Center(
        child: SingleChildScrollView(
            child: Container(
      constraints: BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          user?.participation != "cared"
              ? Center(
                  child: SizedBox(
                  height: 200,
                  child: _animationLink,
                ))
              : SizedBox(
                  width: 0,
                ),
          user?.participation != "cared"
              ? _createInvitationForm(context)
              : SizedBox(
                  width: 0,
                ),
          user?.participation != "cared"
              ? _confirmButton(context)
              : SizedBox(
                  width: 0,
                ),

          SizedBox(
            height: 56,
          ),

          user?.participation != "cared"
              ? invitations.isNotEmpty
                  ? Text(
                      "Pending Invitations. Waiting to confirm",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : SizedBox(
                      height: 0,
                    )
              : invitations.isNotEmpty
                  ? Text(
                      "Pending Invitations. Please confirm invitations",
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : SizedBox(
                      height: 0,
                    ),
          SizedBox(child: _listInvitations(context), height: 600)

          // List of invitations
        ],
      ),
    )));
  }

  // Widget _compound(context) {
  //   return Center(
  //       child: SingleChildScrollView(
  //     child: Container(
  //       constraints: BoxConstraints(maxWidth: 600),
  //       padding: const EdgeInsets.symmetric(horizontal: 30),
  //       alignment: Alignment.center,
  //       // color: Colors.amber,
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           Container(
  //               // color: Colors.red,
  //               child: SizedBox(
  //                   width: 200,
  //                   height: 200,
  //                   child: Visibility(visible: true, child: _animationLink))),
  //           const SizedBox(height: 1),
  //           _entryField(
  //               "Enter the email address of the person to be cared for.",
  //               controller: _emailController)
  //           // _entryField('Enter Code', controller: _confirmCodeController),
  //           // _confirmButton(context),
  //         ],
  //       ),
  //     ),
  //   ));
  // }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _compound(context);
  }
}

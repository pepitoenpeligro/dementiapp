import 'package:flutter/material.dart';
import 'package:location/models/User.dart';
import 'package:location/requests/UserRequests.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/ui/MyBoxes.dart';
import 'package:location/utils/UIButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

// class CreateAccount extends StatefulWidget {
//   final VoidCallback? loginCallback; //!

//   const CreateAccount({Key? key, this.loginCallback}) : super(key: key);
//   @override
//   State<StatefulWidget> createState() => _CreateAccountState();
// }

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  int currentStep = 0;
  int numSteps = 3;
  bool _isFocused1 = false;
  bool _isFocused2 = false;

  late TextEditingController _displayNameController;
  late TextEditingController _birthDateController;
  TextEditingController dateController = TextEditingController();
  User user = User();
  late LottieBuilder animation;

  @override
  void initState() {
    animation = Lottie.asset('assets/animations/fillFormAccount.json');

    dateController.text = "";
    if (Provider.of<AuthState>(context, listen: false).user != null) {
      user = Provider.of<AuthState>(context, listen: false).user!;
    }

    Provider.of<AuthState>(context, listen: false).user;
    _displayNameController = TextEditingController();
    _birthDateController = TextEditingController();

    super.initState();
  }

  continueStep() {
    setState(() {
      if (currentStep < numSteps) {
        currentStep = ((currentStep + 1));
      }

      if (currentStep == numSteps - 1) {
        print("Has llegado a la ultima opcion");

        if (_isFocused1) {
          print("La opcion seleccionada fue: ");
          print("Caja 1");
        } else if (_isFocused2) {
          print("La opcion seleccionada fue: ");
          print("Caja 2");
        }
      }

      if (currentStep == numSteps) {
        currentStep = numSteps - 1;
        print("Considero que ya hay que salir de esta pantalla");

        String displayName = _displayNameController.text;
        String birthDate = _birthDateController.text;

        String participation = "caretaker"; // cared

        if (_isFocused1) {
          print("La opcion seleccionada fue: ");
          print("Caja 1");
          participation = "caretaker";
        } else if (_isFocused2) {
          print("La opcion seleccionada fue: ");
          print("Caja 2");
          participation = "cared";
        }
        user.displayName = displayName;
        DateTime date = DateTime.parse(dateController.text);
        int timestamp = date.toUtc().millisecondsSinceEpoch;
        user.birthdate = timestamp;
        user.participation = participation;

        print("Voy a pedirle a la api que me meta ese usuario:");
        print(user.toJson().toString());

        UserRequests().updateUser(user, context: context).then((value) {
          if (value == true) {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/Entrypoint');
          } else {
            print("Your data is not correct, please refill again your data");
            currentStep = 0;
            _displayNameController.clear();
            dateController.clear();
            _isFocused1 = false;
            _isFocused2 = false;
          }
        }).catchError((error) {
          print("Your request could not be processed right now ${error}");
          currentStep = 0;
          _displayNameController.clear();
          dateController.clear();
          _isFocused1 = false;
          _isFocused2 = false;
        });

        // hacer peticion a la api
        // metiendo el display name, el birthdate y el participation
        // y que la lambda cambie el firstLogin a false;
      }

      print(currentStep);
    });
  }

  cancelStep() {
    setState(() {
      if (currentStep > 0) {
        currentStep = ((currentStep - 1));
      }
    });
  }

  setStep(int step) {
    setState(() {
      currentStep = step;
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

  Widget controlsBuilder(context, details) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Container(
          //   child: Row(children: [], mainAxisAlignment: MainAxisAlignment.center,),
          // )

          ElevatedButton(
            onPressed: details.onStepContinue,
            child: const Text('Next'),
            // style: ElevatedButton.styleFrom(
            //     backgroundColor: Theme.of(context).primaryColor)
          ),
          const SizedBox(width: 16),
          OutlinedButton(
              onPressed: details.onStepCancel, child: const Text('Back'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var boxes = MyBoxes();
    return Scaffold(
        appBar: AppBar(
          title: Text('Complete your Account',
              style: const TextStyle(fontSize: 20)),
          centerTitle: true,
        ),
        body: Center(
            child: ListView(children: [
          ConstrainedBox(
            constraints: BoxConstraints(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // color: Colors.blue,
                  child: SizedBox(
                    child: animation,
                    height: 200,
                    width: 200,
                  ),
                ),
                SizedBox(
                  height: 64,
                ),
                Container(
                    constraints: BoxConstraints(maxWidth: 1400),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    // color: Colors.amber,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Stepper(
                              onStepContinue: continueStep,
                              onStepCancel: cancelStep,
                              type: StepperType.vertical,
                              elevation: 0,
                              controlsBuilder: controlsBuilder,
                              // margin: const EdgeInsets.all(36),
                              physics: const ClampingScrollPhysics(),
                              onStepTapped: (step) => setStep(step),
                              steps: [
                                Step(
                                    title: Text('Display Name'),
                                    content: _entryField('Enter you full Name',
                                        controller: _displayNameController),
                                    isActive: currentStep == 0,
                                    state: currentStep >= 0
                                        ? StepState.complete
                                        : StepState.disabled),
                                Step(
                                    title: Text('Birthdate'),
                                    content: Center(
                                        child: TextField(
                                      controller:
                                          dateController, //editing controller of this TextField
                                      decoration: const InputDecoration(
                                          icon: Icon(Icons
                                              .calendar_today), //icon of text field
                                          labelText:
                                              "Enter Date" //label text of field
                                          ),
                                      readOnly:
                                          true, // when true user cannot edit text
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: DateTime
                                                    .now(), //get today's date
                                                firstDate: DateTime(
                                                    1900), //DateTime.now() - not to allow to choose before today.
                                                lastDate: DateTime.now());

                                        if (pickedDate != null) {
                                          print(
                                              pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd').format(
                                                  pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                                          print(
                                              formattedDate); //formatted date output using intl package =>  2022-07-04
                                          //You can format date as per your need

                                          setState(() {
                                            dateController.text =
                                                formattedDate; //set foratted date to TextField value.
                                          });
                                        } else {
                                          print("Date is not selected");
                                        }
                                      },
                                    )),
                                    isActive: currentStep == 1,
                                    state: currentStep >= 1
                                        ? StepState.complete
                                        : StepState.disabled),
                                Step(
                                    title: const Text('Your role'),
                                    content: Container(
                                        // color: Colors.lightBlue,
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // height: 250,
                                        // width: 250,
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isFocused1 = !_isFocused1;
                                              _isFocused2 = !_isFocused1;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            width: _isFocused1
                                                ? (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 124
                                                    : 264)
                                                : (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 52
                                                    : 200),
                                            height: _isFocused1
                                                ? (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 124
                                                    : 264)
                                                : (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 124
                                                    : 200),
                                            duration: const Duration(
                                                milliseconds: 500),
                                            child: Expanded(
                                              // color: Colors.amber,
                                              child: Column(children: [
                                                Lottie.asset(
                                                    'assets/animations/searching.json'),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Text('caretaker',
                                                    textScaleFactor:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 0.8
                                                            : 2.2))
                                              ]),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          width: 32,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isFocused2 = !_isFocused2;
                                              _isFocused1 = !_isFocused2;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            width: _isFocused2
                                                ? (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 96
                                                    : 264)
                                                : (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 52
                                                    : 200),
                                            height: _isFocused2
                                                ? (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 124
                                                    : 264)
                                                : (MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 124
                                                    : 200),
                                            duration: const Duration(
                                                milliseconds: 500),
                                            child: Column(children: [
                                              Lottie.asset(
                                                  'assets/animations/lost.json'),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              Text(
                                                'cared',
                                                textScaleFactor:
                                                    (MediaQuery.of(context)
                                                                .size
                                                                .width <
                                                            500
                                                        ? 0.8
                                                        : 2.2),
                                              )
                                            ]),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 200,
                                        )
                                      ],
                                    )),
                                    isActive: currentStep == 2,
                                    state: currentStep >= 2
                                        ? StepState.complete
                                        : StepState.disabled)
                              ],
                              currentStep: currentStep,
                            ),
                          ),
                        ])),
              ],
            ),
          )
        ])));
  }
}

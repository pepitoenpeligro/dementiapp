import 'package:flutter/material.dart';
import 'package:location/ui/SnackbarGlobal.dart';
import 'package:location/utils/UIButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../utils/Loader.dart';
import '../state/AuthState.dart';

class ConfirmUser extends StatefulWidget {
  const ConfirmUser({Key? key}) : super(key: key);

  @override
  State<ConfirmUser> createState() => _ConfirmUserState();
}

class _ConfirmUserState extends State<ConfirmUser> {
  late TextEditingController _usernameController;
  late TextEditingController _confirmCodeController;

  late Loader loader;
  String toShow = "";

  @override
  void initState() {
    _confirmCodeController = TextEditingController();
    _usernameController = TextEditingController();
    loader = Loader();
    super.initState();
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

  void _doConfirm() {
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isWorking) {
      return;
    }
    loader.showLoader(context);
    var isValid = true;
    // var isValid = Utility.validateCredentials(
    //     context, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .confirm(_usernameController.text, _confirmCodeController.text,
              context: context)
          .then((status) {
        if (status == true) {
          SnackbarGlobal.successSnackBar(context, 'User confirmed!');

          Future.delayed(Duration(milliseconds: 1400), () {
            Navigator.pop(context);

            Navigator.of(context).pushNamed('/SignIn');
          });
        } else {
          loader.hideLoader();

          SnackbarGlobal.errorSnackBar(
              context, 'User not confirmed. Your user or code is incorrect');
        }
      });
    }

    loader.hideLoader();
  }

  Widget _confirmButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35),
      child: UIButton(
        label: "Confirm User",
        onPressed: _doConfirm,
        borderRadius: 30,
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          alignment: Alignment.center,
          // color: Colors.amber,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  // color: Colors.red,
                  child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Visibility(
                          visible: true,
                          child: Lottie.asset(
                              'assets/animations/verificationMail.json',
                              repeat: true)))),
              const SizedBox(height: 1),
              _entryField('Enter username', controller: _usernameController),
              _entryField('Enter Code', controller: _confirmCodeController),
              _confirmButton(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirm User"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/ui/SnackbarGlobal.dart';
import 'package:location/utils/Loader.dart';
import 'package:location/utils/UIButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SignUp extends StatefulWidget {
  final VoidCallback? loginCallback; //!
  const SignUp({Key? key, this.loginCallback}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> with SingleTickerProviderStateMixin {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late LottieBuilder signUpAnimation;
  late AnimationController _controller;
  late Loader loader;
  String toShow = "";

  @override
  void initState() {
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 3800));

    signUpAnimation = Lottie.asset('assets/animations/register.json',
        controller: _controller, repeat: true);
    _controller.forward();
    // _controller.repeat();

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

  Widget _registerButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 35),
      child: UIButton(
        label: "Register Now!",
        onPressed: _doRegister,
        borderRadius: 30,
      ),
    );
  }

  void _doRegister() {
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
          .signUp(_usernameController.text, _emailController.text,
              _passwordController.text,
              context: context)
          .then((status) {
        print("STATUS ");
        print(status);
        if (status == true) {
          SnackbarGlobal.successSnackBar(context, 'User registered!');

          Future.delayed(Duration(milliseconds: 1400), () {
            Navigator.pop(context);
            Navigator.of(context).pushNamed('/SignIn');
          });
        } else {
          loader.hideLoader();
          // Utils.customSnackBar(context, '[SignUp] your credentials are wrong');
          SnackbarGlobal.errorSnackBar(context,
              'User not registered. Your credentials seems to be wrong');

          // Future.delayed(Duration(milliseconds: 800), () {
          //   ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          // });
        }
      });
    }
    loader.hideLoader();
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
                      width: 180,
                      height: 180,
                      child:
                          Visibility(visible: true, child: signUpAnimation))),
              const SizedBox(height: 1),
              _entryField('Enter username', controller: _usernameController),
              _entryField('Enter email', controller: _emailController),
              _entryField('Enter password',
                  controller: _passwordController, isPassword: true),
              _registerButton(context),
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
        title: Text("SignUp"),
        centerTitle: true,
      ),
      body: _body(context),
    );
  }
}

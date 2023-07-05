import 'package:flutter/material.dart';
import 'package:location/state/AuthState.dart';
import 'package:location/ui/SnackbarGlobal.dart';
import 'package:location/utils/Loader.dart';
import 'package:location/utils/UIButton.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SignIn extends StatefulWidget {
  final VoidCallback? loginCallback; //!

  const SignIn({Key? key, this.loginCallback}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late Loader loader;
  static final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: '[_SignInState] _scaffoldKey Key');

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    loader = Loader();

    // widget.loginCallback!();

    super.initState();
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
                          child:
                              Lottie.asset('assets/animations/hello.json')))),
              const SizedBox(height: 1),
              _entryField('Enter username', controller: _emailController),
              _entryField('Enter password',
                  controller: _passwordController, isPassword: true),
              _emailLoginButton(context),
              const SizedBox(
                height: 16,
              ),
              _registerPageButton(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labelButton(String title, {Function? onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      child: Text(
        title,
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _emailLoginButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: UIButton(
        label: "Login",
        onPressed: _emailLogin,
        borderRadius: 30,
      ),
    );
  }

  Widget _registerPageButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: UIButton(
          borderRadius: 30,
          label: "Register",
          color: Theme.of(context).colorScheme.tertiary.withOpacity(0.585),
          onPressed: () {
            Navigator.of(context).pushNamed('/SignUp');
          }),
    );
  }

  void _emailLogin() {
    loader.showLoader(context);
    var state = Provider.of<AuthState>(context, listen: false);
    if (state.isWorking) {
      return;
    }

    var isValid = true;
    // var isValid = Utility.validateCredentials(
    //     context, _emailController.text, _passwordController.text);
    if (isValid) {
      state
          .signIn(_emailController.text, _passwordController.text,
              context: context)
          .then((status) {
        if (state.user != null) {
          // print("User token ${}")
          // print("USUARIO");
          // print(state.user);
          // print("[_emailLogin] state.user no es null");

          if (status == "UserNotConfirmedException") {
            print("El usuario no esta confirmado, hay que llevarlo a confirm");
            Navigator.pop(context);
            // widget.loginCallback!();
            Navigator.of(context).pushNamed('/ConfirmUser');
          }

          state.getCurrentUser(context: context).then((status) {
            print("El status completo del usuario es: ");
            print(state.user!.toJson().toString());

            if (state.user!.firstLogin == true) {
              // ventana de createAccount
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/CreateAccount');
            } else {
              // SnackbarGlobal.show("HOLA PAPI");

              SnackbarGlobal.successSnackBar(context, 'Login Success');

              Future.delayed(Duration(milliseconds: 1400), () {
                Navigator.pop(context);

                Navigator.of(context).pushNamed('/Entrypoint');
              });
            }
          }).catchError((error) {
            // SnackbarGlobal.show("HOLA PAPI2");
            SnackbarGlobal.errorSnackBar(context, 'Error getting current user');
            // Future.delayed(Duration(milliseconds: 1000), () {
            //   print("[Quitamos el snackbar]");
            //   ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            // });
          });
        } else {
          loader.hideLoader();
          print("[_emailLogin] state.user ES NULL");
          print("EL STATUS ES");
          print(status);

          if (status == "UserNotConfirmedException") {
            print("El usuario no esta confirmado, hay que llevarlo a confirm");
            Navigator.pop(context);
            // widget.loginCallback!();
            Navigator.of(context).pushNamed('/ConfirmUser');
          } else {
            // Utils.customSnackBar(context, '[Login] your credentials are wrong');
            SnackbarGlobal.errorSnackBar(context, 'Your credentials are wrong');
          }
        }

        loader.hideLoader();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Sign in', style: const TextStyle(fontSize: 20)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            iconSize: 20.0,
            onPressed: () {
              while (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.of(context).pushNamed("/SplashPage");
            }),
      ),
      body: _body(context),
    );
  }
}

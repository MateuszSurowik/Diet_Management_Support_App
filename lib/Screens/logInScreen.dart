import 'package:diet_management_suppport_app/Screens/mainScreen.dart';
import 'package:diet_management_suppport_app/main.dart';
import 'package:diet_management_suppport_app/services/firebaseClient.dart';
import 'package:diet_management_suppport_app/widgets/textFormFieldDecorated.dart';
import 'package:flutter/material.dart';

class logInScreen extends StatefulWidget {
  const logInScreen({super.key});

  @override
  State<logInScreen> createState() => _logInScreenState();
}

class _logInScreenState extends State<logInScreen> {
  Firebaseclient _firebaseclient = Firebaseclient();
  bool _signIn = true;
  String _signButtonText = 'Sign Up';
  String _signText = 'Sign In';
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _singState() {
    if (_signIn == true) {
      _signIn = false;
      _signButtonText = 'Sign In';
      _signText = 'Sign Up';
    } else {
      _signIn = true;
      _signButtonText = 'Sign Up';
      _signText = 'Sign in';
    }
  }

  void _goToHoursScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => MainScreen(
                toggleTheme: (int val) {
                  setState(() {
                    if (val == 1) {
                      kIsDark = false;
                    } else {
                      kIsDark = true;
                    }
                  });
                },
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: const Text("Diet Every Value"),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(1),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            opacity: 0.3,
            fit: BoxFit.cover,
            image: AssetImage('lib/utils/assets/Logo.png'),
          ),
        ),
        child: SingleChildScrollView(
          reverse: true,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.logo_dev,
                  size: 150,
                ),
                Text(
                  _signText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 40),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Column(
                    children: [
                      Textformfielddecorated(
                        textEditingController: _emailController,
                        text: 'Email',
                        validator: (input) {
                          if (input == null ||
                              input.trim().length < 2 ||
                              input.toString().contains('@') == false) {
                            return "uncorrect email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Textformfielddecorated(
                        textEditingController: _passwordController,
                        text: 'Password',
                        validator: (password) {
                          if (password == null || password.length < 8) {
                            return _signIn
                                ? 'uncorrect password'
                                : 'password must have at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _signIn
                                ? "if you don't have account Sing up here"
                                : "if you have account Sing up here",
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _singState();
                              });
                            },
                            child: Text(
                              _signButtonText,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.cyan),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (_signIn &&
                                      await _firebaseclient.userExists(
                                          email: _emailController.text,
                                          password: _passwordController.text)) {
                                    _goToHoursScreen(context);
                                  } else if (_signIn == false) {
                                    _firebaseclient.signUpUser(
                                        email: _emailController.text,
                                        password: _passwordController.text);
                                  } else {
                                    return;
                                  }
                                }
                              },
                              icon: const Icon(Icons.arrow_right),
                              style: IconButton.styleFrom(
                                  iconSize: 40, backgroundColor: Colors.cyan),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

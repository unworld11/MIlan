import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // User signed in successfully
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // User could not be signed in
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sign-In Error'),
            content: Text('Unable to sign in to the app.'),
            actions: <Widget>[
              TextButton(
                child:  Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // An error occurred while signing in
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Sign-In Error'),
          content: Text(e.toString()),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Screen'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _handleSignIn,
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Milan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _offsetAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.5)).animate(
            CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInCubic,
                reverseCurve: Curves.easeOutCubic));
    _controller.forward();
    Timer(
      const Duration(seconds: 3),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SlideTransition(
          position: _offsetAnimation,
          child: const Text(
            'Milan',
            style: TextStyle(
              fontSize: 52.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Lato',
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final suppliesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    suppliesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          const Positioned(
            top: 28.0,
            left: 16.0,
            child: Text(
              'Home',
              style: TextStyle(
                fontSize: 72.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 25,
            right: 16.0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              },
              child: Container(
                color: Colors.transparent,
                width: 50,
                child: const Icon(Icons.arrow_forward_ios_sharp),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextField(
                        style: TextStyle(color: Colors.white),
                        controller: nameController, // set the controller
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: addressController, // set the controller
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: suppliesController, // set the controller
                        decoration: const InputDecoration(
                          labelText: 'Supplies Required',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          // Get the form data
                          String name = nameController.text;
                          String address = addressController.text;
                          String supplies = suppliesController.text;

                          // Save the data to Firestore
                          firestore.collection('supplies').add({
                            'name': name,
                            'address': address,
                            'supplies': supplies,
                          }).then((value) {
                            // Success
                            print('Data saved successfully');
                          }).catchError((error) {
                            // Error
                            print('Failed to save data: $error');
                          });
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add_box_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          Positioned(
            top: 80.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[900]!, Colors.grey[800]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[900]!,
                    blurRadius: 4.0,
                    offset: const Offset(2.0, 2.0),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: const Text(
                'Supplies Needed',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato',
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              'Form Data',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lato',
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                color: Colors.transparent,
                width: 50,
                child: const Icon(Icons.arrow_back_ios_new_sharp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
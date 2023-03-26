import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:milan/UsersListPage.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _checkProfile();
    }
  }

  Future<void> _checkProfile() async {
    final uid = _user!.uid;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      setState(() {});
    }
  }

  void _handleSkipSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> MakeProfile() async {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    final name = user.displayName;
    final email = user.email;
    final photo = user.photoURL;
    final contact = user.phoneNumber;
    final docRef = firestore.collection('users').doc(uid);
    docRef.set({
      'name': name,
      'email': email,
      'photo': photo,
      'contact': contact,
      'uid': uid,
    });
  }

  Future<void> _handleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // User signed in successfully

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // User could not be signed in
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign-In Error'),
            content: const Text('Unable to sign in to the app.'),
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
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        toolbarOpacity: 0.5,
        toolbarTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('Login / Sign Up'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: Container()),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    onPressed: _handleSignIn,
                    child: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                    onPressed: _handleSkipSignIn,
                    child: const Text('Skip Sign In'),
                  ),
                  const SizedBox(height: 20.0),
                  TextButton(
                      onPressed: MakeProfile,
                      child: const Text('Make a Profile')),
                ],
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
      title: 'Milan',
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
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final suppliesController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  _loadProfile() async {
    // Get the current user's ID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Retrieve the user's data from the 'users' collection
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    // Extract the user's email, name, and photo
    userId = FirebaseAuth.instance.currentUser!.uid;
    String email = FirebaseAuth.instance.currentUser!.email!;
    String name = userDoc.get('name');
    String photoUrl = userDoc.get('photo');
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Navigate to the profile page with the user's information
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfileScreen(
                userId: userId,
                email: email,
                name: name,
                photoUrl: photoUrl,
                currentUserId: currentUserId,
              )),
    );
  }

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
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          const Positioned(
            top: 28.0,
            left: 30.0, // Add padding here
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
            right: 10.0, // Move closer to the edge
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecondScreen()),
                );
              },
              child: Container(
                color: Colors.transparent,
                width: 60, // Increase size
                child: const Icon(Icons.arrow_forward_ios_sharp,
                    size: 40.0, color: Colors.white), // Increase size
              ),
            ),
          ),
          Positioned(
            bottom: 33.0,
            left: 10.0,
            child: IconButton(
              onPressed: _loadProfile,
              icon: const Icon(Icons.account_circle,
                  size: 60.0, color: Colors.white),
            ),
          ),
          Positioned(
            top: 33,
            right: 10.0, // Move closer to the edge
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UsersListPage()),
                );
              },
              icon: const Icon(Icons.chat, size: 40.0, color: Colors.green),
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
                        style: const TextStyle(color: Colors.white),
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                        ),
                      ),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: phoneController, // set the controller
                        keyboardType: TextInputType
                            .phone, // set the keyboard type to phone
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 16.0), // Add margin
                        ),
                        onPressed: () {
                          // Get the form data
                          String name = nameController.text;
                          String address = addressController.text;
                          String supplies = suppliesController.text;
                          String phone = phoneController.text;

                          // Save the data to Firestore
                          firestore.collection('supplies').add({
                            'name': name,
                            'address': address,
                            'supplies': supplies,
                            'phone': phone,
                          }).then((value) {
                            // Success
                            print('Data saved successfully');
                            nameController.clear();
                            addressController.clear();
                            suppliesController.clear();
                            phoneController.clear();

                            Navigator.pop(context);
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

@override
class SecondScreen extends StatefulWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController _searchController = TextEditingController();

  TextEditingController get searchController => _searchController;

  @override
  void initState() {
    super.initState();
  }

  Future<List<DocumentSnapshot>> getSuppliesData(String address) async {
    print('Location: $address');
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore
        .collection('supplies')
        .where('address', isEqualTo: address)
        .get();
    print('Query snapshot length: ${querySnapshot.docs.length}');
    for (var doc in querySnapshot.docs) {
      print(doc.data());
    }
    return querySnapshot.docs;
  }

  void _navigateToChat(String userId, String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          peerId: userId,
          peerName: userName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ), // Space for status bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by location...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    // Use the suppliesData list to display your UI based on the search query
                    // ...
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: getSuppliesData(_searchController.text),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final suppliesData = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: suppliesData.length,
                  itemBuilder: (context, index) {
                    final doc = suppliesData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 8.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${doc['name'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Address: ${doc['address'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Phone: ${doc['phone']?.toString() ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Supplies: ${doc['supplies'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                                const SizedBox(height: 16.0),
                                ElevatedButton(
                                  onPressed: () => _navigateToChat(
                                    doc.id,
                                    doc['name'],
                                  ),
                                  child: const Text('Help out'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          //add a back button to home-screen
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerName;

  const ChatPage({Key? key, required this.peerId, required this.peerName})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _roomId = '82091008-a484-4a89-ae75-a22bf8d6f3ac';
  final List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
    firstName: '',
    lastName: '',
    imageUrl: '',
  );

  Stream<QuerySnapshot<Map<String, dynamic>>>? _messagesStream;

  String createRoomId(String userId, String peerId) {
    if (userId.hashCode <= peerId.hashCode) {
      return '$userId-$peerId';
    } else {
      return '$peerId-$userId';
    }
  }

  @override
  void initState() {
    super.initState();
    _roomId = createRoomId(_user.id, widget.peerId);
    _messagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('roomId', isEqualTo: _roomId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
      roomId: _roomId,
    );

    await FirebaseFirestore.instance
        .collection('messages')
        .add(textMessage.toJson());
    _addMessage(textMessage);
  }

  types.TextMessage _textMessageFromJson(Map<String, dynamic> data) {
    final authorData = data['author'] as Map<String, dynamic>? ?? {};
    final author = types.User(
      id: authorData['id'] ?? '',
      firstName: authorData['firstName'] ?? '',
      lastName: authorData['lastName'] ?? '',
      imageUrl: authorData['imageUrl'] ?? '',
    );

    return types.TextMessage(
      id: data['id'] ?? '',
      author: author,
      text: data['text'] ?? '',
      createdAt: data['createdAt'] ?? 0,
      metadata: data['metadata'] ?? {},
      roomId: data['roomId'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
      ),
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _messagesStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _messages.clear();
              for (var doc in snapshot.data!.docs) {
                final message =
                    _textMessageFromJson(doc.data());
                if (message.roomId == _roomId) {
                  _messages.add(message);
                }
              }
              _messages.sort(
                  (a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
            }

            return Chat(
              messages: _messages,
              onSendPressed: _handleSendPressed,
              user: _user,
            );
          },
        ),
      ),
    );
  }
}

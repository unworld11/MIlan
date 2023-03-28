import 'package:flutter/material.dart';
import 'package:milan/main.dart'; // Import your ChatPage here.
import 'package:cloud_firestore/cloud_firestore.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({Key? key}) : super(key: key);

  @override
  _UsersListPageState createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream;
  TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _userList = [];

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
  }

  void _navigateToProfile(
      String userId,
      String userName,
      String userEmail,
      String userPhoto,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          userId: userId,
          name: userName,
          email: userEmail,
          photoUrl: userPhoto,
          currentUserId: "your_current_user_id", // Replace this with the actual current user ID
        ),
      ),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> getFilteredList(String query) {
    if (query.isEmpty) {
      return _userList;
    } else {
      return _userList.where((user) {
        String name = user.data()['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[900],
        appBar: AppBar(
        title: const Text('Users'),
    backgroundColor: Colors.black12,
    actions: [
    IconButton(
    onPressed: () {
    setState(() {
    _searchController.clear();
    });
    },
    icon: const Icon(Icons.clear),
    )
    ],
    bottom: PreferredSize(
    preferredSize: const Size.fromHeight(48.0),
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
    hintText: 'Search users by name',
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20.0),
    ),
    suffixIcon: IconButton(
    onPressed: () {
    setState(() {});
    },
    icon: const Icon(Icons.search),
    ),
    ),
    ),
    ),
    ),
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: _usersStream,
    builder: (context, snapshot) {
    if (snapshot.hasData) {
    _userList = snapshot.data!.docs;
    List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredList =
    getFilteredList(_searchController.text);
    return ListView.builder(
    itemCount: filteredList.length,
    itemBuilder: (context, index) {
    final user = filteredList[index].data();
    return ListTile(
    title: Text(
    user['name'] ?? '',
    style: const TextStyle(color: Colors.white),
    ),
    subtitle: Text(
    user['email'] ?? '',
    style: const TextStyle(color: Colors.white60),
    ),
    leading: user['photo'] != null
    ? CircleAvatar(
    backgroundImage: NetworkImage(user['photo']),
    )
        : const CircleAvatar(
    backgroundColor: Colors.blueGrey,
    child: Icon(Icons.person, color: Colors.white),
    ),
    onTap: () => _navigateToProfile(
    filteredList[index].id,
    user['name'] ?? '',
    user['email'] ?? '',
    user['photo'] ?? '',
    ),
      tileColor: Colors.deepOrange[900],
      hoverColor: Colors.grey[700],
    );
    },
    );
    } else if (snapshot.hasError) {
      return Center(
        child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
      );
    }

    return const Center(
      child: CircularProgressIndicator(),
    );
    },
    ),
    );
  }
}


    class ProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;
  final String photoUrl;
  final String currentUserId;

  const ProfileScreen({
    required this.userId,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  String _bio = '';

  @override
  void initState() {
    super.initState();
    _getBioFromDatabase();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _getBioFromDatabase() async {
    // Get a reference to the user's document in the "users" collection
    final docRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);

    // Get the document snapshot
    final docSnapshot = await docRef.get();

    // Extract the value of the "bio" field from the snapshot
    final bio = docSnapshot.data
      ()?['bio'] ?? '';

    // Set the value of the text controller and the state variable to the retrieved bio
    setState(() {
      _bio = bio;
      _bioController.text = bio;
    });
  }

  void _saveBio() async {
    // Save the bio to the Firebase database
    final docRef = FirebaseFirestore.instance.collection('users').doc(widget.currentUserId);
    await docRef.set({'bio': _bioController.text}, SetOptions(merge: true));

    // Display a snackbar to show that the bio has been saved
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bio saved!'),
      ),
    );

    // Update the state variable with the new bio value
    setState(() {
      _bio = _bioController.text;
    });
  }


  void _navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          peerId: widget.userId,
          peerName: widget.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentUserProfile = widget.userId == widget.currentUserId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Add an edit button to allow the user to edit their bio
          if (isCurrentUserProfile)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        title: const Text('Edit Bio'),
                        content: TextField(
                          controller: _bioController,
                          decoration: const InputDecoration(
                            hintText: 'Enter your bio here',
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: const Text('Save'),
                            onPressed: () {
                              _saveBio();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                );
              },
            ),
        ],

      ),
      body: Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.photoUrl),
              ),
              const SizedBox(height: 16),
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 16),
              // Display the user's bio
              Text(
                _bio,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              ElevatedButton(
                onPressed: _navigateToChat,
                child: const Text('Message'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... Rest of the build method

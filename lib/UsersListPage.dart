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

  @override
  void initState() {
    super.initState();
    _usersStream = FirebaseFirestore.instance.collection('users').snapshots();
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
      appBar: AppBar(title: const Text('Users')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _usersStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final user = snapshot.data!.docs[index].data();
                return ListTile(
                  title: Text(user['name'] ?? ''),
                  subtitle: Text(user['email'] ?? ''),
                  leading: user['photo'] != null
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(user['photo']),
                  )
                      : const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  onTap: () => _navigateToChat(
                    snapshot.data!.docs[index].id,
                    user['name'] ?? '',
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
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

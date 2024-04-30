import 'package:chat_application/const_config/color_config.dart';
import 'package:chat_application/const_config/text_config.dart';
import 'package:chat_application/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:intl/intl.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final FirebaseFirestore firebase = FirebaseFirestore.instance;

  Stream<List<UserData>> getUsersStream() {
    return firebase.collection('users').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserData.fromMap(doc.data())).toList());
  }

  Future<DateTime?> getLastActive(String uuid) async {
    var lastMessageSnapshot = await firebase
        .collection('chat')
        .where('uuid', isEqualTo: uuid)
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (lastMessageSnapshot.docs.isNotEmpty) {
      Timestamp lastActive = lastMessageSnapshot.docs.first.get('time');
      return lastActive.toDate();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.scaffoldColor,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Registered Users",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: MyColor.primary,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserData>>(
              stream: getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData) {
                  var users = snapshot.data!;
                  if (users.isEmpty) {
                    return Text("No users found",
                        style: TextDesign().bodyTextSmall);
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      UserData user = users[index];
                      return FutureBuilder<DateTime?>(
                        future: getLastActive(user.uuid!),
                        builder: (context, lastActiveSnapshot) {
                          String lastActiveText = "Never Active";
                          if (lastActiveSnapshot.hasData &&
                              lastActiveSnapshot.data != null) {
                            lastActiveText = DateFormat('dd/MM/yyyy hh:mm a')
                                .format(lastActiveSnapshot.data!);
                          }
                          return Container(
                            margin: const EdgeInsets.all(8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 15.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    RandomAvatar(
                                      user.name ?? 'Unknown User',
                                      trBackground: false,
                                      height: 40,
                                      width: 40,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(user.name ?? 'Unknown User',
                                        style: TextDesign().bodyTextSmall),
                                  ],
                                ),
                                Text(lastActiveText,
                                    style: TextStyle(color: Colors.grey[600]))
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                } else {
                  return Text("No data available",
                      style: TextDesign().bodyTextSmall);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

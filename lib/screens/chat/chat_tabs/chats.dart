import 'package:chat_application/widgets/input_widgets/simple_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:random_avatar/random_avatar.dart';

import '../../../const_config/color_config.dart';
import '../../../models/user_model.dart';
import '../../../services/chat_service.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final firebase = FirebaseFirestore.instance;
  final messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> _fetchUserName(String uuid) async {
    var doc = await firebase.collection('users').doc(uuid).get();
    if (doc.exists) {
      UserData user = UserData.fromMap(doc.data()!);
      return user.name ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.scaffoldColor,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firebase.collection('chat').orderBy('time').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.active) {
                  var data = snapshot.data!.docs;

                  return data.length != 0
                      ? ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            var message =
                                data[index].data() as Map<String, dynamic>;
                            var uuid = message['uuid'] as String?;
                            bool isCurrentUser = uuid == auth.currentUser?.uid;

                            return Align(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isCurrentUser)
                                      FutureBuilder<String>(
                                          future: _fetchUserName(uuid!),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return RandomAvatar(
                                                snapshot.data!,
                                                trBackground: false,
                                                height: 20,
                                              );
                                            } else {
                                              return const SizedBox(
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }
                                          }),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Card(
                                        color: isCurrentUser
                                            ? MyColor.primary
                                            : MyColor.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            message['message'] as String? ??
                                                'No message content',
                                            style: TextStyle(
                                              color: isCurrentUser
                                                  ? MyColor.white
                                                  : MyColor.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isCurrentUser)
                                      FutureBuilder<String>(
                                        future: _fetchUserName(
                                            auth.currentUser!.uid),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return RandomAvatar(
                                              snapshot.data!,
                                              trBackground: false,
                                              height: 35,
                                            );
                                          } else {
                                            return const SizedBox(
                                              height: 35,
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : const Center(child: Text("No Chats to show"));
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: SimpleInputField(
                    controller: messageController,
                    hintText: "Type a message...",
                    needValidation: true,
                    errorMessage: "Message box can't be empty",
                    fieldTitle: "",
                    needTitle: false,
                  ),
                ),
                IconButton(
                  icon: const Icon(LineAwesomeIcons.paper_plane,
                      color: MyColor.primary),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      ChatService().sendChatMessage(
                        message: messageController.text,
                      );
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

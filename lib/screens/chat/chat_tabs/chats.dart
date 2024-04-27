import 'package:chat_application/const_config/text_config.dart';
import 'package:chat_application/widgets/custom_buttons/Rouded_Action_Button.dart';
import 'package:chat_application/widgets/input_widgets/simple_input_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../const_config/color_config.dart';
import '../../../services/chat_service.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final firebase = FirebaseFirestore.instance;
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColor.scaffoldColor,
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: firebase.collection('chat').orderBy('time').snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData && snapshot.connectionState == ConnectionState.active) {
                    var data = snapshot.data.docs;
                    return data.length != 0
                        ? ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Card(
                                  color: Colors.white,
                                  child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(snapshot.data.docs[index]['message']),
                                ),),
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
            SimpleInputField(
              controller: messageController,
              hintText: "Aa..",
              needValidation: true,
              errorMessage: "Message box can't be empty",
              fieldTitle: "",
              needTitle: false,
            ),
            const SizedBox(
              height: 10,
            ),
            RoundedActionButton(
              onClick: () {
                ChatService().sendChatMessage(message: messageController.text);
              },
              label: "Send Message",
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ));
  }
}

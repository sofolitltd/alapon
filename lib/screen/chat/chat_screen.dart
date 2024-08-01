import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/screen/chat/all_user_screen.dart';
import '/screen/chat/chat_details_screen.dart';
import '../../Model/user_model.dart';
import '../profile/profile_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  String getChatId(String userId1, String userId2) {
    // Ensure a consistent chat ID regardless of user order
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bangla Chat'),
        elevation: 1,
        centerTitle: false,
        actions: [
          //
          IconButton.filledTonal(
            onPressed: () {
              //
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllUserScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
          ),

          const SizedBox(width: 4),
          //
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: const CircleAvatar(
              radius: 20,
            ),
          ),

          //
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('users')
            .doc(uid)
            .collection('friends')
            .where('status', isEqualTo: 'accepted')
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.docs;
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No message found'));
          }

          //
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              String userId = data[index].id;
              String lastMessage = data[index].get('lastMessage');
              String lastMessageTime = data[index].get('lastMessageTime');
              String senderId = data[index].get('senderId');
              String seen = data[index].get('seen');

              //
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.data!.exists) {
                    return const SizedBox();
                  }

                  var data = snapshot.data!.data();

                  Map<String, dynamic> json = data as Map<String, dynamic>;
                  UserModel userModel = UserModel.fromJson(json);
                  String userId = userModel.uid;

                  if (userId == uid) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    onTap: () async {
                      //
                      await firestore
                          .collection('users')
                          .doc(uid)
                          .collection('friends')
                          .doc(userId)
                          .get()
                          .then((val) {
                        //
                        if (val.exists) {
                          val.reference.update({
                            "seen": 'seen',
                          });
                        }
                      });

                      //

                      //
                      String chatId = getChatId(uid, userId);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailsScreen(
                            chatId: chatId,
                            receiverId: userId,
                            receiverName: userModel.name,
                          ),
                        ),
                      );
                    },
                    leading: const CircleAvatar(),
                    title: Text(userModel.name),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lastMessage.isEmpty ? 'Write a message' : lastMessage,
                          style: TextStyle(
                            color: (seen == '') ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          lastMessageTime.toString().isEmpty
                              ? ''
                              // : '',
                              : timeAgo(lastMessageTime),
                          style: TextStyle(
                            color: seen == '' ? Colors.black : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

//
String timeAgo(String lastMessageTime) {
  int microsecondsSinceEpoch = int.parse(lastMessageTime);

  // Convert microseconds to milliseconds
  int millisecondsSinceEpoch = microsecondsSinceEpoch ~/ 1000;

  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  DateTime now = DateTime.now();

  if (dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day) {
    // Same day, show time with AM/PM
    return DateFormat('h:mm a').format(dateTime);
  } else {
    // Different day, show month and date
    return DateFormat('MMM d').format(dateTime);
  }
}

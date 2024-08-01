import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetailsScreen extends StatefulWidget {
  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  final String chatId;
  final String receiverId;
  final String receiverName;

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(),
            const SizedBox(width: 8),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                    reverse: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      String currentUserId =
                          _auth.currentUser!.uid; // Get current user ID

                      return Align(
                        alignment: data['senderId'] == currentUserId
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: data['senderId'] == currentUserId
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            data['text'],
                            style: TextStyle(
                              color: data['senderId'] == currentUserId
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      String currentUserId = _auth.currentUser!.uid;

                      //
                      var data = {
                        'text': _messageController.text.trim(),
                        'senderId': currentUserId,
                        'timestamp': FieldValue.serverTimestamp(),
                      };
                      //
                      var time =
                          DateTime.now().microsecondsSinceEpoch.toString();
                      var data1 = {
                        'lastMessage': _messageController.text.trim(),
                        'lastMessageTime': time,
                        'senderId': currentUserId,
                        'seen': 'seen',
                      };

                      var data2 = {
                        'lastMessage': _messageController.text.trim(),
                        'lastMessageTime': time,
                        'senderId': currentUserId,
                        'seen': '',
                      };
                      //
                      _messageController.clear();

                      //
                      await _firestore
                          .collection('chats')
                          .doc(widget.chatId)
                          .collection('messages')
                          .add(data);

                      //
                      await _firestore
                          .collection('users')
                          .doc(currentUserId)
                          .collection('friends')
                          .doc(widget.receiverId)
                          .get()
                          .then((val) {
                        val.reference.update(data1);
                      });

                      //
                      await _firestore
                          .collection('users')
                          .doc(widget.receiverId)
                          .collection('friends')
                          .doc(currentUserId)
                          .get()
                          .then((val) {
                        val.reference.update(data2);
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

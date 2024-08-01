import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Model/user_model.dart';
import 'user_profile.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var data = snapshot.data!.docs;
          return ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              var json = data[index].data() as Map<String, dynamic>;
              UserModel userModel = UserModel.fromJson(json);

              String userId = userModel.uid;

              if (userId == uid) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfile(
                        userModel: userModel,
                        uid: uid,
                        userId: userId,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 32,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userModel.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              //
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(uid)
                                          .collection('friends')
                                          .doc(userId)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(height: 48);
                                        }

                                        //
                                        if (snapshot.hasError ||
                                            !snapshot.hasData ||
                                            !snapshot.data!.exists) {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              sendFriendRequest(uid, userId);
                                            },
                                            icon: const Icon(Icons
                                                .person_add_alt_1_outlined),
                                            label: const Text('Add Friend'),
                                          );
                                        }

                                        var status =
                                            snapshot.data!.get('status');

                                        //
                                        if (status == 'sent') {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              cancelFriendRequest(uid, userId);
                                            },
                                            icon: const Icon(Icons.cancel),
                                            label: const Text('Cancel Request'),
                                          );
                                        } else if (status == 'pending') {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              acceptFriendRequest(uid, userId);
                                            },
                                            icon: const Icon(Icons
                                                .check_circle_outline_rounded),
                                            label: const Text('Accept Request'),
                                          );
                                        } else if (status == 'accepted') {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              unfollowFriend(uid, userId);
                                            },
                                            icon:
                                                const Icon(Icons.person_remove),
                                            label: const Text('Unfollow'),
                                          );
                                        } else if (status == 'sent') {
                                          return ElevatedButton.icon(
                                            onPressed: () {
                                              cancelFriendRequest(uid, userId);
                                            },
                                            icon: const Icon(Icons
                                                .person_add_alt_1_outlined),
                                            label: const Text('Add Friend'),
                                          );
                                        }
                                        //
                                        return ElevatedButton.icon(
                                          onPressed: () {
                                            sendFriendRequest(uid, userId);
                                          },
                                          icon: const Icon(
                                              Icons.person_add_alt_1_outlined),
                                          label: const Text('Add Friend'),
                                        );
                                      },
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: SizedBox(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Send Friend Request
void sendFriendRequest(String currentUserId, String friendUserId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore
      .collection('users')
      .doc(friendUserId)
      .collection('friends')
      .doc(currentUserId)
      .set({
    'status': 'pending',
    'timestamp': FieldValue.serverTimestamp(),
    'lastMessage': '',
    'lastMessageTime': '',
    'senderId': '',
    'seen': '',
  });

  await firestore
      .collection('users')
      .doc(currentUserId)
      .collection('friends')
      .doc(friendUserId)
      .set({
    'status': 'sent',
    'timestamp': FieldValue.serverTimestamp(),
    'lastMessage': '',
    'lastMessageTime': '',
    'senderId': '',
    'seen': '',
  });
}

// accept Friend Request
void acceptFriendRequest(String currentUserId, String friendUserId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore
      .collection('users')
      .doc(friendUserId)
      .collection('friends')
      .doc(currentUserId)
      .set({
    'status': 'accepted',
    'timestamp': FieldValue.serverTimestamp(),
    'lastMessage': '',
    'lastMessageTime': '',
    'senderId': '',
    'seen': '',
  });

  await firestore
      .collection('users')
      .doc(currentUserId)
      .collection('friends')
      .doc(friendUserId)
      .set({
    'status': 'accepted',
    'timestamp': FieldValue.serverTimestamp(),
    'lastMessage': '',
    'lastMessageTime': '',
    'senderId': '',
    'seen': '',
  });
}

// Cancel Friend Request
void cancelFriendRequest(String currentUserId, String friendUserId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore
      .collection('users')
      .doc(friendUserId)
      .collection('friends')
      .doc(currentUserId)
      .delete();

  await firestore
      .collection('users')
      .doc(currentUserId)
      .collection('friends')
      .doc(friendUserId)
      .delete();
}

// Unfollow Friend
void unfollowFriend(String currentUserId, String friendUserId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await firestore
      .collection('users')
      .doc(currentUserId)
      .collection('friends')
      .doc(friendUserId)
      .delete();

  await firestore
      .collection('users')
      .doc(friendUserId)
      .collection('friends')
      .doc(currentUserId)
      .delete();
}

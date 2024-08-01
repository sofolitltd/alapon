import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/Model/user_model.dart';
import 'all_user_screen.dart';
import 'chat_details_screen.dart';

class UserProfile extends StatelessWidget {
  const UserProfile(
      {super.key,
      required this.userModel,
      required this.uid,
      required this.userId});

  final UserModel userModel;
  final String uid;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                color: Colors.teal.shade100,
              ),
              const Positioned(
                bottom: -40,
                right: 50,
                child: CircleAvatar(
                  radius: 80,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          //
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              userModel.name,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('friends')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Add Friend'),
                  );
                }

                var status = snapshot.data!.get('status');

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
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Accept Request'),
                  );
                } else if (status == 'accepted') {
                  return Row(
                    children: [
                      //
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            unfollowFriend(uid, userId);
                          },
                          icon: const Icon(Icons.person_remove),
                          label: const Text('Unfollow'),
                        ),
                      ),

                      const SizedBox(width: 16),

                      //
                      Expanded(
                        flex: 1,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            String getChatId(String userId1, String userId2) {
                              // Ensure a consistent chat ID regardless of user order
                              List<String> ids = [userId1, userId2];
                              ids.sort();
                              return ids.join('_');
                            }

                            String chatId = getChatId(uid, userId);

                            //
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
                          icon: const Icon(Icons.message),
                          label: const Text('Message'),
                        ),
                      ),
                    ],
                  );
                } else if (status == 'sent') {
                  return ElevatedButton.icon(
                    onPressed: () {
                      cancelFriendRequest(uid, userId);
                    },
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Add Friend'),
                  );
                }
                //
                return ElevatedButton.icon(
                  onPressed: () {
                    sendFriendRequest(uid, userId);
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Add Friend'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

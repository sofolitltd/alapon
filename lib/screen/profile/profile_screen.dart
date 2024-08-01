import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/main.dart';
import '../../Model/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          //
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              //
              var data = snapshot.data!;

              if (!data.exists) {
                return const SizedBox();
              }

              //
              Map<String, dynamic> json = data.data() as Map<String, dynamic>;
              UserModel userModel = UserModel.fromJson(json);
              //
              return Column(
                children: [
                  //
                  Card(
                    child: ListTile(
                      onTap: () {},
                      leading: const CircleAvatar(),
                      title: Text(userModel.name),
                      subtitle: Text(userModel.email),
                    ),
                  ),

                  const SizedBox(height: 8),
                  //
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Mobile'),
                          Text(
                            userModel.mobile,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),
          //

          ElevatedButton(
            onPressed: () {
              //
              FirebaseAuth.instance.signOut().then((auth) {
                print('Log out');
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WrapperScreen()),
                    (route) => false);
              });
            },
            child: const Text('Log Out'),
          )
        ],
      ),
    );
  }
}

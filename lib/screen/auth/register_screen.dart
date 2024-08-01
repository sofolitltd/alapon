import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../chat/chat_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _mobileNumberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)!.settings.arguments as String?;

    //
    String capitalizeEachWord(String input) {
      if (input.isEmpty) {
        return input;
      }
      return input
          .split(' ')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
          .join(' ');
    }

    //
    void createAccount(route) async {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        try {
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (userCredential.user!.uid.isEmpty) return;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'uid': userCredential.user!.uid,
            'name': capitalizeEachWord(_nameController.text.trim()),
            'mobile': _mobileNumberController.text.trim(),
            'email': _emailController.text.trim(),
            'image': '',
            'timestamp': FieldValue.serverTimestamp(),
          }).then((val) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Successfully Create your Account')));
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
                (route) => false);
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Signup Failed: $e')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: Center(
        child: Align(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 450,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            hintText: 'Enter Certificate Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                                _mobileNumberFocusNode); // Move focus to next
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _mobileNumberController,
                          focusNode: _mobileNumberFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Mobile',
                            hintText: 'Enter Mobile No',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                                _emailFocusNode); // Move focus to next
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter Active Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(
                                _passwordFocusNode); // Move focus to next
                          },
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter Strong Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          obscureText: !_isPasswordVisible,
                          onFieldSubmitted: (_) {
                            createAccount(route); // Submit form
                          },
                          validator: (value) {
                            if (value!.isEmpty || value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            text: 'Please remember your ',
                            style: Theme.of(context).textTheme.titleSmall,
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Email',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                              ),
                              TextSpan(
                                text: ' and ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(),
                              ),
                              TextSpan(
                                text: 'Password',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                              ),
                              TextSpan(
                                text: ' for further login. ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => createAccount(route),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(),
                                )
                              : Text('Create Account'.toUpperCase()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

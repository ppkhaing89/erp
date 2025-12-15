import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:erp/common/message.dart';
import 'package:erp/common/api.dart';
import 'dart:convert';
import 'package:erp/views/home/modulelist.dart';
import 'package:erp/model/global.dart' as globals;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final TextEditingController _txtUserID = TextEditingController();
  final TextEditingController _txtPassword = TextEditingController();

  Api api = Api();
  Message msg = Message();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _txtUserID.dispose();
    _txtPassword.dispose();
    super.dispose();
  }

  Future<void> loginClick(BuildContext context) async {
    if (_txtUserID.text.isEmpty) {
      msg.showErrorDialog(context, 'UserID or Email is required!');
      return;
    } else if (_txtPassword.text.isEmpty) {
      msg.showErrorDialog(context, 'Password is required!');
      return;
    }

    var obj = <String, String>{
      'Email': _txtUserID.text,
      'Password': _txtPassword.text
    };

    String body = await api.apiCall('UserApi/LoginCheck', obj);
    dynamic jsonObject = jsonDecode(jsonDecode(body.toString()));
    if (jsonObject.length > 0) {
      globals.userCD = jsonObject[0]["UserCD"];
      globals.countryCD = jsonObject[0]["CountryCD"];
      globals.userName = jsonObject[0]["FullName"];
      globals.profilephoto = jsonObject[0]["ProfilePhoto"];
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => const ModuleList(),
          ),
        );
      }
    } else {
      if (mounted) {
        // ignore: use_build_context_synchronously
        msg.showErrorDialog(context, 'Login Failed!');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/loginbg_2.jpeg',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center, // Align the login box to the bottom
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 80.0, // changed from 80 to 50
                      width: 120.0, // add width to better contrrol aspect ratio
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/d-link-logo1.png'),
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: const Center(
                        child: Text(
                          '',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A8A8),
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _txtUserID,
                      cursorColor:
                          const Color(0xFF00A8A8), // ← Change cursor color here
                      decoration: InputDecoration(
                        hintText: 'UserID or Email',
                        prefixIcon: const Icon(Icons.person_2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 120, 136, 150),
                              width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF00A8A8), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: _txtPassword,
                      cursorColor: const Color(0xFF00A8A8),
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: const Color(0xFF00A8A8),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color.fromARGB(255, 120, 136, 150),
                              width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: const BorderSide(
                              color: Color(0xFF00A8A8), width: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () {
                        loginClick(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A8A8),
                        padding: const EdgeInsets.all(10.0),
                      ),
                      icon: const Icon(
                        Icons.login,
                        size: 24.0,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  'Developed by D-Link Singapore',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

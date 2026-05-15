import 'package:flutter/material.dart';
import 'package:volync/features/auth/presentation/pages/login2.dart';
import 'package:volync/features/auth/presentation/pages/signUp.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;

    final circleDiameter = screenWidth * 1.4;

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Circle background — covers top portion only
          Positioned(
            top: -circleDiameter * 0.05,
            left: (screenWidth - circleDiameter) / 2,
            child: Container(
              width: circleDiameter,
              height: circleDiameter,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 232, 246, 243),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 75),
                Image.asset(
                  'lib/assets/images/volync_logo.png',
                  width: 250, // set width
                  height: 250, // set height
                  fit: BoxFit.fitHeight, // how image fits
                ),
                SizedBox(height: 130),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginEmail()),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 134, 187, 216),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.75,
                      MediaQuery.of(context).size.height * 0.085,
                    ),
                  ),
                  child: Text(
                    'Ayo Mulai !',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),

                SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  ),
                  style: TextButton.styleFrom(
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.75,
                      MediaQuery.of(context).size.height * 0.05,
                    ),
                  ),
                  child: Text(
                    'Buat Akun Baru',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
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

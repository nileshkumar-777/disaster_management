import 'package:flutter/material.dart';


class LoadingScreen extends StatelessWidget {

  const LoadingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(60, 78, 63, 63),
        body: Column(
          
          children: [
            SizedBox(height: 150), // Controls the vertical position
            Row(
              children: [
                SizedBox(width: 55,),
                Image.asset(
                  'assets/saving.png',
                  height: 300,
                ),
              ],
              
            ),
            SizedBox(height: 40,),
            Text('"You are stronger than this storm."',
            style: TextStyle(
              color: Colors.white,
              fontSize:22 ,
              fontWeight: FontWeight.bold
              
            ),
            
            ),
            SizedBox(height: 30,),
            Divider(
              thickness: 2,
              indent:50 ,
              endIndent: 50,
            ),
            SizedBox(height: 200,),
            Icon(
              Icons.restart_alt,
              size: 50,
              color: Colors.white,
            )
          
          ],
        ),
      ),
    );
  }
}
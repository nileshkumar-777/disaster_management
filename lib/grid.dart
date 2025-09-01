import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GridItem extends StatelessWidget {
  final String text;   
  final Color color;
  final IconData icon;   

  const GridItem({
    super.key,
    required this.text,   
    required this.color,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // shadow color
            spreadRadius: 2,                     // how wide it spreads
            blurRadius: 6,                       // softness
            offset: const Offset(3, 3),          // x,y offset
          ),
        ],
      ),
      child:  Row(
        children: [

          Icon(
            icon,  // 🔹 now works
            size: 30,
            color: Colors.white,
          ),
          SizedBox(width: 15,),
          Text(
              text,
              style: GoogleFonts.aBeeZee(fontSize: 35, color: Color.fromARGB(255, 214, 206, 206)),
            ),
        ],
      ),
      );
    
  }
}


class GridItem2 extends StatelessWidget {
  final String text;   
  final Color color;
  final IconData icon;   
  final Color iconcolor;

  const GridItem2({
    super.key,
    required this.text,   
    required this.color,
    required this.icon,
    required this.iconcolor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // shadow color
            spreadRadius: 2,                     // how wide it spreads
            blurRadius: 6,                       // softness
            offset: const Offset(3, 3),          // x,y offset
          ),
        ],
      ),
      child:  Column(
        children: [

          Icon(
            icon,  // 🔹 now works
            size: 30,
            color: iconcolor,
          ),
          SizedBox(height: 4,),
          Center(
            child: Center(
              child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.aBeeZee(
                    fontSize: 17,
                    color: Color.fromARGB(255, 49, 48, 48),
                    fontWeight: FontWeight.bold
                    ),
                ),
            ),
          ),
        ],
      ),
      );
    
  }
}

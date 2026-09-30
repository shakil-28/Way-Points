import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(
            color: Color(0xFFF8FAFC),
            child: Opacity(
              opacity: 0.80,
              child: Image.network('https://lh3.googleusercontent.com/aida-public/AB6AXuB8abTw3wf5dXTcKsp6oymb-Vy7nKJyZfFVSvtLVx_E9Zy4MSEIWYD3Tee31k_UYlIkFzfQKZLvrP2m3SYYaYiT0hU6v3k829T9Mj33kNc4qgk7Q3QG5CMwo6XPqco33kF4LcM0CRP_9d9s0UGF01Ey5pY_OCKnCZFqSjztXYEQ9IS9Tiy7LjHy1zlkj11i6f-P5hWTwBcVARrCWV-LiAyFZy1Rbis78VMJZVYzvcvIP-EGP4kbTTEJFw',
                fit: BoxFit.cover,
              ),
            ),
           )
          ),

          SafeArea(
              child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(onPressed: () => {

                        }, icon: Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,

                        ),
                      ),

                      SizedBox(width: 8),

                      SvgPicture.asset('assets/logo.svg',
                        height: 32,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Active Navigation',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),

                ),
              ],
            )
          )
        ],
      ),
    );
  }
}

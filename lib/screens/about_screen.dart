import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // خلفية داكنة فخمة تناسب الوضع الليلي
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('عن التطبيق والمبرمج 👨‍💻', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // أيقونة اللوجو مع تأثير هالة مضيئة فاخرة
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.indigoAccent.withOpacity(0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigoAccent.withOpacity(0.2),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.code_rounded, size: 55, color: Colors.indigoAccent),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'تطبيق إنجاز | Engaz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 6),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'الإصدار 1.0.0 (Pro Edition)',
                style: TextStyle(fontSize: 13, color: Colors.indigoAccent, fontWeight: FontWeight.w600),
              ),
            ),
            
            const SizedBox(height: 35),
            
            // كرت معلومات المبرمج بتصميم زجاجي أو داكن فاخر
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, color: Colors.indigoAccent, size: 20),
                      const SizedBox(width: 8),
                      const Text('المبرمج والمطور:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(right: 28),
                    child: Text(
                      'مهندس عمر عبد العزيز',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Colors.tealAccent, size: 20),
                      const SizedBox(width: 8),
                      const Text('حقوق النشر:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(right: 28),
                    child: Text(
                      '© 2026 جميع الحقوق محفوظة للمطور.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            const Text(
              'صُنِع بشغف لتحقيق الإنتاجية والنجاح 🚀',
              style: TextStyle(fontSize: 13, color: Colors.grey, letterSpacing: 0.5),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
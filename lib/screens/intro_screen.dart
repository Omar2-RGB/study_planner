import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'adsense_banner.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // الشعار
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.indigoAccent.withOpacity(0.35),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigoAccent.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // اسم التطبيق
                  const Text(
                    'إنجاز | Engaz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'نظّم وقتك، رتّب مهامك، وحقق إنجازاتك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.indigoAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // تعريف التطبيق
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ما هو تطبيق إنجاز؟',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'إنجاز هو تطبيق يساعدك على تنظيم يومك ودراستك بطريقة بسيطة وعملية. '
                          'يمكنك من خلاله إدارة المهام، تنظيم جدولك، كتابة الملاحظات، '
                          'ومتابعة إحصائيات تقدمك، بالإضافة إلى مؤقت يساعدك على التركيز أثناء الدراسة أو العمل.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // إعلان Google AdSense
                  const AdsenseBanner(),

                  const SizedBox(height: 30),

                  // عنوان الميزات
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'كل ما تحتاجه في مكان واحد',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // مؤقت التركيز
                  _FeatureCard(
                    icon: Icons.timer_rounded,
                    title: 'مؤقت التركيز',
                    description:
                        'استخدم المؤقت لتنظيم جلسات الدراسة والعمل وتقليل التشتت وزيادة تركيزك.',
                  ),

                  // إدارة المهام
                  _FeatureCard(
                    icon: Icons.task_alt_rounded,
                    title: 'إدارة المهام',
                    description:
                        'أضف مهامك اليومية وتابع ما أنجزته حتى تبقى على اطلاع دائم بتقدمك.',
                  ),

                  // الجدول
                  _FeatureCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'الجدول',
                    description:
                        'رتّب مواعيدك ودراستك وأنشطتك اليومية ضمن جدول واضح ومنظم.',
                  ),

                  // الملاحظات
                  _FeatureCard(
                    icon: Icons.note_alt_rounded,
                    title: 'الملاحظات',
                    description:
                        'احتفظ بأفكارك وملاحظاتك المهمة داخل التطبيق لتصل إليها بسهولة عندما تحتاجها.',
                  ),

                  // الإحصائيات
                  _FeatureCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'الإحصائيات',
                    description:
                        'راجع تقدمك وإنجازاتك من خلال الإحصائيات لمعرفة مدى التزامك بأهدافك.',
                  ),

                  const SizedBox(height: 20),

                  // لمن صمم التطبيق
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لمن صُمم إنجاز؟',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'إنجاز مناسب للطلاب، المبرمجين، الموظفين، وأي شخص يريد تنظيم وقته '
                          'ومهامه اليومية بطريقة أكثر وضوحاً. سواء كنت تستعد لامتحان، تعمل على مشروع، '
                          'أو تريد فقط ترتيب يومك، يمكنك استخدام أدوات إنجاز لمساعدتك على البقاء منظماً.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // زر الدخول للتطبيق
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'ابدأ باستخدام إنجاز',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'إنجاز — رفيقك لتنظيم الوقت والدراسة',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.indigoAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.indigoAccent,
              size: 27,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.6,
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

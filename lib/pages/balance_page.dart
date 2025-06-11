import 'package:flutter/material.dart';

class BalancePage extends StatelessWidget {
  // المتغير balance يتم تمريره من الصفحة الأخرى
  final double balance;

  // المُنشئ لقبول قيمة balance
  const BalancePage({Key? key, required this.balance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(255, 243, 242, 242), // تحديد لون الخلفية
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context); // العودة للصفحة السابقة
                },
                color: Colors.white,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text(
                'My Account',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 238, 241, 240),
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
                  ],
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 77, 48),
                    Color.fromARGB(255, 5, 14, 8),
                  ],
                  stops: [0.3, 6.0],
                  end: Alignment.topLeft,
                  begin: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text(
          "Your Balance: \$${balance.toStringAsFixed(2)}", // عرض الرصيد مع تنسيق الرقم
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat Demo',
      theme: ThemeData(),
      home: CompanyChatPage(companyName: 'GreenFarm Supplies'),
    );
  }
}

class CompanyChatPage extends StatefulWidget {
  final String companyName;

  const CompanyChatPage({super.key, required this.companyName});

  @override
  _CompanyChatPageState createState() => _CompanyChatPageState();
}

class _CompanyChatPageState extends State<CompanyChatPage> {
  final List<Map<String, String>> _messages = [];

  final List<String> _questions = [
    'What is your issue?',
    'Can I help you with any product?',
    'What kind of services are you looking for?'
  ];

  final Map<String, String> _companyResponses = {
    'What is your issue?': 'Please describe the issue in more detail.',
    'Can I help you with any product?': 'We offer various products like fertilizers and seeds.',
    'What kind of services are you looking for?': 'We can assist you with irrigation and crop advice.',
  };

  TextEditingController _controller = TextEditingController();
  bool _showQuestions = true;

  void _sendMessage(String question) {
    setState(() {
      _messages.add({'sender': 'Farmer', 'message': question});
      _messages.add({
        'sender': 'Company',
        'message': _companyResponses[question] ?? 'I didn\'t understand that.',
      });
      _showQuestions = false;
    });
  }

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
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: const Text(
                'MateChat',
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
body: Container(
  color: Color.fromARGB(255, 243, 242, 242), // لون خلفية جديد بدل الأبيض
  child: Column(
    children: [
      Expanded(
        child: ListView.builder(
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            return MessageBubble(
              sender: message['sender']!,
              message: message['message']!,
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 40, 8, 10),
        child: Column(
          children: [
            if (_showQuestions)
              Column(
                children: _questions.map((question) {
                  return GestureDetector(
                    onTap: () {
                      _sendMessage(question);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Text(
                        question,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Color.fromARGB(255, 29, 65, 48), // أخضر للشات
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        _sendMessage(text);
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String message;

  const MessageBubble({super.key, required this.sender, required this.message});

  @override
 Widget build(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(9.0),
    child: Align(
      alignment: sender == 'Farmer' ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment:
            sender == 'Farmer' ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: sender == 'Farmer'
                  ? const Color.fromARGB(255, 144, 144, 144)
                  : const Color.fromARGB(255, 34, 59, 28),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // تكبير الحواف
            decoration: BoxDecoration(
              color: sender == 'Farmer'
                  ? Colors.grey[300]
                  : const Color.fromARGB(255, 34, 59, 28),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15, // تكبير حجم الخط
                color: sender == 'Farmer' ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}}

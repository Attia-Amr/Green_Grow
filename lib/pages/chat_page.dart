


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Green Grow',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _suggestionsVisible = true;

  // ✨ رابط السيرفر بتاعك (غيري الـ IP حسب جهازك)
  // final String serverUrl = 'http://192.168.1.10:5000/chat';
    final String serverUrl = 'https://0a49-154-238-163-140.ngrok-free.app/chat';


  // ✨ إرسال رسالة إلى السيرفر
  Future<void> _sendMessage({String? customText}) async {
    final text = customText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'You', 'text': text});
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': text,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final botReply = decoded['reply']; // لاحظ هنا 'reply'

        setState(() {
          _messages.add({'sender': 'Bot', 'text': botReply});
        });
      } else {
        setState(() {
          _messages.add({'sender': 'Bot', 'text': '❗ Server error: ${response.statusCode}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'Bot', 'text': '❗ Error sending message: $e'});
      });
    }
  }

  // ✨ بناء الأزرار المقترحة
  Widget _buildSuggestedQuestion(String question) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 192, 194, 191),
        foregroundColor: const Color.fromARGB(255, 19, 65, 22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      onPressed: () {
        setState(() {
          _suggestionsVisible = false;
        });
        _sendMessage(customText: question);
      },
      child: Text(
        question,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'images/background1.jpg',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.1),
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            children: [
              // ✅ العنوان
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 15, 77, 48),
                      Color.fromARGB(255, 5, 14, 8),
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(66, 47, 49, 48),
                      blurRadius: 15,
                      spreadRadius: 15,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundImage: AssetImage('Chaaaattttt.jpg'),
                      backgroundColor: Color.fromARGB(255, 102, 49, 49),
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      children: const [
                        Positioned(
                          left: 3,
                          top: 3,
                          child: Text(
                            'AgriBot',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          'AgriBot',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ الرسائل
Expanded(
  child: ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    itemCount: _messages.length,
    itemBuilder: (context, index) {
      final message = _messages[index];
      final isMe = message['sender'] == 'You';
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe
                ? const Color.fromARGB(255, 29, 65, 48) // الخلفية للرسائل المرسلة
                : const Color.fromARGB(255, 192, 194, 191), // الخلفية للرسائل المرسلة من البوت
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message['text']!,
            style: TextStyle(
              fontSize: 17, // تكبير حجم الخط هنا
              color: isMe ? Colors.white : Colors.black, // تغيير اللون للنص
            ),
          ),
        ),
      );
    },
  ),
),

              // ✅ الأسئلة المقترحة
              if (_suggestionsVisible)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      _buildSuggestedQuestion("Best time to plant vegetables?"),
                      const SizedBox(height: 10),
                      _buildSuggestedQuestion("What is the best type of fertilizer?"),
                      const SizedBox(height: 10),
                      _buildSuggestedQuestion("How do I know the soil type?"),
                    ],
                  ),
                ),

              // ✅ خانة كتابة الرسالة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 29, 65, 48),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _suggestionsVisible = false;
                          });
                          _sendMessage();
                        },
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
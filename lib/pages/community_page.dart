
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Agricultural Cnity',

    // home: const CommunityPage(),
  );
}

}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
        appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ClipRRect(
     
          child: AppBar(
          
            title: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: const Text(
                'Community',
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
  color: Colors.grey[300], // لون الخلفية الرمادية
  child: Column(
    children: [
      // User Info Section
      Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 15, 77, 48),
              Color.fromARGB(255, 5, 14, 8),
            ],
            stops: [0.3, 1.0],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : const AssetImage('images/girl.jpg') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Text(
              'Hello, ${user?.email?.split('@')[0] ?? "Farmer"}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 234, 240, 238),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 5),

      // Post Stream Section
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final posts = snapshot.data!.docs;

            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(post: posts[index]);
              },
            );
          },
        ),
      ),
    ],
  ),
),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPostPage()),
          );
        },
          backgroundColor: const  Color.fromARGB(255, 15, 77, 48), 
        child: const Icon(Icons.add,color:Color.fromARGB(255, 218, 228, 218),),
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final QueryDocumentSnapshot post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late int likes;
  bool isLiked = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    likes = widget.post['likes'] ?? 0;
    _checkIfLiked();
  }

  void _checkIfLiked() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.post.id)
          .collection('likes')
          .doc(user!.uid)
          .get();
      setState(() {
        isLiked = doc.exists;
      });
    }
  }

  void _toggleLike() async {
    if (user == null) return;

    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .collection('likes')
        .doc(user!.uid);

    final postRef =
        FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    if (isLiked) {
      await likeRef.delete();
      await postRef.update({'likes': FieldValue.increment(-1)});
      setState(() {
        likes--;
        isLiked = false;
      });
    } else {
      await likeRef.set({'likedAt': Timestamp.now()});
      await postRef.update({'likes': FieldValue.increment(1)});
      setState(() {
        likes++;
        isLiked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = widget.post['userName'] ?? 'Unknown Farmer';
    final content = widget.post['content'] ?? '';
    final imageUrl = widget.post['imageUrl'] ?? '';

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 16,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(userEmail,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
            if (imageUrl != '') ...[
              const SizedBox(height: 10),
              Image.network(imageUrl),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$likes Likes'),
                const Spacer(),
                CommentCountButton(postId: widget.post.id),
              ],
            )
          ],
        ),
      ),
    );
  }
}





class CommentCountButton extends StatelessWidget {
  final String postId;
  const CommentCountButton({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .snapshots(),
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          count = snapshot.data!.docs.length;
        }

        return TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CommentsPage(postId: postId),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.comment, size: 20, color: const Color.fromARGB(255, 57, 100, 66)),
              const SizedBox(width: 6),
              const Text('Comments', style: TextStyle(color: Color.fromARGB(255, 57, 100, 66))),
              const SizedBox(width: 6),
              Text('($count)', style: const TextStyle(color: Color.fromARGB(255, 57, 100, 66))),
            ],
          ),
        );
      },
    );
  }
}

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _controller = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('post_images/${DateTime.now()}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }

  Future<void> _addPost() async {
    final user = FirebaseAuth.instance.currentUser;

    String imageUrl = '';
    if (_imageFile != null) {
      imageUrl = await _uploadImage(_imageFile!);
    }

    await FirebaseFirestore.instance.collection('posts').add({
      'userName': user?.email?.split('@')[0] ?? 'Unknown Farmer',
      'userId': user?.uid,
      'content': _controller.text,
      'timestamp': Timestamp.now(),
      'likes': 0,
      'imageUrl': imageUrl,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.grey[300], // خلفية ناعمة رمادي فاتح
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
                'Add Post',
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




body: SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Create a Post",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 15, 77, 48),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.grey.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Share your thoughts...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (_imageFile != null)
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.file(
            _imageFile!,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Add Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color.fromARGB(255, 15, 77, 48),
                side: const BorderSide(color: Color.fromARGB(255, 15, 77, 48)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _addPost,
              icon: const Icon(Icons.send),
              label: const Text("Post"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 77, 48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
)







    );
  }
}


class CommentsPage extends StatefulWidget {
  final String postId;
  const CommentsPage({super.key, required this.postId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _addComment() async {
    if (_controller.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userName': FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 'Unknown Farmer',
        'comment': _controller.text.trim(),
        'timestamp': Timestamp.now(),
      });

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
    }
  }

  Future<void> _editComment(String commentId, String oldComment) async {
    _controller.text = oldComment;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Edit Comment',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 32, 94, 34),
            ),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Edit your comment...',
                hintStyle: const TextStyle(color: Color.fromARGB(255, 32, 94, 34)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 32, 94, 34), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 32, 94, 34), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              style: const TextStyle(color: Color.fromARGB(255, 32, 94, 34)),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .doc(commentId)
                      .update({
                    'comment': _controller.text.trim(),
                    'timestamp': Timestamp.now(),
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color.fromARGB(255, 32, 94, 34),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final commentsRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(95),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              color: Colors.white,
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Comments',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 238, 241, 240),
                shadows: [
                  Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                ],
              ),
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 15, 77, 48),
                  Color.fromARGB(255, 5, 14, 8),
                ],
                stops: [0.3, 6.0],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: commentsRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading comments'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet 🥲', style: TextStyle(fontSize: 18)));
                }
                final comments = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final name = comment['userName'] ?? 'Unknown Farmer';
                    final text = comment['comment'] ?? '';
                    final commentId = comment.id;
                    final currentUser = FirebaseAuth.instance.currentUser;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 250, 252, 248),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundImage: AssetImage('images/girl.jpg'),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          text,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 16,
                          ),
                        ),
                        trailing: currentUser?.email?.split('@')[0] == name
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editComment(commentId, text);
                                  } else if (value == 'delete') {
                                    _deleteComment(commentId);
                                  }
                                },
                                itemBuilder: (context) {
                                  return [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ];
                                },
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color.fromARGB(255, 18, 43, 18)),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color.fromARGB(255, 22, 54, 23), width: 2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color.fromARGB(255, 25, 63, 26)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

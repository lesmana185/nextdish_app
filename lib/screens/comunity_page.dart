import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'share_recipe_page.dart';
// import 'package:timeago/timeago.dart' as timeago; // Bisa di-uncomment jika ingin format waktu dinamis

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late Future<List<Map<String, dynamic>>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _fetchPosts();
  }

  Future<List<Map<String, dynamic>>> _fetchPosts() async {
    final response = await Supabase.instance.client
        .from('community_posts')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fungsi ini akan dikirim ke PostCardItem agar bisa refresh dari dalam
  void _refreshFeed() {
    setState(() {
      _postsFuture = _fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),

      // TOMBOL TAMBAH (+)
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShareRecipePage()),
            );
            // Jika sukses posting (result == true), refresh feed
            if (result == true) _refreshFeed();
          },
          backgroundColor: const Color(0xFF63B685),
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Komunitas",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF388E3C),
                              fontFamily: 'Serif')),
                      Text("Berbagi resep dengan\npengguna NextDish Lainnya",
                          style:
                              TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset('assets/images/home/logosmall.png',
                          height: 40),
                      const Text("NextDish",
                          style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // LIST FEED
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF38A169)));
                  }
                  final posts = snapshot.data ?? [];
                  if (posts.isEmpty) {
                    return const Center(
                        child: Text("Belum ada postingan.",
                            style: TextStyle(color: Colors.grey)));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _refreshFeed();
                      await _postsFuture;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: posts.length,
                      itemBuilder: (context, index) => PostCardItem(
                        post: posts[index],
                        // PENTING: Kita kirim fungsi refresh ke anak
                        onRefresh: _refreshFeed,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET CARD TERPISAH (DENGAN FITUR DELETE) ---
class PostCardItem extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onRefresh; // Callback untuk refresh

  const PostCardItem({super.key, required this.post, required this.onRefresh});

  @override
  State<PostCardItem> createState() => _PostCardItemState();
}

class _PostCardItemState extends State<PostCardItem> {
  bool _isLiked = false;
  int _likeCount = 0;
  final String _currentUserId =
      Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post['likes_count'] ?? 0;
    _checkIfLiked();
  }

  void _checkIfLiked() async {
    final response = await Supabase.instance.client
        .from('post_likes')
        .select()
        .eq('user_id', _currentUserId)
        .eq('post_id', widget.post['id'])
        .maybeSingle();

    if (mounted) {
      setState(() => _isLiked = response != null);
    }
  }

  void _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      if (_isLiked) {
        await Supabase.instance.client.from('post_likes').insert({
          'user_id': _currentUserId,
          'post_id': widget.post['id'],
        });
      } else {
        await Supabase.instance.client
            .from('post_likes')
            .delete()
            .eq('user_id', _currentUserId)
            .eq('post_id', widget.post['id']);
      }
      await Supabase.instance.client
          .from('community_posts')
          .update({'likes_count': _likeCount}).eq('id', widget.post['id']);
    } catch (e) {
      debugPrint("Gagal like: $e");
    }
  }

  // --- LOGIKA HAPUS POSTINGAN ---
  Future<void> _deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Postingan?"),
        content: const Text("Postingan ini akan dihapus permanen."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('community_posts')
          .delete()
          .eq('id', widget.post['id']);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Postingan dihapus.")));
        // Panggil refresh milik halaman induk
        widget.onRefresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
      }
    }
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => CommentSection(postId: widget.post['id']),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final ImageProvider avatarImage = (post['user_avatar'] != null)
        ? NetworkImage(post['user_avatar'])
        : const AssetImage('assets/images/home/profile.png') as ImageProvider;

    // Cek Pemilik Postingan
    final bool isMyPost = (post['user_id'] == _currentUserId);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header User
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundImage: avatarImage),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['user_name'] ?? "User",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text("Baru saja",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              // TOMBOL HAPUS (HANYA MUNCUL JIKA PEMILIK)
              if (isMyPost)
                IconButton(
                  onPressed: _deletePost,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Hapus Postingan",
                ),
            ],
          ),
          const SizedBox(height: 12),

          Text(post['caption'] ?? "",
              style: const TextStyle(
                  color: Colors.black87, fontSize: 14, height: 1.4)),
          if (post['recipe_title'] != null && post['recipe_title'].isNotEmpty)
            Text("Resep: ${post['recipe_title']}",
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              post['image_url'],
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : Colors.grey,
                        size: 26,
                      ),
                      const SizedBox(width: 6),
                      Text("$_likeCount",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _showCommentSheet,
                  child: const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          color: Colors.grey, size: 24),
                      SizedBox(width: 6),
                      Text("Komentar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
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

// --- WIDGET KOMENTAR (TETAP SAMA) ---
class CommentSection extends StatefulWidget {
  final int postId;
  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();

  void _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('post_comments').insert({
        'user_id': user.id,
        'post_id': widget.postId,
        'comment_text': text,
        'user_name': user.userMetadata?['full_name'] ?? 'User',
        'user_avatar': user.userMetadata?['avatar_url'],
      });

      _commentController.clear();
      setState(() {});
    } catch (e) {
      debugPrint("Gagal komen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const Text("Komentar",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('post_comments')
                  .select()
                  .eq('post_id', widget.postId)
                  .order('created_at', ascending: true),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                final comments = snapshot.data!;

                if (comments.isEmpty) {
                  return const Center(
                      child: Text("Belum ada komentar. Yuk mulai ngobrol!"));
                }

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: c['user_avatar'] != null
                            ? NetworkImage(c['user_avatar'])
                            : const AssetImage('assets/images/home/profile.png')
                                as ImageProvider,
                        radius: 16,
                      ),
                      title: Text(c['user_name'] ?? "User",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text(c['comment_text'] ?? "",
                          style: const TextStyle(color: Colors.black87)),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Tulis komentar...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _postComment,
                  icon: const Icon(Icons.send, color: Color(0xFF63B685)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

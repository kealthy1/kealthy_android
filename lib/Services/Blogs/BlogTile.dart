import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/Login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Login/Guest_Alert.dart';
import 'Blog.dart';

class LikesState {
  final int likesCount;
  final bool isLiked;

  LikesState({required this.likesCount, required this.isLiked});
}

final blogLikesProvider =
    StateNotifierProvider.family<BlogLikesNotifier, LikesState, String>(
        (ref, blogId) {
  return BlogLikesNotifier(blogId);
});

class BlogLikesNotifier extends StateNotifier<LikesState> {
  final String blogId;
  BlogLikesNotifier(this.blogId)
      : super(LikesState(likesCount: 0, isLiked: false)) {
    _fetchLikes();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _getPhoneNumberFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber');
  }

  Future<void> _fetchLikes() async {
    try {
      final doc = await _firestore.collection('blogs').doc(blogId).get();
      final data = doc.data();
      final likes = data?['likes'] ?? 0;

      // Get phone number from shared preferences
      final userPhoneNumber = await _getPhoneNumberFromSharedPrefs();

      // Check if the user has already liked this blog
      final likedBy = List<String>.from(data?['likedBy'] ?? []);
      final isLiked =
          userPhoneNumber != null && likedBy.contains(userPhoneNumber);

      state = LikesState(
        likesCount: likes > 0 ? likes : 0,
        isLiked: isLiked,
      );
    } catch (e) {
      print("Error fetching likes: $e");
      state = LikesState(likesCount: 0, isLiked: false);
    }
  }

  void toggleLikeAsync(String blogId) async {
    final currentState = state;
    final isLiked = !currentState.isLiked;
    final likesCount =
        isLiked ? currentState.likesCount + 1 : currentState.likesCount - 1;

    // Update the state optimistically
    state = LikesState(likesCount: likesCount, isLiked: isLiked);

    try {
      final docRef = _firestore.collection('blogs').doc(blogId);

      // Get phone number from shared preferences
      final userPhoneNumber = await _getPhoneNumberFromSharedPrefs();
      if (userPhoneNumber == null) {
        throw Exception("User phone number not found");
      }

      if (isLiked) {
        // Add the phone number to the likedBy array
        await docRef.update({
          'likes': likesCount,
          'likedBy': FieldValue.arrayUnion([userPhoneNumber]),
        });
      } else {
        // Remove the phone number from the likedBy array
        await docRef.update({
          'likes': likesCount,
          'likedBy': FieldValue.arrayRemove([userPhoneNumber]),
        });
      }
    } catch (e) {
      print("Error toggling like: $e");
      // Revert the state in case of an error
      state = LikesState(
        likesCount: isLiked ? likesCount - 1 : likesCount + 1,
        isLiked: !isLiked,
      );
    }
  }

  String formatLikesCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(0)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}k';
    } else {
      return '$count';
    }
  }
}

class BlogListTile extends ConsumerWidget {
  final Blog blog;
  final VoidCallback onTap;

  const BlogListTile({super.key, required this.blog, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesProvider = ref.watch(blogLikesProvider(blog.id));

    final dateFormatted = DateFormat('d MMM').format(blog.createdAt);
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl:
                        blog.imageUrls.isNotEmpty ? blog.imageUrls[0] : '',
                    width: screenWidth * 0.35,
                    height: screenWidth * 0.25,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(8, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      dateFormatted,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(CupertinoIcons.hand_thumbsup_fill),
                        color: likesProvider.isLiked
                            ? const Color(0xFF273847)
                            : Colors.grey,
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final phoneNumber =
                              prefs.getString('phoneNumber') ?? '';
                          if (phoneNumber.isEmpty) {
                            GuestDialog.show(
                              context: context,
                              title: "Login Required",
                              content: "Please log in to like this post.",
                              navigateTo:
                                  LoginFields(), 
                            );
                          } else {
                            ref
                                .read(blogLikesProvider(blog.id).notifier)
                                .toggleLikeAsync(blog.id);
                          }
                        },
                      ),
                      if (likesProvider.likesCount > 0)
                        Text(
                          '${ref.read(blogLikesProvider(blog.id).notifier).formatLikesCount(likesProvider.likesCount)} Likes',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                    ],
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

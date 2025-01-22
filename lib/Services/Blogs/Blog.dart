import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Services/Blogs/BlogList.dart';

final blogProvider = FutureProvider<List<Blog>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final snapshot = await firestore.collection('blogs').get();

  return snapshot.docs.map((doc) {
    return Blog.fromFirestore(doc);
  }).toList();
});

class Blog {
  final String id;
  final String title;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrls,
    required this.createdAt,
  });

  factory Blog.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Blog(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class BlogDetailsPage extends ConsumerWidget {
  final Blog blog;

  const BlogDetailsPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(filteredBlogsProvider);
        // ignore: unused_result
        ref.refresh(blogProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            titleSpacing: 18,
            surfaceTintColor: Colors.white,
            automaticallyImplyLeading: false,
            title: Text(
              'Blogs For You',
              style: GoogleFonts.poppins(
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white),
        body: BlogCard(blog: blog),
      ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final Blog blog;

  const BlogCard({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (blog.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: CachedNetworkImage(
                    cacheManager: DefaultCacheManager(),
                    imageUrl: blog.imageUrls[0],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      height: 200,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  blog.title,
                  style: GoogleFonts.poppins(
                      fontSize: 25,
                      color: Colors.black,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              if (blog.imageUrls.length > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      cacheManager: DefaultCacheManager(),
                      imageUrl: blog.imageUrls[1],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        height: 200,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  textAlign: TextAlign.justify,
                  blog.content,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (blog.imageUrls.length > 2)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      cacheManager: DefaultCacheManager(),
                      imageUrl: blog.imageUrls[2],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        height: 200,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "By Kealthy",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

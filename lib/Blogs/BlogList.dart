import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'Blog.dart';
import 'BlogTile.dart';

class BlogListPage extends ConsumerWidget {
  const BlogListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blogState = ref.watch(blogProvider);
    final filteredBlogs = ref.watch(filteredBlogsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        titleSpacing: 12,
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kealthy Blogs',
              style: GoogleFonts.poppins(
                color: Color(0xFF273847),
              ),
            ),
            PopupMenuButton<String>(
              color: Colors.white,
              icon: Icon(
                Icons.filter_list,
                color: Color(0xFF273847),
              ),
              onSelected: (value) {
                ref.read(filterProvider.notifier).state = value;
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'all',
                  child: Text(
                    'All Blogs',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
                PopupMenuItem(
                  value: 'month',
                  child: Text(
                    'This Month',
                    style: GoogleFonts.poppins(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: blogState.when(
        data: (blogs) {
          return ListView.builder(
            itemCount: filteredBlogs.length,
            itemBuilder: (context, index) {
              final blog = filteredBlogs[index];
              return BlogListTile(
                blog: blog,
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => BlogDetailsPage(blog: blog),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => Center(
            child: LoadingAnimationWidget.inkDrop(
                color: Color(0xFF273847), size: 60)),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}



final filterProvider = StateProvider<String>((ref) => 'month');

final filteredBlogsProvider = Provider<List<Blog>>((ref) {
  final blogState = ref.watch(blogProvider);
  final filter = ref.watch(filterProvider);

  return blogState.when(
    data: (blogs) {
      blogs.sort((a, b) => b.createdAt.compareTo(a.createdAt)); 

      final currentDate = DateTime.now();
      if (filter == 'month') {
        final startOfMonth = DateTime(currentDate.year, currentDate.month, 1);
        final endOfMonth = DateTime(currentDate.year, currentDate.month + 1, 0);

        return blogs
            .where((blog) =>
                blog.createdAt.isAfter(startOfMonth.subtract(Duration(seconds: 1))) &&
                blog.createdAt.isBefore(endOfMonth.add(Duration(days: 1))))
            .toList();
      } else {
        return blogs;
      }
    },
    loading: () => [],
    error: (error, stackTrace) => [],
  );
});


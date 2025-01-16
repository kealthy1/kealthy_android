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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        titleSpacing: 12,
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        title: Text(
          'Kealthy Blogs',
          style: GoogleFonts.poppins(
            color: Color(0xFF273847),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: blogState.when(
        data: (blogs) {
          blogs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            itemCount: blogs.length,
            itemBuilder: (context, index) {
              final blog = blogs[index];
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

class BlogDetailsPage extends StatelessWidget {
  final Blog blog;

  const BlogDetailsPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

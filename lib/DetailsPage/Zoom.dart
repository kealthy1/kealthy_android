import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../Services/Cache.dart';

class ImageIndexNotifier extends StateNotifier<int> {
  ImageIndexNotifier(int initialIndex) : super(initialIndex);

  void setIndex(int newIndex) {
    state = newIndex;
  }
}

final imageIndexProvider =
    StateNotifierProvider.family<ImageIndexNotifier, int, int>(
  (ref, initialIndex) => ImageIndexNotifier(initialIndex),
);

class ImageZoomPage extends ConsumerStatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageZoomPage({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  _ImageZoomPageState createState() => _ImageZoomPageState();
}

class _ImageZoomPageState extends ConsumerState<ImageZoomPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(imageIndexProvider(widget.initialIndex));

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PhotoViewGallery.builder(
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.white),
                itemCount: widget.imageUrls.length,
                pageController: _pageController,
                onPageChanged: (index) {
                  ref
                      .read(imageIndexProvider(widget.initialIndex).notifier)
                      .setIndex(index);
                },
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                      widget.imageUrls[index],
                      cacheManager: CustomCacheManager(),
                    ),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2.5,
                    heroAttributes: PhotoViewHeroAttributes(tag: index),
                    filterQuality: FilterQuality.high,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              height: MediaQuery.of(context).size.height * 0.1,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(index);
                      ref
                          .read(
                              imageIndexProvider(widget.initialIndex).notifier)
                          .setIndex(index);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: currentIndex == index
                              ? Colors.orange
                              : Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: widget.imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          cacheManager: CustomCacheManager(),
                        ),
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

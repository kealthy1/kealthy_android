import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../MenuPage/menu_item.dart';
import '../Services/Cache.dart';
import 'Zoom.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class ImageHeader extends ConsumerStatefulWidget {
  final MenuItem menuItem;

  const ImageHeader({required this.menuItem, super.key});

  @override
  _ImageHeaderState createState() => _ImageHeaderState();
}

class _ImageHeaderState extends ConsumerState<ImageHeader> {
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context ) {
    return SafeArea(
      child: AspectRatio(
        aspectRatio: 9 / 9,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageZoomPage(
                      imageUrls: widget.menuItem.imageUrls,
                      initialIndex: ref.read(pageIndexProvider),
                    ),
                  ),
                );
              },
              child: PhotoViewGallery.builder(
                loadingBuilder: (context, event) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 150,
                    color: Colors.grey[300],
                  ),
                ),
                backgroundDecoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(
                      widget.menuItem.imageUrls[index],
                      cacheManager: CustomCacheManager(),
                    ),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.covered,
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    heroAttributes: PhotoViewHeroAttributes(tag: index),
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error, size: 50, color: Colors.red),
                    ),
                    filterQuality: FilterQuality.high,
                  );
                },
                itemCount: widget.menuItem.imageUrls.length,
                pageController: pageController,
                onPageChanged: (index) {
                  ref.read(pageIndexProvider.notifier).state = index;
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FractionallySizedBox(
                  widthFactor: 0.6,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: widget.menuItem.imageUrls.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: const Color(0xFF273847),
                        dotColor: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

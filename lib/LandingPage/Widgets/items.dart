import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../DetailsPage/HomePage.dart';
import '../../MenuPage/Search_provider.dart';
import '../../MenuPage/menu_item.dart';
import '../../Services/Cache.dart';
import '../../Services/FirestoreCart.dart';
import '../../Services/Navigation.dart';
import '../Allitems.dart';
import '../Cart_Container.dart';
import 'searchprovider.dart';

class ItemCard extends ConsumerStatefulWidget {
  final MenuItem menuItem;
  final String Search;

  const ItemCard({super.key, required this.menuItem, required this.Search});

  @override
  _ItemCardState createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<ItemCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.Search);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(productProvider);
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);
    final relatedItems = allItems
        .where((item) =>
            item.category == widget.menuItem.category &&
            item.name != widget.menuItem.name)
        .map((item) => item.toMenuItem())
        .toSet()
        .toList();

    final allItemsToShow = [widget.menuItem, ...relatedItems];

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(productProvider);
        // ignore: unused_result
        ref.refresh(searchQueryProvider);

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            surfaceTintColor: Colors.white,
            centerTitle: true,
            title: Text(
              widget.menuItem.category,
              style: const TextStyle(),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: allItems.isEmpty
                    ? _buildShimmerGrid()
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: allItemsToShow.length,
                        itemBuilder: (context, index) {
                          final item = allItemsToShow[index];
                          return _buildGridItemCard(context, item);
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomSheet: cartItems.isNotEmpty && isVisible
            ? AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const CartContainer(),
              )
            : null,
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        readOnly: true,
        onTap: () {
          // ignore: unused_result
          ref.refresh(searchQueryProvider);
          Navigator.of(context).pushReplacement(
            SeamlessRevealRoute(
              page: const AllItemsPage(),
            ),
          );
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(CupertinoIcons.search),
          hintText: "Search ",
          hintStyle: const TextStyle(color: Colors.black),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildGridItemCard(BuildContext context, MenuItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(menuItem: item),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: CachedNetworkImage(
                    cacheManager: CustomCacheManager(),
                    imageUrl:
                        item.imageUrls.isNotEmpty ? item.imageUrls[0] : '',
                    fit: BoxFit.fill,
                    placeholder: (context, url) => _buildShimmerItem(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maxLines: 1,
                      item.subcategory,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ' ₹ ${item.price.toStringAsFixed(0)} /-',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

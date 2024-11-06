import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kealthy/Diet/ProductList.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class KetogenicDietPage extends StatelessWidget {
  const KetogenicDietPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[100],
        toolbarHeight: 1,
      ),
      backgroundColor: Colors.green[100],
      body: FutureBuilder(
        future: _fetchDiets(),
        builder: (context, AsyncSnapshot<List<DietModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.green,
                size: 70,
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          final diets = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.02,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kealthy Diet Plans',
                    style: TextStyle(
                      fontSize: screenWidth * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  for (var diet in diets) ...[
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoModalPopupRoute(
                                builder: (context) => DietProducts(
                                  dietName: diet.name,
                                ),
                              ));
                        },
                        child: _buildMealCard(diet, screenWidth, screenHeight)),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<DietModel>> _fetchDiets() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('Diets').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return DietModel(
        name: data['Name'],
        description: data['Description'],
        imageUrl: data['ImageUrl'],
      );
    }).toList();
  }

  Widget _buildMealCard(
      DietModel diet, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: diet.imageUrl,
            height: screenHeight * 0.15,
            width: screenHeight * 0.15,
            fit: BoxFit.cover,
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  diet.name,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  diet.description.replaceAll("\\n", "\n"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.025,
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

class DietModel {
  final String name;
  final String description;
  final String imageUrl;

  DietModel({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

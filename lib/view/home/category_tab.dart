import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/view/home/coolcategory.dart';
import 'package:kealthy/view/home/hotcategory.dart';
import 'Category.dart';

final tabIndexProvider = StateProvider<int>((ref) => 0);

class CategoryTabPage extends ConsumerStatefulWidget {
  const CategoryTabPage({super.key});

  @override
  ConsumerState<CategoryTabPage> createState() => _CategoryTabPageState();
}

class _CategoryTabPageState extends ConsumerState<CategoryTabPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tabIndexProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              ref.read(tabIndexProvider.notifier).state = index;
            },
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Groceries'),
              Tab(text: 'Food'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.50,
          child: TabBarView(
            controller: _tabController,
            children: const [
              HomeCategory(),
              Center(
                child: FoodCategory(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FoodCategory extends StatelessWidget {
  const FoodCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> foodItems = ["Hot", "Cool"];
    final List<IconData> icons = [Icons.local_fire_department, Icons.ac_unit];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foodItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (index == 0) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const HotPage()));
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const CoolPage()));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icons[index],
                    size: 32, color: Theme.of(context).primaryColor),
                const SizedBox(height: 8),
                Text(
                  foodItems[index],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

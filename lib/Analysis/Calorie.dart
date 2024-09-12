import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Riverpod/calorie_provider.dart';

class CalorieIntakePage extends ConsumerWidget {
  const CalorieIntakePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calorieState = ref.watch(calorieProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              hintText: 'Weight (kg)',
              icon: Icons.scale,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(calorieProvider.notifier)
                    .updateWeight(double.tryParse(value) ?? 0);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Height (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(calorieProvider.notifier)
                    .updateHeight(double.tryParse(value) ?? 0);
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Age (Years)',
              icon: Icons.person,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(calorieProvider.notifier)
                    .updateAge(int.tryParse(value) ?? 0);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Radio<String>(
                  activeColor: Colors.green,
                  value: 'male',
                  groupValue: calorieState.gender,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(calorieProvider.notifier).updateGender(value);
                    }
                  },
                ),
                const Text('Male'),
                Radio<String>(
                  activeColor: Colors.green,
                  value: 'female',
                  groupValue: calorieState.gender,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(calorieProvider.notifier).updateGender(value);
                    }
                  },
                ),
                const Text('Female'),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (calorieState.weight > 0 &&
                      calorieState.height > 0 &&
                      calorieState.age > 0 &&
                      calorieState.gender != '') {
                    ref.read(calorieProvider.notifier).calculateCalories(1.375);
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please fill all fields",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM_LEFT,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  'Calculate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                final maintenanceCalories =
                    ref.watch(calorieProvider).maintenanceCalories;
                final calorieLoss = ref.watch(calorieProvider).calorieLoss;
                final calorieGain = ref.watch(calorieProvider).calorieGain;

                if (maintenanceCalories != null) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 600) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _calorieInfoCard(
                              title: 'Lose weight',
                              calories:
                                  '${calorieLoss!.toStringAsFixed(0)} - ${(calorieLoss + 100).toStringAsFixed(0)} cal',
                              description:
                                  'This range of daily calories will enable you to lose 1-2 lb per week in a healthy and sustainable way.',
                              color: Colors.red[100],
                              iconColor: Colors.red,
                              icon: Icons.arrow_downward,
                            ),
                            _calorieInfoCard(
                              title: 'Maintain weight',
                              calories:
                                  '${maintenanceCalories.toStringAsFixed(0)} - ${(maintenanceCalories + 100).toStringAsFixed(0)} cal',
                              description:
                                  'This range of daily calories will enable you to maintain your current weight.',
                              color: Colors.green[100],
                              iconColor: Colors.green,
                              icon: Icons.arrow_forward,
                            ),
                            _calorieInfoCard(
                              title: 'Gain weight',
                              calories:
                                  '${calorieGain!.toStringAsFixed(0)} - ${(calorieGain + 100).toStringAsFixed(0)} cal',
                              description:
                                  'This range of daily calories will enable you to gain 1-2 lb per week.',
                              color: Colors.blue[100],
                              iconColor: Colors.blue,
                              icon: Icons.arrow_upward,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _calorieInfoCard(
                              title: 'Lose weight',
                              calories:
                                  '${calorieLoss!.toStringAsFixed(0)} - ${(calorieLoss + 100).toStringAsFixed(0)} cal',
                              description:
                                  'This range of daily calories will enable you to lose 1-2 lb per week in a healthy and sustainable way.',
                              color: Colors.red[100],
                              iconColor: Colors.red,
                              icon: Icons.arrow_downward,
                            ),
                            const SizedBox(height: 16),
                            _calorieInfoCard(
                              title: 'Maintain weight',
                              calories:
                                  '${maintenanceCalories.toStringAsFixed(0)} - ${(maintenanceCalories + 100).toStringAsFixed(0)} cal',
                              description:
                                  'This range of daily calories will enable you to maintain your current weight.',
                              color: Colors.green[100],
                              iconColor: Colors.green,
                              icon: Icons.arrow_forward,
                            ),
                            const SizedBox(height: 16),
                            _calorieInfoCard(
                              title: 'Gain weight',
                              calories:
                                  '${calorieGain!.toStringAsFixed(0)} - ${(calorieGain + 100).toStringAsFixed(0)} cal',
                              description:
                                  'This range of daily calories will enable you to gain 1-2 lb per week.',
                              color: Colors.blue[100],
                              iconColor: Colors.blue,
                              icon: Icons.arrow_upward,
                            ),
                          ],
                        );
                      }
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _calorieInfoCard({
    required String title,
    required String calories,
    required String description,
    required Color? color,
    required Color? iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Calorie intake per day',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            calories,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    required this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

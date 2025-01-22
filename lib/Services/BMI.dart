import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Riverpod/calorie_provider.dart';

class CalorieIntakePage extends ConsumerStatefulWidget {
  const CalorieIntakePage({super.key});

  @override
  ConsumerState<CalorieIntakePage> createState() => _CalorieIntakePageState();
}

class _CalorieIntakePageState extends ConsumerState<CalorieIntakePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calorieState = ref.watch(calorieProvider);

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(calorieProvider);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "Kealthy BMI Tracker",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                hintText: 'Weight (kg)',
                icon: Icons.accessibility_new,
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
                  int? age = int.tryParse(value);
                  if (age == null || age < 2 || age > 100) {
                    Fluttertoast.showToast(
                      msg: "Please enter a valid age between 2 and 100.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM_LEFT,
                      timeInSecForIosWeb: 1,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    ref.read(calorieProvider.notifier).updateAge(age);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Radio<String>(
                    activeColor: const Color(0xFF273847),
                    value: 'male',
                    groupValue: calorieState.gender,
                    onChanged: (value) {
                      if (value != null) {
                        FocusScope.of(context).unfocus();
                        ref.read(calorieProvider.notifier).updateGender(value);
                      }
                    },
                  ),
                  Text('Male', style: GoogleFonts.poppins()),
                  Radio<String>(
                    activeColor: const Color(0xFF273847),
                    value: 'female',
                    groupValue: calorieState.gender,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(calorieProvider.notifier).updateGender(value);
                      }
                    },
                  ),
                  Text('Female', style: GoogleFonts.poppins()),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();

                    if (calorieState.weight > 0 &&
                        calorieState.height > 0 &&
                        calorieState.age > 0 &&
                        calorieState.gender.isNotEmpty) {
                      ref
                          .read(calorieProvider.notifier)
                          .calculateCalories(1.375);

                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please fill all fields.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM_LEFT,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    backgroundColor: const Color(0xFF273847),
                  ),
                  child: Text(
                    'Calculate BMI',
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 12),
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
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    padding: const EdgeInsets.symmetric(horizontal: 25),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 32),
        const SizedBox(height: 5),
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          'Calorie intake per day',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          calories,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: GoogleFonts.poppins(fontSize: 10),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
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
          color: Colors.grey.shade500,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF273847),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
                suffixText: hintText,
                suffixStyle: GoogleFonts.poppins(),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalorieState {
  final double weight;
  final double height;
  final int age;
  final String gender;
  double? maintenanceCalories;
  double? calorieLoss;
  double? calorieGain;

  CalorieState({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    this.maintenanceCalories,
    this.calorieLoss,
    this.calorieGain,
  });

  double calculateBMR() {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double calculateCalories(double activityLevel) {
    return calculateBMR() * activityLevel;
  }
}


final calorieProvider = StateNotifierProvider<CalorieNotifier, CalorieState>((ref) {
  return CalorieNotifier();
});

class CalorieNotifier extends StateNotifier<CalorieState> {
  CalorieNotifier()
      : super(CalorieState(weight: 0, height: 0, age: 0, gender: 'male'));

  void updateWeight(double weight) {
    state = CalorieState(
      weight: weight,
      height: state.height,
      age: state.age,
      gender: state.gender,
      maintenanceCalories: state.maintenanceCalories,
      calorieLoss: state.calorieLoss,
      calorieGain: state.calorieGain,
    );
  }

  void updateHeight(double height) {
    state = CalorieState(
      weight: state.weight,
      height: height,
      age: state.age,
      gender: state.gender,
      maintenanceCalories: state.maintenanceCalories,
      calorieLoss: state.calorieLoss,
      calorieGain: state.calorieGain,
    );
  }

  void updateAge(int age) {
    state = CalorieState(
      weight: state.weight,
      height: state.height,
      age: age,
      gender: state.gender,
      maintenanceCalories: state.maintenanceCalories,
      calorieLoss: state.calorieLoss,
      calorieGain: state.calorieGain,
    );
  }

  void updateGender(String gender) {
    state = CalorieState(
      weight: state.weight,
      height: state.height,
      age: state.age,
      gender: gender,
      maintenanceCalories: state.maintenanceCalories,
      calorieLoss: state.calorieLoss,
      calorieGain: state.calorieGain,
    );
  }

  void calculateCalories(double activityLevel) {
    final maintenanceCalories = state.calculateCalories(activityLevel);
    final calorieLoss = maintenanceCalories - 500;
    final calorieGain = maintenanceCalories + 500;

    state = CalorieState(
      weight: state.weight,
      height: state.height,
      age: state.age,
      gender: state.gender,
      maintenanceCalories: maintenanceCalories,
      calorieLoss: calorieLoss,
      calorieGain: calorieGain,
    );
  }
}

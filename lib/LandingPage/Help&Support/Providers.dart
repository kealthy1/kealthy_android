import 'package:riverpod/riverpod.dart';

class TicketFormState {
  final String? department;
  final String? priority;
  final String? description;

  TicketFormState({this.department, this.priority, this.description});

  TicketFormState copyWith({
    String? department,
    String? priority,
    String? description,
  }) {
    return TicketFormState(
      department: department ?? this.department,
      priority: priority ?? this.priority,
      description: description ?? this.description,
    );
  }
}

class TicketFormNotifier extends StateNotifier<TicketFormState> {
  TicketFormNotifier() : super(TicketFormState());

  void updateDepartment(String department) {
    state = state.copyWith(department: department);
  }

  void updatePriority(String priority) {
    state = state.copyWith(priority: priority);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void resetForm() {
    state = TicketFormState();
  }
}

final ticketFormProvider =
    StateNotifierProvider<TicketFormNotifier, TicketFormState>(
  (ref) => TicketFormNotifier(),
);

class DropdownState {
  final String? firstDropdownValue;
  final List<String> secondDropdownOptions;
  final String? secondDropdownValue;

  DropdownState({
    this.firstDropdownValue,
    this.secondDropdownOptions = const [],
    this.secondDropdownValue,
  });

  DropdownState copyWith({
    String? firstDropdownValue,
    List<String>? secondDropdownOptions,
    String? secondDropdownValue,
  }) {
    return DropdownState(
      firstDropdownValue: firstDropdownValue ?? this.firstDropdownValue,
      secondDropdownOptions:
          secondDropdownOptions ?? this.secondDropdownOptions,
      secondDropdownValue: secondDropdownValue ?? this.secondDropdownValue,
    );
  }
}

class DropdownNotifier extends StateNotifier<DropdownState> {
  DropdownNotifier() : super(DropdownState());

  void updateFirstDropdown(String value) {
    List<String> secondOptions;

    if (value == 'Orders') {
      secondOptions = [
        'Missing Items in Order',
        'Delivery Cancelled Without Notice',
        'Package Not Received',
        'Late Delivery',
        'Other',
      ];
    } else if (value == 'Payments') {
      secondOptions = ['Failed', 'Pending'];
    } else if (value == 'Report Bug') {
      secondOptions = [
        'App Crashing',
        'Unable to Login',
        'Feature Not Working',
        'Slow Performance',
        'other',
      ];
    } else if (value == 'Feedback') {
      secondOptions = [
        'Order Experience',
        'App Experience',
        'Delivery Experience',
        'Other'
      ];
    } else {
      secondOptions = [];
    }

    state = state.copyWith(
      firstDropdownValue: value,
      secondDropdownOptions: secondOptions,
      secondDropdownValue: null,
    );
  }

  void updateSecondDropdown(String value) {
    state = state.copyWith(secondDropdownValue: value);
  }
}

final dropdownProvider = StateNotifierProvider<DropdownNotifier, DropdownState>(
  (ref) => DropdownNotifier(),
);

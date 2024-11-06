import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryInstructionNotifier extends StateNotifier<Set<String>> {
  DeliveryInstructionNotifier() : super({});

  Future<void> toggleInstruction(String instruction) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedInstructions = Set<String>.from(state);
    if (updatedInstructions.contains(instruction)) {
      updatedInstructions.remove(instruction);
    } else {
      updatedInstructions.add(instruction);
    }

    if (updatedInstructions.isEmpty) {
      await prefs.remove('deliveryInstructions');
      print('Cleared all delivery instructions due to none selected.');
    } else {
      await prefs.setStringList(
          'deliveryInstructions', updatedInstructions.toList());
      print('Saved Instructions: ${updatedInstructions.toList()}');
    }
    state = updatedInstructions;

    print(
        '$instruction has been ${updatedInstructions.contains(instruction) ? 'added' : 'removed'} from saved instructions.');
  }

  Future<void> clearInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('deliveryInstructions');
    state = {};
    print('Cleared all delivery instructions.');
  }
}

final deliveryInstructionProvider =
    StateNotifierProvider<DeliveryInstructionNotifier, Set<String>>((ref) {
  return DeliveryInstructionNotifier();
});

class DeliveryInstructionsSection extends ConsumerWidget {
  const DeliveryInstructionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedInstructions = ref.watch(deliveryInstructionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Instructions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildInstructionTile(
                    context: context,
                    ref: ref,
                    icon: Icons.notifications_active,
                    label: 'Avoid ringing bell',
                    selected: selectedInstructions,
                  ),
                  const SizedBox(width: 10),
                  _buildInstructionTile(
                    context: context,
                    ref: ref,
                    icon: Icons.door_front_door_outlined,
                    label: 'Leave at the door',
                    selected: selectedInstructions,
                  ),
                  const SizedBox(width: 10),
                  _buildInstructionTile(
                    context: context,
                    ref: ref,
                    icon: Icons.person_outlined,
                    label: 'Leave With Guard',
                    selected: selectedInstructions,
                  ),
                  const SizedBox(width: 10),
                  _buildInstructionTile(
                    context: context,
                    ref: ref,
                    icon: Icons.phone_disabled,
                    label: 'Avoid calling',
                    selected: selectedInstructions,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String label,
    required Set<String> selected,
  }) {
    final isSelected = selected.contains(label);

    return GestureDetector(
      onTap: () {
        ref.read(deliveryInstructionProvider.notifier).toggleInstruction(label);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.22,
        height: MediaQuery.of(context).size.height * 0.14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? Colors.green : Colors.grey[100],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.black, size: 30),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

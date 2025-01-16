import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeliveryInstructionNotifier extends StateNotifier<Set<String>> {
  DeliveryInstructionNotifier() : super({});

  /// Toggles the delivery instruction. If the instruction exists, it will be removed; otherwise, it will be set.
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
      print('Cleared all delivery instructions.');
    } else {
      // Convert the set into a comma-separated string
      final instructionsString = updatedInstructions.join(',');
      await prefs.setString('deliveryInstructions', instructionsString);
      print('Saved Instructions: $instructionsString');
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

  Future<void> loadInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedInstructions = prefs.getString('deliveryInstructions');

    if (savedInstructions != null && savedInstructions.isNotEmpty) {
      state = savedInstructions.split(',').toSet();
    } else {
      state = {};
    }

    print('Loaded instructions: $state');
  }
}

final deliveryInstructionProvider =
    StateNotifierProvider<DeliveryInstructionNotifier, Set<String>>((ref) {
  return DeliveryInstructionNotifier();
});

class DeliveryInstructionsSection extends ConsumerStatefulWidget {
  const DeliveryInstructionsSection({super.key});

  @override
  ConsumerState<DeliveryInstructionsSection> createState() =>
      _DeliveryInstructionsSectionState();
}

class _DeliveryInstructionsSectionState
    extends ConsumerState<DeliveryInstructionsSection> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _loadSavedInstructions();
    _textController.addListener(_handleTextChange);

    // Load saved delivery instructions
    ref.read(deliveryInstructionProvider.notifier).loadInstructions();
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChange);
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedInstructions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedInstructions = prefs.getString('cookinginstrcutions');
    _textController.text =
        savedInstructions ?? "Don't send cutlery, tissues, and Straws";
  }

  Future<void> _handleTextChange() async {
    final prefs = await SharedPreferences.getInstance();
    final text = _textController.text.trim();
    if (text.isEmpty) {
      await prefs.remove('cookinginstrcutions');
      print('Cleared text instruction.');
    } else {
      await prefs.setString('cookinginstrcutions', text);
      print('Saved text instruction: $text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedInstructions = ref.watch(deliveryInstructionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instructions',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _textController,
            textAlign: TextAlign.start,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Cooking Instructions",
              hintStyle: GoogleFonts.poppins(),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final tileWidth = constraints.maxWidth / 4.5;
              final tileHeight = tileWidth * 1.2;

              return SingleChildScrollView(
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
                      width: tileWidth,
                      height: tileHeight,
                    ),
                    const SizedBox(width: 10),
                    _buildInstructionTile(
                      context: context,
                      ref: ref,
                      icon: Icons.door_front_door_outlined,
                      label: 'Leave at the door',
                      selected: selectedInstructions,
                      width: tileWidth,
                      height: tileHeight,
                    ),
                    const SizedBox(width: 10),
                    _buildInstructionTile(
                      context: context,
                      ref: ref,
                      icon: Icons.person_outlined,
                      label: 'Leave With Guard',
                      selected: selectedInstructions,
                      width: tileWidth,
                      height: tileHeight,
                    ),
                    const SizedBox(width: 10),
                    _buildInstructionTile(
                      context: context,
                      ref: ref,
                      icon: Icons.phone_disabled,
                      label: 'Avoid calling',
                      selected: selectedInstructions,
                      width: tileWidth,
                      height: tileHeight,
                    ),
                    const SizedBox(width: 10),
                    _buildInstructionTile(
                      context: context,
                      ref: ref,
                      icon: Icons.pets,
                      label: 'Pet at Home',
                      selected: selectedInstructions,
                      width: tileWidth,
                      height: tileHeight,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildInstructionTile({
  required BuildContext context,
  required WidgetRef ref,
  required IconData icon,
  required String label,
  required Set<String> selected,
  required double width,
  required double height,
}) {
  final isSelected = selected.contains(label);

  return GestureDetector(
    onTap: () {
      ref.read(deliveryInstructionProvider.notifier).toggleInstruction(label);
    },
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? const Color(0xFF273847) : Colors.grey[100],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.black, size: 30),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );
}

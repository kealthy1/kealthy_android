import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Floating_button.dart';

final draggableFabPositionProvider =
    StateProvider<Offset>((ref) => const Offset(11.0, 300.0));

class DraggableFloatingActionButton extends ConsumerWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final String label;

  const DraggableFloatingActionButton({
    super.key,
    required this.imageUrl,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(draggableFabPositionProvider);
    final screenSize = MediaQuery.of(context).size;
    final fabSize = 56.0;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          final currentPosition = ref.read(draggableFabPositionProvider);
          double newX = currentPosition.dx + details.delta.dx;
          double newY = currentPosition.dy + details.delta.dy;

          newX = newX.clamp(0, screenSize.width - fabSize);
          newY = newY.clamp(0, screenSize.height - fabSize - kToolbarHeight);

          ref.read(draggableFabPositionProvider.notifier).state =
              Offset(newX, newY);
        },
        child: ReusableFloatingActionButton(
          imageUrl: imageUrl,
          onTap: onTap,
          label: label,
        ),
      ),
    );
  }
}

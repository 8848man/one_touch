import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch_camera_v2/design_system/design_system.dart';

// Replaces the default counter test from `flutter create`, which referenced a
// MyApp widget that does not exist in this project.
void main() {
  testWidgets('album chip bar marks the selected album and reports taps', (tester) async {
    String? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          backgroundColor: AppColors.cameraSurface,
          body: Center(
            child: AlbumChipBar(
              items: const [
                AlbumChipItem(id: 'a', label: 'trip'),
                AlbumChipItem(id: 'b', label: 'work'),
              ],
              selectedId: 'a',
              onSelected: (id) => tapped = id,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('trip'), findsOneWidget);
    await tester.tap(find.text('work'));
    expect(tapped, 'b');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension Utils on WidgetTester {
  /// Scrolls until [finder] finds a single [Widget].
  ///
  /// This helper is only required because [WidgetTester.ensureVisible] does not yet work for items that are scrolled
  /// out of view in a [ListView]. See https://github.com/flutter/flutter/issues/17668. Once that issue is resolved,
  /// we should be able to remove this altogether.
  ///
  /// On top of that, this would ideally be an extension method against [WidgetTester], but at the time of writing,
  /// extension methods are not yet available in the stable channel.
  Future<void> ensureVisibleByScrolling(
    Finder finder, {
    required Offset scrollFrom,
    Offset scrollBy = const Offset(0, -50),
    int maxScrolls = 300,
  }) async {
    final gesture = await startGesture(scrollFrom);

    Widget? foundWidget;

    for (var i = 0; i < maxScrolls; ++i) {
      await gesture.moveBy(scrollBy);
      await pump();
      final widgets = widgetList(finder);

      if (widgets.length == 1) {
        foundWidget = widgets.first;
        break;
      }
    }

    await gesture.cancel();

    expect(foundWidget, isNotNull);

    // Just because we found the widget, doesn't mean it's visible. It could be off-stage. But now we can at least use the standard
    // ensureVisible method to bring it on-screen.
    await ensureVisible(finder);
    // Attempting to bring the widget on-screen may result in it being scrolled too far up in a list, in which case it will bounce back
    // once the gesture above completes. We need to pump for long enough for the bounce-back animation to complete.
    await pump(const Duration(seconds: 1));
  }
}

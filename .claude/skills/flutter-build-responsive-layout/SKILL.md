---
name: flutter-build-responsive-layout
description: Use `LayoutBuilder`, `MediaQuery`, or `Expanded/Flexible` to create a layout that adapts to different screen sizes. Use when you need the UI to look good on both mobile and tablet/desktop form factors.
metadata:
  model: models/gemini-3.1-pro-preview
  last_modified: Tue, 21 Apr 2026 20:17:40 GMT
---
# Implementing Adaptive Layouts

## Contents
- [Space Measurement Guidelines](#space-measurement-guidelines)
- [Widget Sizing and Constraints](#widget-sizing-and-constraints)
- [Device and Orientation Behaviors](#device-and-orientation-behaviors)
- [Workflow: Constructing an Adaptive Layout](#workflow-constructing-an-adaptive-layout)
- [Workflow: Optimizing for Large Screens](#workflow-optimizing-for-large-screens)
- [Examples](#examples)

## Space Measurement Guidelines
Determine the available space accurately to ensure layouts adapt to the app window, not just the physical device.

*   **Use `MediaQuery.sizeOf(context)`** to get the size of the entire app window.
*   **Use `LayoutBuilder`** to make layout decisions based on the parent widget's allocated space. Evaluate `constraints.maxWidth` to determine the appropriate widget tree to return.
*   **Do not use `MediaQuery.orientationOf` or `OrientationBuilder`** near the top of the widget tree to switch layouts. Device orientation does not accurately reflect the available app window space.
*   **Do not check for hardware types** (e.g., "phone" vs. "tablet"). Flutter apps run in resizable windows, multi-window modes, and picture-in-picture. Base all layout decisions strictly on available window space.

## Widget Sizing and Constraints
Understand and apply Flutter's core layout rule: **Constraints go down. Sizes go up. Parent sets position.**

*   **Distribute Space:** Use `Expanded` and `Flexible` within `Row`, `Column`, or `Flex` widgets.
    *   Use `Expanded` to force a child to fill all remaining available space.
    *   Use `Flexible` to allow a child to size itself up to a specific limit.
*   **Constrain Width:** Prevent widgets from consuming all horizontal space on large screens. Wrap widgets like `GridView` or `ListView` in a `ConstrainedBox` and define a `maxWidth` in the `BoxConstraints`.
*   **Lazy Rendering:** Always use `ListView.builder` or `GridView.builder` when rendering lists with an unknown or large number of items.

## Device and Orientation Behaviors
Ensure the app behaves correctly across all device form factors and input methods.

*   **Do not lock screen orientation.** Locking orientation causes severe layout issues on foldable devices.
*   **Support Multiple Inputs:** Implement support for basic mice, trackpads, and keyboard shortcuts. Ensure touch targets are appropriately sized and keyboard navigation is accessible.

## Workflow: Constructing an Adaptive Layout

**Task Progress:**
- [ ] Identify the target widget that requires adaptive behavior.
- [ ] Wrap the widget tree in a `LayoutBuilder`.
- [ ] Extract the `constraints.maxWidth` from the builder callback.
- [ ] Define an adaptive breakpoint (e.g., `largeScreenMinWidth = 600`).
- [ ] **If `maxWidth > largeScreenMinWidth`:** Return a large-screen layout (e.g., sidebar + content).
- [ ] **If `maxWidth <= largeScreenMinWidth`:** Return a small-screen layout.
- [ ] Run validator -> resize the application window -> review layout transitions -> fix overflow errors.

## Workflow: Optimizing for Large Screens

**Task Progress:**
- [ ] Identify full-width components (e.g., `ListView`, text blocks, forms).
- [ ] **If optimizing a list:** Convert `ListView.builder` to `GridView.builder` with `SliverGridDelegateWithMaxCrossAxisExtent`.
- [ ] **If optimizing a form or text block:** Wrap in a `ConstrainedBox` with `BoxConstraints(maxWidth: [optimal_width])`.
- [ ] Wrap the `ConstrainedBox` in a `Center` widget.
- [ ] Run validator -> test on desktop/tablet -> review horizontal stretching -> adjust `maxWidth`.

## Examples

### Adaptive Layout using LayoutBuilder

```dart
const double largeScreenMinWidth = 600.0;

class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > largeScreenMinWidth) {
          return Row(
            children: [
              const SizedBox(width: 250, child: Placeholder(color: Colors.blue)),
              const VerticalDivider(width: 1),
              Expanded(child: const Placeholder(color: Colors.green)),
            ],
          );
        } else {
          return const Placeholder(color: Colors.green);
        }
      },
    );
  }
}
```

### Constraining Width on Large Screens

```dart
class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800.0),
          child: ListView.builder(
            itemCount: 50,
            itemBuilder: (context, index) => ListTile(title: Text('Item $index')),
          ),
        ),
      ),
    );
  }
}
```

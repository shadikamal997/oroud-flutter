# Shop Dashboard Widgets - Usage Guide

## Quick Start

Import all widgets at once:
```dart
import 'package:oroud_app/features/shop_dashboard/presentation/widgets/widgets.dart';
```

Or import individually:
```dart
import 'package:oroud_app/features/shop_dashboard/presentation/widgets/empty_state_widget.dart';
```

---

## 1. EmptyStateWidget

### Basic Usage
```dart
EmptyStateWidget(
  icon: Icons.local_offer_outlined,
  title: 'No offers yet',
  subtitle: 'Create your first offer to get started',
)
```

### With Action Button
```dart
EmptyStateWidget(
  icon: Icons.inbox,
  title: 'No notifications',
  subtitle: 'You\'ll see updates here when customers interact with your offers',
  actionLabel: 'Create an Offer',
  onAction: () => context.push('/shop/create-offer'),
  color: ShopColors.primary,
)
```

### Properties
- `icon` (required) - IconData to display
- `title` (required) - Main heading text
- `subtitle` (required) - Descriptive supporting text
- `actionLabel` (optional) - Button text
- `onAction` (optional) - Button callback
- `color` (optional) - Theme color (default: orange)
- `showAnimation` (optional) - Enable/disable animations (default: true)

---

## 2. StatCard

### Basic Usage
```dart
StatCard(
  icon: Icons.visibility,
  label: 'Total Views',
  value: '1,234',
  color: Colors.blue,
)
```

### With Subtitle and Trend
```dart
StatCard(
  icon: Icons.favorite,
  label: 'Saves',
  value: '567',
  color: Colors.red,
  subtitle: 'Last 30 days',
  showTrend: true,
  trendValue: 12.5, // Positive = green ↑, negative = red ↓
  onTap: () => print('Navigate to details'),
)
```

### Properties
- `icon` (required) - Metric icon
- `label` (required) - Metric name
- `value` (required) - Display value (string for formatting control)
- `color` (required) - Theme color
- `subtitle` (optional) - Additional context
- `onTap` (optional) - Make card tappable
- `showTrend` (optional) - Show trend indicator
- `trendValue` (optional) - Percentage change (+/- for direction)

---

## 3. OnboardingTip

### Basic Usage
```dart
OnboardingTip(
  tipKey: 'welcome_dashboard',
  title: '👋 Welcome!',
  message: 'This is your shop control center. Create offers, view analytics, and more.',
)
```

### With Action
```dart
OnboardingTip(
  tipKey: 'first_offer_tip',
  title: '💡 Pro Tip',
  message: 'Great offers have clear titles, high-quality images, and limited-time urgency.',
  icon: Icons.lightbulb_outline,
  actionLabel: 'Learn More',
  onAction: () => launchUrl('https://help.oroud.app/best-offers'),
  color: ShopColors.info,
)
```

### Properties
- `tipKey` (required) - Unique identifier for persistence
- `title` (required) - Tip heading
- `message` (required) - Tip content
- `icon` (optional) - Leading icon
- `color` (optional) - Theme color
- `actionLabel` (optional) - CTA button text
- `onAction` (optional) - CTA callback

### Note
Tips are automatically saved to SharedPreferences when dismissed. Same tipKey will never show again.

---

## 4. PerformanceChart

### Basic Usage
```dart
PerformanceChart(
  title: 'Weekly Views',
  valueLabel: 'Last 7 Days',
  color: ShopColors.primary,
  data: [
    ChartData(label: 'Mon', value: 45),
    ChartData(label: 'Tue', value: 67),
    ChartData(label: 'Wed', value: 52),
    ChartData(label: 'Thu', value: 88),
    ChartData(label: 'Fri', value: 95),
    ChartData(label: 'Sat', value: 102),
    ChartData(label: 'Sun', value: 76),
  ],
)
```

### Properties
- `data` (required) - List of ChartData points
- `title` (required) - Chart heading
- `color` (required) - Line and area color
- `valueLabel` (required) - Badge label (e.g., "Last 7 Days")

### ChartData
```dart
ChartData({
  required String label,  // X-axis label
  required double value,  // Y-axis value
})
```

---

## 5. Success Animation

### Show Success Overlay
```dart
showSuccessOverlay(
  context, 
  'Offer created successfully!',
  onComplete: () {
    context.go('/shop/offers');
  },
);
```

### Custom Success Widget
```dart
SuccessAnimation(
  message: 'Settings saved!',
  onComplete: () => Navigator.pop(context),
)
```

---

## 6. Smooth Widgets

### Loading Indicator
```dart
// Simple
SmoothLoadingIndicator()

// With message
SmoothLoadingIndicator(
  message: 'Loading analytics...',
  color: ShopColors.primary,
)
```

### Error Widget
```dart
SmoothErrorWidget(
  message: 'Failed to load offers',
  onRetry: () => ref.refresh(myOffersProvider),
  icon: Icons.cloud_off,
)
```

---

## 7. Shop Theme Constants

### Colors
```dart
ShopColors.primary      // Orange
ShopColors.secondary    // Pink
ShopColors.success      // Green
ShopColors.error        // Red
ShopColors.warning      // Amber
ShopColors.info         // Blue

// Semantic
ShopColors.activeColor
ShopColors.expiredColor
ShopColors.premiumColor
```

### Spacing
```dart
ShopSpacing.xs    // 4.0
ShopSpacing.sm    // 8.0
ShopSpacing.md    // 16.0
ShopSpacing.lg    // 24.0
ShopSpacing.xl    // 32.0
ShopSpacing.xxl   // 48.0
```

### Text Styles
```dart
ShopTextStyles.heading
ShopTextStyles.subheading
ShopTextStyles.body
ShopTextStyles.caption
ShopTextStyles.buttonText
```

### Border Radius
```dart
ShopBorderRadius.smallRadius       // 8.0
ShopBorderRadius.mediumRadius      // 12.0
ShopBorderRadius.largeRadius       // 16.0
ShopBorderRadius.extraLargeRadius  // 20.0
```

### Card Decorations
```dart
ShopCardDecoration.standard  // Light shadow
ShopCardDecoration.elevated  // Heavy shadow
ShopCardDecoration.premium   // Gold gradient border
```

### Button Styles
```dart
ElevatedButton(
  onPressed: () {},
  style: ShopButtonStyle.primary,
  child: Text('Save'),
)

OutlinedButton(
  onPressed: () {},
  style: ShopButtonStyle.outlined,
  child: Text('Cancel'),
)
```

---

## Common Patterns

### Loading → Data → Empty State
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final dataAsync = ref.watch(myDataProvider);
  
  return dataAsync.when(
    loading: () => SmoothLoadingIndicator(message: 'Loading...'),
    error: (err, stack) => SmoothErrorWidget(
      message: err.toString(),
      onRetry: () => ref.refresh(myDataProvider),
    ),
    data: (items) {
      if (items.isEmpty) {
        return EmptyStateWidget(
          icon: Icons.inbox,
          title: 'Nothing here yet',
          subtitle: 'Your items will appear here',
        );
      }
      return ListView.builder(...);
    },
  );
}
```

### Create with Success Feedback
```dart
Future<void> _createOffer() async {
  try {
    await api.createOffer(offerData);
    
    if (mounted) {
      showSuccessOverlay(
        context,
        'Offer created successfully!',
        onComplete: () => context.go('/shop/my-offers'),
      );
    }
  } catch (e) {
    // Show error snackbar
  }
}
```

### Onboarding Flow
```dart
Column(
  children: [
    OnboardingTip(
      tipKey: 'step_1',
      title: 'Step 1: Profile',
      message: 'Complete your shop profile first',
      onAction: () => context.push('/shop/profile'),
    ),
    OnboardingTip(
      tipKey: 'step_2',
      title: 'Step 2: First Offer',
      message: 'Create your first offer to attract customers',
      onAction: () => context.push('/shop/create-offer'),
    ),
  ],
)
```

---

## Best Practices

1. **Consistent Colors** - Always use `ShopColors.*` instead of hardcoded colors
2. **Spacing** - Use `ShopSpacing.*` for consistent padding/margins
3. **Empty States** - Always provide actionable empty states
4. **Loading States** - Show feedback for async operations
5. **Success Feedback** - Confirm important actions with animations
6. **Error Handling** - Provide retry mechanisms
7. **Animations** - Keep durations between 200-500ms
8. **Accessibility** - Ensure high contrast and readable text

---

## Examples in Codebase

- **EmptyState**: `my_offers_screen.dart` line 196
- **StatCard**: `shop_analytics_screen.dart` line 68
- **OnboardingTip**: `shop_dashboard_screen.dart` line 38
- **PerformanceChart**: `shop_analytics_screen.dart` line 120
- **Theme Usage**: All shop dashboard screens

---

**Questions?** Check the component source files for full implementation details.

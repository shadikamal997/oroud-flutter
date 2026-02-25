#!/bin/bash

FILES=(
"lib/features/offers/presentation/saved_offers_screen.dart"
"lib/features/shop_dashboard/presentation/shop_settings_screen.dart"
"lib/features/shop_dashboard/presentation/shop_dashboard_screen.dart"
"lib/features/shop_dashboard/presentation/edit_offer_screen.dart"
"lib/features/shop_dashboard/presentation/create_offer_screen.dart"
"lib/features/shop_dashboard/presentation/shop_notifications_screen.dart"
"lib/features/shop_dashboard/presentation/my_offers_screen.dart"
"lib/features/shop_dashboard/presentation/premium_upgrade_screen.dart"
"lib/features/shop_dashboard/presentation/widgets/smooth_widgets.dart"
"lib/features/shop_dashboard/presentation/widgets/onboarding_tip.dart"
"lib/features/shop_dashboard/presentation/widgets/shop_theme.dart"
"lib/features/shop_dashboard/presentation/widgets/empty_state_widget.dart"
"lib/features/shop_dashboard/presentation/register_shop_screen.dart"
"lib/features/profile/presentation/reviews_history_screen.dart"
"lib/features/profile/presentation/settings_screen.dart"
"lib/features/profile/presentation/following_screen.dart"
"lib/features/profile/presentation/city_selection_screen.dart"
"lib/features/profile/presentation/profile_screen.dart"
"lib/features/profile/presentation/edit_profile_screen.dart"
"lib/features/profile/presentation/widgets/user_onboarding_widget.dart"
"lib/features/profile/presentation/widgets/delete_account_dialog.dart"
"lib/features/profile/presentation/widgets/avatar_upload_widget.dart"
"lib/features/profile/presentation/help_support_screen.dart"
"lib/features/profile/presentation/user_notifications_screen.dart"
"lib/shared/widgets/hero_slider.dart"
"lib/shared/widgets/special_offer_section.dart"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    if ! grep -q "app_colors.dart" "$file"; then
      # Add import after the first import line
      awk '/^import / && !done { print; print "import '\''package:oroud_app/core/theme/app_colors.dart'\'';"; done=1; next }1' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
      echo "Added import to $file"
    fi
  fi
done

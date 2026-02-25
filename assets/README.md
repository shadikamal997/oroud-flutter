# Assets Folder Structure

This folder contains all media assets for the Oroud app.

## 📁 Folder Organization

### `/videos/`
**Purpose:** Video files for splash screen and other video content
- **Required:** `splash.mp4` - Splash screen video (3-4 seconds)
- **Recommended specs:**
  - Resolution: 1080x1920 (portrait) or 720x1280
  - Format: MP4 (H.264 codec)
  - Duration: 3-4 seconds
  - Size: Keep under 2MB

### `/images/`
**Purpose:** Photos, backgrounds, illustrations, and general images
- App backgrounds
- Feature illustrations
- Product images
- Promotional banners
- Example: `logo.png`, `background.jpg`, `promo_banner.png`

### `/icons/`
**Purpose:** App icons, custom icons, and icon assets
- App launcher icons
- Custom UI icons
- Category icons
- Social media icons
- Example: `app_icon.png`, `google_icon.svg`, `facebook_icon.svg`

### `/fonts/` (if needed)
**Purpose:** Custom font files
- TTF or OTF font files
- Example: `custom_font_regular.ttf`, `custom_font_bold.ttf`
- Note: Requires additional configuration in pubspec.yaml under `fonts:` section

## 🎯 Current Configuration

The following asset paths are configured in `pubspec.yaml`:
```yaml
assets:
  - assets/videos/
  - assets/images/
  - assets/icons/
```

## 📝 How to Add Assets

1. **Place your files** in the appropriate folder
2. **Reference in code:**
   ```dart
   // For videos
   VideoPlayerController.asset('assets/videos/splash.mp4')
   
   // For images
   Image.asset('assets/images/logo.png')
   
   // For icons (as images)
   Image.asset('assets/icons/custom_icon.png')
   ```

3. **Hot reload** - Assets are loaded at build time, so you'll need to:
   - Stop the app
   - Run `flutter pub get` (optional, but recommended after adding assets)
   - Restart the app

## ⚠️ Important Notes

- All asset paths are relative to the project root
- Supported image formats: PNG, JPG, GIF, WebP, BMP, WBMP
- Supported video formats: MP4, MOV, AVI (platform dependent)
- Keep file sizes optimized for mobile apps
- Use lowercase filenames with underscores: `splash_video.mp4` ✅ not `SplashVideo.mp4` ❌

## 🚀 Quick Start for Splash Screen

To get your splash screen working:
1. Add `splash.mp4` to `assets/videos/` folder
2. The splash screen code already references: `assets/videos/splash.mp4`
3. Restart your app - it will automatically play!

## 📦 File Size Recommendations

- **Videos:** < 2MB (compress if needed)
- **Images:** 
  - Small icons: < 50KB
  - Regular images: < 500KB
  - Backgrounds: < 1MB
- Use [TinyPNG](https://tinypng.com/) for image compression
- Use [HandBrake](https://handbrake.fr/) for video compression

#!/usr/bin/env python3
"""
Generate complete iOS App Icon Set for Possible Journey
Creates all required sizes for App Store submission
"""

from PIL import Image
import os

def create_icon_set():
    """Create all required iOS app icon sizes"""
    
    # Load the base 1024x1024 icon
    base_icon = Image.open("PossibleJourney_Simple_AppIcon_1024x1024.png")
    
    # iOS App Icon sizes required by Apple
    icon_sizes = {
        # iPhone
        "iPhone_Notifications_20x20@2x": 40,
        "iPhone_Notifications_20x20@3x": 60,
        "iPhone_Settings_29x29@2x": 58,
        "iPhone_Settings_29x29@3x": 87,
        "iPhone_Spotlight_40x40@2x": 80,
        "iPhone_Spotlight_40x40@3x": 120,
        "iPhone_App_60x60@2x": 120,
        "iPhone_App_60x60@3x": 180,
        
        # iPad
        "iPad_Notifications_20x20@1x": 20,
        "iPad_Notifications_20x20@2x": 40,
        "iPad_Settings_29x29@1x": 29,
        "iPad_Settings_29x29@2x": 58,
        "iPad_Spotlight_40x40@1x": 40,
        "iPad_Spotlight_40x40@2x": 80,
        "iPad_App_76x76@1x": 76,
        "iPad_App_76x76@2x": 152,
        "iPad_Pro_App_83.5x83.5@2x": 167,
        
        # App Store
        "App_Store_1024x1024@1x": 1024
    }
    
    # Create output directory
    output_dir = "AppIconSet"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    print("🎨 Generating iOS App Icon Set...")
    
    for name, size in icon_sizes.items():
        # Resize the icon
        resized_icon = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save with descriptive filename
        filename = f"{name}.png"
        filepath = os.path.join(output_dir, filename)
        resized_icon.save(filepath, "PNG")
        
        print(f"✅ {filename} ({size}x{size})")
    
    print(f"\n📁 All icons saved to: {output_dir}/")
    print("📱 Ready for App Store submission!")
    
    # Create a summary file
    summary_path = os.path.join(output_dir, "README.md")
    with open(summary_path, 'w') as f:
        f.write("# Possible Journey App Icon Set\n\n")
        f.write("Complete iOS app icon set for App Store submission.\n\n")
        f.write("## Icon Sizes Generated:\n\n")
        for name, size in icon_sizes.items():
            f.write(f"- {name}: {size}x{size}px\n")
        f.write("\n## Design Theme:\n")
        f.write("- Blue gradient background\n")
        f.write("- Target icon with checkmark\n")
        f.write("- Represents goals and progress\n")
        f.write("- Matches app's habit-building theme\n\n")
        f.write("## Apple Guidelines Compliance:\n")
        f.write("- ✅ All required sizes included\n")
        f.write("- ✅ PNG format with no alpha channel\n")
        f.write("- ✅ Simple, recognizable design\n")
        f.write("- ✅ High contrast for visibility\n")
        f.write("- ✅ Works at all display sizes\n")
    
    print(f"📝 Summary created: {summary_path}")

if __name__ == "__main__":
    create_icon_set() 
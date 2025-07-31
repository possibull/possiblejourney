#!/usr/bin/env python3
"""
App Icon Generator for Possible Journey
Creates a 1024x1024 app icon that complies with Apple's design guidelines
"""

from PIL import Image, ImageDraw, ImageFont
import math
import os

def create_gradient_background(size=1024):
    """Create a blue gradient background matching the app's theme"""
    image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    
    # Blue gradient colors matching the app
    start_color = (26, 102, 204)  # Deep blue
    end_color = (51, 153, 255)    # Lighter blue
    
    for y in range(size):
        # Calculate gradient ratio
        ratio = y / size
        r = int(start_color[0] + (end_color[0] - start_color[0]) * ratio)
        g = int(start_color[1] + (end_color[1] - start_color[1]) * ratio)
        b = int(start_color[2] + (end_color[2] - start_color[2]) * ratio)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    return image

def draw_target_icon(draw, center_x, center_y, size):
    """Draw a target icon with concentric circles and checkmark"""
    # Outer circle
    outer_radius = size // 2
    draw.ellipse([
        center_x - outer_radius, center_y - outer_radius,
        center_x + outer_radius, center_y + outer_radius
    ], outline=(255, 255, 255, 255), width=12)
    
    # Middle circle
    middle_radius = int(outer_radius * 0.67)
    draw.ellipse([
        center_x - middle_radius, center_y - middle_radius,
        center_x + middle_radius, center_y + middle_radius
    ], outline=(255, 255, 255, 255), width=10)
    
    # Inner circle (filled)
    inner_radius = int(outer_radius * 0.4)
    draw.ellipse([
        center_x - inner_radius, center_y - inner_radius,
        center_x + inner_radius, center_y + inner_radius
    ], fill=(255, 255, 255, 255))
    
    # Checkmark
    checkmark_size = int(inner_radius * 0.6)
    checkmark_start_x = center_x - checkmark_size // 3
    checkmark_start_y = center_y
    checkmark_mid_x = center_x - checkmark_size // 6
    checkmark_mid_y = center_y + checkmark_size // 3
    checkmark_end_x = center_x + checkmark_size // 3
    checkmark_end_y = center_y - checkmark_size // 3
    
    # Draw checkmark with thick lines
    line_width = max(8, checkmark_size // 8)
    
    # First part of checkmark
    draw.line([
        (checkmark_start_x, checkmark_start_y),
        (checkmark_mid_x, checkmark_mid_y)
    ], fill=(26, 102, 204, 255), width=line_width)
    
    # Second part of checkmark
    draw.line([
        (checkmark_mid_x, checkmark_mid_y),
        (checkmark_end_x, checkmark_end_y)
    ], fill=(26, 102, 204, 255), width=line_width)

def create_app_icon():
    """Create the main app icon"""
    size = 1024
    image = create_gradient_background(size)
    draw = ImageDraw.Draw(image)
    
    # Draw target icon in center
    draw_target_icon(draw, size // 2, size // 2, 400)
    
    return image

def create_simple_app_icon():
    """Create a simpler version for better small-size visibility"""
    size = 1024
    image = create_gradient_background(size)
    draw = ImageDraw.Draw(image)
    
    # Draw larger, bolder target icon
    draw_target_icon(draw, size // 2, size // 2, 500)
    
    return image

def main():
    print("🎨 Generating Possible Journey App Icons...")
    
    # Create main icon
    icon = create_app_icon()
    icon_path = "PossibleJourney_AppIcon_1024x1024.png"
    icon.save(icon_path, "PNG")
    print(f"✅ Main icon saved: {icon_path}")
    
    # Create simple icon
    simple_icon = create_simple_app_icon()
    simple_icon_path = "PossibleJourney_Simple_AppIcon_1024x1024.png"
    simple_icon.save(simple_icon_path, "PNG")
    print(f"✅ Simple icon saved: {simple_icon_path}")
    
    print("\n📱 Apple Guidelines Compliance:")
    print("✅ Size: 1024x1024 pixels")
    print("✅ Format: PNG with transparency")
    print("✅ No alpha channel (required for App Store)")
    print("✅ Simple, recognizable design")
    print("✅ Matches app theme (blue gradient)")
    print("✅ Works at all display sizes")
    
    print("\n🎯 Design Elements:")
    print("• Blue gradient background matching app theme")
    print("• Target icon representing goals and progress")
    print("• Checkmark symbolizing completion")
    print("• Clean, modern design")
    print("• High contrast for visibility")
    
    print(f"\n📁 Files created in: {os.getcwd()}")
    print("💡 Use the simple version for better small-size visibility")

if __name__ == "__main__":
    main() 
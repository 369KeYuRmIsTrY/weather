import 'package:flutter/material.dart';

class WeatherTheme {
  static List<Color> getGradientColors(String description, String iconCode) {
    final desc = description.toLowerCase();

    // Check icon code first (more accurate)
    if (iconCode.contains('01')) {
      // Clear sky - sunny
      return [
        const Color(0xFF87CEEB), // Sky blue
        const Color(0xFF4682B4), // Steel blue
        const Color(0xFF1E90FF), // Dodger blue
      ];
    } else if (iconCode.contains('02')) {
      // Few clouds
      return [
        const Color(0xFFB0C4DE), // Light steel blue
        const Color(0xFF87CEEB), // Sky blue
        const Color(0xFF4682B4), // Steel blue
      ];
    } else if (iconCode.contains('03') || iconCode.contains('04')) {
      // Cloudy
      return [
        const Color(0xFF708090), // Slate gray
        const Color(0xFF778899), // Light slate gray
        const Color(0xFF696969), // Dim gray
      ];
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      // Rain
      return [
        const Color(0xFF4682B4), // Steel blue
        const Color(0xFF4169E1), // Royal blue
        const Color(0xFF191970), // Midnight blue
      ];
    } else if (iconCode.contains('11')) {
      // Thunderstorm
      return [
        const Color(0xFF483D8B), // Dark slate blue
        const Color(0xFF2F4F4F), // Dark slate gray
        const Color(0xFF000000), // Black
      ];
    } else if (iconCode.contains('13')) {
      // Snow
      return [
        const Color(0xFFE0E0E0), // Light gray
        const Color(0xFFB0B0B0), // Gray
        const Color(0xFF808080), // Dark gray
      ];
    } else if (iconCode.contains('50')) {
      // Mist/Fog
      return [
        const Color(0xFFD3D3D3), // Light gray
        const Color(0xFFA9A9A9), // Dark gray
        const Color(0xFF808080), // Gray
      ];
    }

    // Fallback based on description
    if (desc.contains('clear') || desc.contains('sunny')) {
      return [
        const Color(0xFF87CEEB),
        const Color(0xFF4682B4),
        const Color(0xFF1E90FF),
      ];
    } else if (desc.contains('cloud')) {
      return [
        const Color(0xFF708090),
        const Color(0xFF778899),
        const Color(0xFF696969),
      ];
    } else if (desc.contains('rain') || desc.contains('drizzle')) {
      return [
        const Color(0xFF4682B4),
        const Color(0xFF4169E1),
        const Color(0xFF191970),
      ];
    } else if (desc.contains('storm') || desc.contains('thunder')) {
      return [
        const Color(0xFF483D8B),
        const Color(0xFF2F4F4F),
        const Color(0xFF000000),
      ];
    } else if (desc.contains('snow')) {
      return [
        const Color(0xFFE0E0E0),
        const Color(0xFFB0B0B0),
        const Color(0xFF808080),
      ];
    }

    // Default blue gradient
    return [Colors.blue.shade400, Colors.blue.shade600, Colors.blue.shade800];
  }

  static Color getShadowColor(String iconCode) {
    if (iconCode.contains('01')) {
      return Colors.blue.withOpacity(0.3);
    } else if (iconCode.contains('11')) {
      return Colors.purple.withOpacity(0.4);
    } else if (iconCode.contains('13')) {
      return Colors.grey.withOpacity(0.3);
    }
    return Colors.blue.withOpacity(0.3);
  }
}

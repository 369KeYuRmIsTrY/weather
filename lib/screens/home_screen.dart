import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../models/city_suggestion.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Weather? _weather;
  bool _isLoading = false;
  String _errorMessage = '';
  List<CitySuggestion> _suggestions = [];
  bool _showSuggestions = false;
  bool _isLoadingSuggestions = false;
  Timer? _debounceTimer;

  Future<void> _fetchWeather([String? cityName]) async {
    final city = cityName ?? _cityController.text.trim();
    if (city.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a city name';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _weather = null;
    });

    // Unfocus search field
    _searchFocusNode.unfocus();

    try {
      final weather = await _weatherService.getWeather(city);
      if (!mounted) return;
      setState(() {
        _weather = weather;
        _cityController.text = weather.cityName;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
      _showSuggestions = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 450), () {
      _fetchSuggestions(trimmed);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    try {
      final results = await _weatherService.getCitySuggestions(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isLoadingSuggestions = false;
        _showSuggestions = results.isNotEmpty && _searchFocusNode.hasFocus;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _isLoadingSuggestions = false;
        _showSuggestions = false;
      });
    }
  }

  void _selectSuggestion(CitySuggestion suggestion) {
    setState(() {
      _cityController.text = suggestion.name;
      _showSuggestions = false;
      _suggestions = [];
    });
    _fetchWeather(suggestion.name);
  }

  @override
  void initState() {
    super.initState();
    _cityController.addListener(() {
      _onSearchChanged(_cityController.text);
    });
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      } else if (_cityController.text.trim().length >= 2) {
        setState(() {
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    });
    // Fetch default weather for Delhi
    _fetchWeather('Delhi');
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cityController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _getWeatherIcon(String iconCode) {
    // Use OpenWeatherMap's official weather icons
    // Format: https://openweathermap.org/img/wn/{iconCode}@4x.png
    // @4x provides high resolution for better quality
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@4x.png';

    return Image.network(
      iconUrl,
      width: 160,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to Material icon if network image fails
        return _getFallbackIcon(iconCode);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          width: 160,
          height: 160,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF6B6B6B),
            ),
          ),
        );
      },
    );
  }

  Widget _getFallbackIcon(String iconCode) {
    // Fallback Material icons if network image fails
    if (iconCode.contains('01')) {
      return const Icon(Icons.wb_sunny, size: 110, color: Color(0xFFD39B00));
    } else if (iconCode.contains('02')) {
      return const Icon(Icons.wb_cloudy, size: 110, color: Color(0xFF9E9E9E));
    } else if (iconCode.contains('03') || iconCode.contains('04')) {
      return const Icon(Icons.cloud, size: 110, color: Color(0xFF757575));
    } else if (iconCode.contains('09') || iconCode.contains('10')) {
      return const Icon(Icons.grain, size: 110, color: Color(0xFF2196F3));
    } else if (iconCode.contains('11')) {
      return const Icon(Icons.flash_on, size: 110, color: Color(0xFF9C27B0));
    } else if (iconCode.contains('13')) {
      return const Icon(Icons.ac_unit, size: 110, color: Color(0xFFE0E0E0));
    } else if (iconCode.contains('50')) {
      return const Icon(Icons.blur_on, size: 110, color: Color(0xFFBDBDBD));
    }
    return const Icon(Icons.wb_sunny, size: 110, color: Color(0xFFD39B00));
  }

  Widget _buildWeatherCard() {
    if (_weather == null) return const SizedBox.shrink();

    final subtitle = _weather!.country.isNotEmpty ? _weather!.country : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7E2FF),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _weather!.cityName,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ],
          const SizedBox(height: 36),
          _getWeatherIcon(_weather!.iconCode),
          const SizedBox(height: 28),
          Text(
            '${_weather!.temperature.toStringAsFixed(0)}°',
            style: GoogleFonts.outfit(
              fontSize: 96,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF555555),
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E2FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _cityController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 28,
                            color: Color(0xFF6B6B6B),
                          ),
                          hintText: 'Search your city here...',
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 20,
                            color: const Color(0xFF6B6B6B),
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 16,
                          ),
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: const Color(0xFF1F1F1F),
                          fontWeight: FontWeight.w500,
                        ),
                        onSubmitted: (_) => _fetchWeather(),
                        onChanged: _onSearchChanged,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Suggestions dropdown
                    if (_showSuggestions)
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 220),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _isLoadingSuggestions
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ),
                              )
                            : _suggestions.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No matches found',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF6B6B6B),
                                    fontSize: 14,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: Colors.grey.shade200,
                                ),
                                itemBuilder: (context, index) {
                                  final item = _suggestions[index];
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.location_on,
                                      color: Color(0xFF6B6B6B),
                                    ),
                                    title: Text(
                                      item.name,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F1F1F),
                                      ),
                                    ),
                                    subtitle: Text(
                                      item.country,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: const Color(0xFF6B6B6B),
                                      ),
                                    ),
                                    onTap: () => _selectSuggestion(item),
                                  );
                                },
                              ),
                      ),

                    const SizedBox(height: 12),

                    // Loading / Error / Weather / Empty
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isLoading && _weather == null)
                              const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF6B6B6B),
                                ),
                              ),

                            if (_errorMessage.isNotEmpty && !_isLoading)
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            if (_weather != null) _buildWeatherCard(),

                            if (!_isLoading &&
                                _errorMessage.isEmpty &&
                                _weather == null)
                              Padding(
                                padding: const EdgeInsets.only(top: 80),
                                child: Text(
                                  'Search for a city to see the weather',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: const Color(0xFF6B6B6B),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../data/app_theme.dart';
import '../provider/theme_provider.dart' show ThemeChanged;
import 'save_adapter.dart';
import 'shared_preferences_adapter.dart';

/// Handler which provides the activated controller.
typedef void ThemeControllerHandler(ThemeController controller, Future<String?> previouslySavedThemeFuture);

/// Object which controls the behavior of the theme.
/// This is the object provided through the widget tree.
class ThemeController extends ChangeNotifier {
  /// List of [AppTheme]s that are available to this application.
  /// No two themes cannot have identical theme ids.
  final List<AppTheme> _appThemes;

  /// Reference to the current [AppTheme]
  AppTheme _appTheme;

  /// Adapter which helps to save current theme and load it back.
  /// Currently uses [SharedPreferenceAdapter] which uses shared_preferences plugin.
  final SaveAdapter _saveAdapter = SharedPreferenceAdapter();

  /// Whether to save the theme on disk every time the theme changes
  final bool _saveThemesOnChange;

  /// Whether to load the theme on initialization.
  /// If this is true, default onInitCallback will be executed instead.
  final bool _loadThemeOnInit;

  final ThemeChanged _onThemeChanged;

  /// ThemeProvider id to identify between 2 providers and allow more than 1 provider.
  final String _providerId;

  /// Controller which handles updating and controlling current theme.
  /// [themes] determine the list of themes that will be available.
  /// **[themes] cannot have conflicting [id] parameters**
  /// If conflicting [id]s were found [AssertionError] will be thrown.
  ///
  /// [defaultThemeId] is optional.
  /// If not provided, default theme will be the first provided theme.
  /// Otherwise the given theme will be set as the default theme.
  /// [AssertionError] will be thrown if there is no theme with [defaultThemeId].
  ///
  /// [saveThemesOnChange] is required.
  /// This refers to whether to persist the theme on change.
  /// If it is `true`, theme will be saved to disk whenever the theme changes.
  /// **If you use this, do NOT use nested [ThemeProvider]s as all will be saved in the same key**
  ///
  /// [onInitCallback] is the callback which is called when the ThemeController is first initialed.
  /// You can use this to call `controller.loadThemeById(ID)` or equivalent to set theme.
  ///
  /// [loadThemeOnInit] will load a previously saved theme from disk.
  /// If [loadThemeOnInit] is provided, [onInitCallback] will be ignored.
  /// So [onInitCallback] and [loadThemeOnInit] can't both be provided at the same time.
  ThemeController({
    required String providerId,
    required List<AppTheme> themes,
    required String? defaultThemeId,
    required bool saveThemesOnChange,
    required bool loadThemeOnInit,
    ThemeChanged? onThemeChanged,
    ThemeControllerHandler? onInitCallback,
  })  : _saveThemesOnChange = saveThemesOnChange,
        _loadThemeOnInit = loadThemeOnInit,
        _providerId = providerId,
        _onThemeChanged = onThemeChanged ?? _defaultOnThemeChanged,
        _appThemes = themes,
        _appTheme = themes.first {
    var uniqueIdCheck = Set<AppTheme>.identity();
    themes.forEach((theme) {
      assert(
          !uniqueIdCheck.contains(theme.id),
          "Conflicting theme ids found: "
          "${theme.id} is already added to the widget tree,");
      uniqueIdCheck.add(theme);
    });

    assert(defaultThemeId == null || _appTheme.id == defaultThemeId,
        "No app theme with the default theme id: $defaultThemeId");

    assert(!(onInitCallback != null && _loadThemeOnInit), "Cannot set both onInitCallback and loadThemeOnInit");

    if (_loadThemeOnInit) {
      _getPreviousSavedTheme().then((savedTheme) {
        _setTheme(savedTheme);
      });
    } else if (onInitCallback != null) {
      onInitCallback(this, _saveAdapter.loadTheme(_providerId));
    }
  }

  /// Get the previously saved theme id from disk.
  /// If no previous saved theme, or it is not valid, returns null.
  Future<AppTheme?> _getPreviousSavedTheme() async => _getThemeById(await _saveAdapter.loadTheme(_providerId));

  /// Sets the current theme to given index.
  /// Additionally this notifies all widgets and saves theme.
  AppTheme? _getThemeById(String? themeId) => _appThemes.firstWhere((e) => e.id == themeId, orElse: null);

  void _setTheme(AppTheme? newTheme) {
    if (newTheme == null) {
      return;
    }

    if (_appTheme != newTheme) {
      AppTheme oldTheme = _appTheme;
      _appTheme = newTheme;

      notifyListeners();

      if (_saveThemesOnChange) {
        saveThemeToDisk();
      }

      _onThemeChanged(oldTheme, newTheme);
    }
  }

  // Public methods

  /// Get the current theme
  AppTheme get theme => _appTheme;

  /// Get the current theme id
  String get currentThemeId => _appTheme.id;

  // Get id of the attached provider
  String get providerId => _providerId;

  /// Cycle to next theme in the theme list.
  /// The sequence is determined by the sequence
  /// specified in the [ThemeProvider] in the [themes] parameter.
  void nextTheme() {
    int nextThemeIndex = (_appThemes.indexOf(_appTheme) + 1) % _appThemes.length;
    setTheme(_appThemes.elementAt(nextThemeIndex).id);
  }

  /// Selects the theme by the given theme id.
  /// Throws an [AssertionError] if the theme id is not found.
  void setTheme(String themeId) {
    _setTheme(_getThemeById(themeId)!);
  }

  /// Loads previously saved theme from disk.
  /// If this fails(no previous saved theme) it will be ignored.
  /// (No exceptions will be thrown)
  Future<void> loadThemeFromDisk() async {
    _setTheme(await _getPreviousSavedTheme());
  }

  /// Saves current theme to disk.
  Future<void> saveThemeToDisk() async {
    _saveAdapter.saveTheme(_providerId, currentThemeId);
  }

  /// Returns the list of all themes.
  List<AppTheme> get allThemes => _appThemes;

  /// Returns whether there is a theme with the given id.
  bool hasTheme(String themeId) {
    return _appThemes.any((e) => e.id == themeId);
  }

  /// Adds the given theme dynamically.
  ///
  /// The theme will get the index as the last theme.
  /// If this fails(possibly already existing theme id), throws an [Exception].
  void addTheme(AppTheme newTheme) {
    if (hasTheme(newTheme.id)) {
      throw Exception('${newTheme.id} is already being used as a theme.');
    }
    _appThemes.add(newTheme);
    notifyListeners();
  }

  /// Removes the theme with the given id dynamically.
  ///
  /// If this fails(possibly non existing theme id), throws an error.
  void removeTheme(String themeId) {
    if (currentThemeId == themeId) {
      throw Exception('$themeId is set as current theme.');
    }
    var appThemesLength = _appThemes.length;
    _appThemes.removeWhere((e) => e.id == themeId);
    if (appThemesLength == _appThemes.length) {
      throw Exception('$themeId does not exist.');
    }
    notifyListeners();
  }

  /// Removes last saved theme configuration.
  Future<void> forgetSavedTheme() async {
    await _saveAdapter.forgetTheme(providerId);
  }

  static void _defaultOnThemeChanged(AppTheme oldTheme, AppTheme newTheme) {}
}

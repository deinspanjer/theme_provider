import 'package:flutter/material.dart';

import '../../theme_provider.dart';

/// Enumeration of the different types of ThemeData that might be available
/// in the AppTheme object
enum AppThemeDataType { light, dark, highContrastLight, highContrastDark }

///  Main App theme object.
///
/// Usage:
/// ```dart
///  AppTheme<MyOptionClass>(
///     id: 'my_custom_theme',
///     data: ThemeData.from(
///       colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
///     ),
///     options: MyOptionClass(),
///   ),
/// ```
@immutable
class AppTheme {
  final ThemeData _data;

  /// Active [ThemeData] associated with the [AppTheme]
  ThemeData get data {
    final ThemeMode mode = widget.themeMode ?? ThemeMode.system;
    final Brightness platformBrightness = MediaQuery.platformBrightnessOf(context);
    final bool useDarkTheme = mode == ThemeMode.dark
        || (mode == ThemeMode.system && platformBrightness == ui.Brightness.dark);
    final bool highContrast = MediaQuery.highContrastOf(context);
    ThemeData? theme;

    if (useDarkTheme && highContrast && widget.highContrastDarkTheme != null) {
      theme = widget.highContrastDarkTheme;
    } else if (useDarkTheme && widget.darkTheme != null) {
      theme = widget.darkTheme;
    } else if (highContrast && widget.highContrastTheme != null) {
      theme = widget.highContrastTheme;
    }
    theme ??= widget.theme ?? ThemeData.light();
  }

  /// Light [ThemeData] associated with the [AppTheme]
  ThemeData? get light => _data;

  /// Dark [ThemeData] associated with the [AppTheme]
  ThemeData? get dark => null;

  /// High contrast light [ThemeData] associated with the [AppTheme]
  ThemeData? get highContrastLight => null;

  /// High contrast dark [ThemeData] associated with the [AppTheme]
  ThemeData? get highContrastDark => null;

  /// Passed options object. Use this object to pass
  /// additional data that should be associated with the theme.
  ///
  /// eg: If font color on a specific button changes create a class
  /// to encapsulate the value.
  /// ```dart
  /// class MyThemeOptions implements AppThemeOptions{
  ///   final Color specificButtonColor;
  ///   ThemeOptions(this.specificButtonColor);
  /// }
  /// ```
  ///
  /// Then provide the options with the theme.
  /// ```dart
  /// themes: [
  ///   AppTheme(
  ///     data: ThemeData.light(),
  ///     options: MyThemeOptions(Colors.blue),
  ///   ),
  ///   AppTheme(
  ///     data: ThemeData.dark(),
  ///     options: MyThemeOptions(Colors.red),
  ///   ),
  /// ]
  /// ```
  ///
  /// Then the option can be retrieved as
  /// `ThemeProvider.optionsOf<MyThemeOptions>(context).specificButtonColor`.
  final AppThemeOptions? options;

  /// Unique ID which defines the theme.
  /// Don't use conflicting strings.
  ///
  /// This has to be a lowercase string separated by underscores. (can contain numbers)
  ///   * theme_1
  ///   * my_theme
  ///   * dark_extended_theme
  ///
  /// Don't use very lengthy strings.
  /// Instead use [description] as the field to add description.
  final String id;

  /// Short description which describes the theme. Must be less than 30 characters.
  final String description;

  /// Constructs a [AppTheme].
  /// [data] is required.
  ///
  /// [id] is required and it has to be unique.
  /// Use _ separated lowercase strings.
  /// Id cannot have spaces.
  ///
  /// [options] can ba any object. Use it to pass
  ///
  /// [description] is required and it is a human friendly name for the AppTheme. Must be less than 30 characters.
  AppTheme({
    required this.id,
    required data,
    required this.description,
    this.options,
  }) : this._data = data {
    assert(description.length < 30, "Theme description too long ($id)");
    assert(id.isNotEmpty, "Id cannot be empty");
    assert(id.toLowerCase() == id, "Id has to be a lowercase string");
    assert(!id.contains(" "), "Id cannot contain spaces. (Use _ for spaces)");
  }

  /// Default light theme
  factory AppTheme.light({String? id}) {
    return AppTheme(
      data: ThemeData.light(),
      id: id ?? "default_light_theme",
      description: "Default Light Theme",
    );
  }

  /// Default dark theme
  factory AppTheme.dark({String? id}) {
    return AppTheme(
      data: ThemeData.dark(),
      id: id ?? "default_dark_theme",
      description: "Default Dark Theme",
    );
  }

  /// Additional purple theme constructor
  factory AppTheme.purple({String? id}) {
    return AppTheme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.purple,
        accentColor: Colors.pink,
      ),
      id: id ?? "default_purple_theme",
      description: "Custom Default Purple Theme",
    );
  }

  /// Creates a copy of this [AppTheme] but with the given fields replaced with the new values.
  /// Id will be replaced by the given [id].
  AppTheme copyWith({
    required String id,
    String? description,
    ThemeData? data,
    AppThemeOptions? options,
  }) {
    return AppTheme(
      id: id,
      description: description ?? this.description,
      data: data ?? this.data,
      options: options ?? this.options,
    );
  }

  /// Identity of [AppTheme] is based on its id field.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppTheme && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

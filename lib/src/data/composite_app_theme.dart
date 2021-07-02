import 'package:flutter/material.dart';

import '../../theme_provider.dart';

///  Composite App Theme object.
///  Allows the developer to specify up to four variants of a theme:
///  * Light (fallback default)
///  * Dark
///  * High Contrast Light
///  * High Contrast Dark
///
/// If multiple theme variants are specified, the [ThemeMode] property of [MaterialApp]
/// determines whether a light or dark theme brightness will be used. If [ThemeMode.system]
/// is specified (the default) then the appropriate theme will be selected based
/// on the brightness preference indicated by the platform via [MediaQuery.platformBrightnessOf].
/// If the platform supports the high contrast text accessibility feature (Currently only iOS)
/// then the appropriate high contrast theme data will be used if specified.
///
/// Usage:
/// ```dart
///  CompositeAppTheme(
///    id: id ?? "baseline_material_theme",
///    description: "Baseline Material Theme",
///    lightData: ThemeData.from(colorScheme: ColorScheme.light()),
///    darkData: ThemeData.from(colorScheme: ColorScheme.dark()),
///    lightHighContrastData: ThemeData.from(colorScheme: ColorScheme.highContrastLight()),
///    darkHighContrastData: ThemeData.from(colorScheme: ColorScheme.highContrastDark()),
///  )
///  CompositeAppTheme<MyOptionClass>(
///    id: 'my_custom_composite_theme',
///    lightData: ThemeData.from(
///      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
///    ),
///    darkData: ThemeData.from(
///      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo),
///    ),
///    highContrastDarkData: ThemeData.from(
///      colorScheme: ColorScheme.highContrastDark(),
///    ),
///    options: MyOptionClass(),
///   ),
/// ```
@immutable
class CompositeAppTheme extends AppTheme {
  /// light [ThemeData] associated with the [CompositeAppTheme]
  /// This is the default if the system tries to select another ThemeData
  /// from the [MaterialApp] properties and it is null.
  final ThemeData? lightData;

  /// light high-contrast [ThemeData] associated with the [CompositeAppTheme]
  /// This data is used if the system requests a high-contrast light theme.
  final ThemeData? highContrastLightData;

  /// dark [ThemeData] associated with the [CompositeAppTheme]
  /// This data is used if the system requests a dark theme.
  /// If it is requested and the property is null, [MaterialApp] will
  /// default to the `theme` property which is populated by the [CompositeAppTheme] `lightData` property.
  final ThemeData? darkData;

  /// dark high-contrast [ThemeData] associated with the [CompositeAppTheme]
  /// This data is used if the system requests a high-contrast dark theme.
  /// If it is requested and the property is null, [MaterialApp] will
  /// default to the `darkTheme` property which is populated by the [CompositeAppTheme] `darkData` property.
  final ThemeData? highContrastDarkData;

  /// Constructs a [CompositeAppTheme] which is a subclass of [AppTheme].
  /// At least [lightData] or [darkData] must be provided.
  CompositeAppTheme(
      {required String id,
      required String description,
      AppThemeOptions? options,
      this.lightData,
      this.highContrastLightData,
      this.darkData,
      this.highContrastDarkData})
      : super(id: id, description: description, data: ThemeData.fallback()) {
    assert(this.lightData != null || this.darkData != null, "At least lightData or darkData must be provided.");
  }

  /// Default light theme
  factory CompositeAppTheme.baselineMaterial({String? id}) {
    return CompositeAppTheme(
      id: id ?? "baseline_material_theme",
      description: "Baseline Material Theme",
      lightData: ThemeData.from(colorScheme: ColorScheme.light()),
      darkData: ThemeData.from(colorScheme: ColorScheme.dark()),
      highContrastLightData: ThemeData.from(colorScheme: ColorScheme.highContrastLight()),
      highContrastDarkData: ThemeData.from(colorScheme: ColorScheme.highContrastDark()),
    );
  }
}

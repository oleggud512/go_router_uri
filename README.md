# go_router_uri

## Overview
This utility provides a structured and type-safe way to define, register, and navigate app routes using [`go_router`](https://pub.dev/packages/go_router).  
It eliminates string-based route management by introducing hierarchical, composable route classes that mirror your app’s navigation tree.

---

## ✨ Key Features
- **Type-safe route composition:** Build routes using nested `AppSubPath` classes instead of manual string concatenation.  
- **Centralized route registry:** Define all routes and parameters in one place (`AppUri`).  
- **Easy navigation:** Generate full paths programmatically (e.g., `AppUri.root.texts.textId('42').edit.path`).  
- **Predictable structure:** Your route definitions mirror your UI’s navigation hierarchy.  

---

## 🧩 Example Route Definition

```dart
import 'package:my_util_package/my_util_package.dart';

const _texts = 'texts';
const _add = 'add';
const _textId = 'textId';
const _edit = 'edit';
const _settings = 'settings';

class AppUri extends RootSubPath {
  AppUri._() {
    register(LeafSubPath.new);
    register(TextsSubPath.new);
    register(TextSubPath.new);
  }

  late final texts = route<TextsSubPath>(_texts);

  static final root = AppUri._();
}

class TextsSubPath extends AppSubPath<TextsSubPath> {
  TextsSubPath(super.parent);

  late final add = leafRoute(_add);
  late final settings = leafRoute(_settings);
  late final textId = param<TextSubPath>(_textId);
}

class TextSubPath extends AppSubPath<TextSubPath> {
  TextSubPath(super.parent);
  late final edit = leafRoute(_edit);
}
```

This structure defines a nested hierarchy of routes such as:
```
/texts
/texts/add
/texts/settings
/texts/:textId
/texts/:textId/edit
```

---

## 🚦 Example Router Configuration

```dart
class MyRouter {
  const MyRouter._();

  static GoRouter router = _createRouter();

  static GoRouter _createRouter() {
    return GoRouter(
      initialLocation: AppUri.root.texts.path,
      routes: [
        GoRoute(
          path: AppUri.root.texts.path,
          builder: (context, state) => TextsListScreen(),
          routes: [
            GoRoute(
              path: AppUri.root.texts.br.settings.path,
              builder: (context, state) => SettingsScreen(),
            ),
            GoRoute(
              path: AppUri.root.texts.br.add.path,
              builder: (context, state) => TextAddScreen(),
            ),
            GoRoute(
              path: AppUri.root.texts.br.textId().path,
              builder: (context, state) {
                final textId = int.parse(
                  state.pathParameters[AppUri.root.texts.textId.paramName]!,
                );
                return TextReaderScreen(textId: textId);
              },
            ),
            GoRoute(
              path: AppUri.root.texts.br.textId().edit.path,
              builder: (context, state) {
                final textId = int.parse(
                  state.pathParameters[AppUri.root.texts.textId.paramName]!,
                );
                return TextEditScreen(textId: textId);
              },
            ),
          ],
        ),
      ],
    );
  }
}
```

---

## 🧭 Navigation Example

Navigate using the structured API instead of string paths:

```dart
context.go(
  AppUri.root.texts.textId(text.id.toString()).edit.path,
);
```

This generates and navigates to:
```
/texts/42/edit
```
automatically resolving all segments and parameters.

---

## ⚙️ Benefits in Large Apps
- **Refactoring safety:** Renaming or reordering routes doesn’t break navigation calls.  
- **Autocomplete support:** IDEs provide code completion for route segments.  
- **Parameter validation:** Parameters are typed and easy to track.  
- **Simplified deep linking:** Route trees reflect your URI structure directly.

---



---

## 🛠️ TODOs / Future Improvements
- **Remove dependency on `get_it`** to simplify setup and reduce external dependencies.  
- **Eliminate the need to register `LeafSubPath` manually** each time — automate this registration in the base classes.

# Implementation Plan: Polishing, Bug Fixes & Level Improvements

This plan outlines the fixes and improvements requested for the game's UI, audio behavior, translations, and level design.

## User Review Required
> [!IMPORTANT]  
> Please review the plan below. I will update the level generation script to create larger, more professional levels with better obstacles and puzzles. Once you approve, I will execute these changes immediately.

## Proposed Changes

---

### 1. Arrow Direction Fix for Arabic (RTL)
#### [MODIFY] `lib/utils/command_ui_extension.dart`
- Currently, standard material arrows flip automatically in RTL mode (Arabic). Since our grid directions are **absolute**, moving "Right" should always point East.
- I will enforce absolute icons (`Icons.east`, `Icons.west`, etc.) and ensure `matchTextDirection` is disabled so the arrows never flip.

### 2. Hide Text on Selected Commands
#### [MODIFY] `lib/presentation/screens/game/game_screen.dart`
- Remove the text label from `_CommandChip` (the chips in the queue panel).
- Increase the size of the icon in `_CommandChip` to fill the space cleanly and make it visually appealing for kids.

### 3. Background Music Behavior
#### [MODIFY] `lib/presentation/providers/audio_provider.dart`
- Change SFX playback to reuse a single `_sfxPlayer` (or a small pool) instead of spawning a new `AudioPlayer` every time. Creating too many players causes the OS to kill the BGM player to save resources.
#### [MODIFY] `lib/main.dart`
- Inject the `audioControllerProvider` listener into the root `_AppRoot` widget so the background music starts as soon as the app opens, rather than waiting for the `GameScreen`.

### 4. World and Level Translations
#### [MODIFY] `lib/core/l10n/app_localizations.dart`
- Add translations for world titles: "Sequence" -> "التسلسل", "Mazes" -> "المتاهات", "Loops" -> "التكرار", "Conditions" -> "الشروط", "Debugging" -> "اكتشاف الأخطاء".
- Add translations for "Level %" -> "المرحلة %".
- Add translations for the snackbars: "All levels unlocked!" and "Progress reset!".
#### [MODIFY] UI Screens (`world_selection_screen.dart` & `game_screen.dart`)
- Update the UI to use the translated strings instead of the raw JSON English strings.

### 5. Android Internet Permission
#### [MODIFY] `android/app/src/main/AndroidManifest.xml`
- Add `<uses-permission android:name="android.permission.INTERNET" />` inside the `<manifest>` block.

### 6. Reset Selected Character on Progress Reset
#### [MODIFY] `lib/presentation/providers/settings_provider.dart`
- Add a `resetCharacter()` method to revert the selected character to the default robot.
#### [MODIFY] `lib/presentation/screens/settings/settings_screen.dart` & `about_screen.dart`
- When the user confirms a progress reset (or intentionally fails the cheat code), the app will now call both the progress reset and the character reset.

### 7. Level Enhancements (More Professional & Complex)
#### [MODIFY] `scratch/generate_levels.dart`
- Increase complexity by generating **30 levels per world** (up from 20).
- **World 1 (Sequence):** Gradual introduction of obstacles and longer paths.
- **World 2 (Mazes):** True labyrinth structures requiring zig-zag movements.
- **World 3 (Loops):** Puzzle designs that specifically force the use of nested logic and exact counting.
- **World 4 (Conditions):** Dynamic paths where the user *must* use conditionals to bypass potential walls.
- **World 5 (Debugging):** More subtle logical bugs (like putting an obstacle right before the goal with a wrong command) to make fixing them more rewarding.
- Re-run the script to update all JSON files in `assets/data/`.

---

## Verification Plan

1. **Static Analysis:** Run `flutter analyze` to ensure no Dart errors.
2. **Audio Verification:** Check that BGM plays on app launch and doesn't get killed by SFX.
3. **UI Verification:** Check Arabic mode to confirm arrows point in absolute directions and command text is hidden.

.DEFAULT_GOAL = buildWeb
flutter ?= flutter
dart ?= dart
package ?= com.jhubi1.calcprint

.PHONY: clean
clean:
	$(flutter) clean
	$(flutter) pub get

.PHONY: buildWeb
buildWeb:
ifeq ($(noBaking),)
	$(dart) run gitbaker
	$(flutter) gen-l10n
endif
	$(flutter) build web --release --csp --wasm

.PHONY: buildAndroid
buildAndroid:
ifeq ($(noBaking),)
	$(dart) run gitbaker
	$(flutter) gen-l10n
endif
	$(flutter) build apk --release

.PHONY: buildFull
buildFull: clean buildWeb buildAndroid

# ANDROID HELPERS

.PHONY: helperAndroidDeeplink
helperAndroidDeeplink:
	adb shell pm verify-app-links --re-verify $(package)
	adb shell pm get-app-links $(package)

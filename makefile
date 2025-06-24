.DEFAULT_GOAL = buildWeb
flutter ?= flutter
package ?= com.jhubi1.calcprint

.PHONY: clean
clean:
	$(flutter) clean
	$(flutter) pub get

.PHONY: buildWeb
buildWeb:
	$(flutter) build web --release --csp --wasm

.PHONY: buildAndroid
buildAndroid:
	$(flutter) build apk --release

.PHONY: buildFull
buildFull: clean buildWeb buildAndroid

# ANDROID HELPERS

.PHONY: helperAndroidDeeplink
helperAndroidDeeplink:
	adb shell pm verify-app-links --re-verify $(package)
	adb shell pm get-app-links $(package)

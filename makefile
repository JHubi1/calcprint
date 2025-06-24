.DEFAULT_GOAL = buildWeb
flutter ?= flutter

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
	adb shell pm verify-app-links --re-verify com.jhubi1.calcprint
	adb shell pm get-app-links com.jhubi1.calcprint

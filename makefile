NAME := Ksign
PLATFORM := iphoneos
SCHEMES := Ksign
TMP := $(TMPDIR)/$(NAME)
STAGE := $(TMP)/stage
APP := $(TMP)/Build/Products/Release-$(PLATFORM)

.PHONY: all clean $(SCHEMES)

all: $(SCHEMES)

clean:
	rm -rf "$(TMP)"
	rm -rf packages
	rm -rf Payload

deps:
	rm -rf deps || true
	mkdir -p deps
	curl -fsSL "https://backloop.dev/pack.json" -o cert.json || true
	if [ -f cert.json ]; then \
		jq -r '.cert // empty' cert.json > deps/server.crt 2>/dev/null || true; \
		jq -r '(.key1 // "") + "\n" + (.key2 // "")' cert.json > deps/server.pem 2>/dev/null || true; \
		jq -r '.info.domains.commonName // "*.backloop.dev"' cert.json > deps/commonName.txt 2>/dev/null || echo "*.backloop.dev" > deps/commonName.txt; \
		rm -f cert.json; \
	else \
		touch deps/server.crt deps/server.pem; \
		echo "*.backloop.dev" > deps/commonName.txt; \
	fi

$(SCHEMES): deps
	xcodebuild \
	    -project Ksign.xcodeproj \
	    -scheme "$@" \
	    -configuration Release \
	    -arch arm64 \
	    -sdk $(PLATFORM) \
	    -derivedDataPath $(TMP) \
	    -skipPackagePluginValidation \
	    CODE_SIGNING_ALLOWED=NO \
	    ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO

	rm -rf Payload
	rm -rf "$(STAGE)/"
	mkdir -p "$(STAGE)/Payload"

	mv "$(APP)/$@.app" "$(STAGE)/Payload/$@.app"

	chmod -R 0755 "$(STAGE)/Payload/$@.app"
	codesign --force --sign - --timestamp=none "$(STAGE)/Payload/$@.app"

	cp deps/* "$(STAGE)/Payload/$@.app/" || true

	rm -rf "$(STAGE)/Payload/$@.app/_CodeSignature"
	ln -sf "$(STAGE)/Payload" Payload
	
	mkdir -p packages
	zip -r9 "packages/$@.ipa" Payload
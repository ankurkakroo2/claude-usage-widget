.PHONY: build clean run test

APP_NAME = ClaudeUsageWidget
BUNDLE_ID = com.claude.usagewidget
BUILD_DIR = .build
DERIVED_DATA = $(BUILD_DIR)/DerivedData

build:
	@echo "Building $(APP_NAME)..."
	@swift build -c release

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(DERIVED_DATA)

run: build
	@echo "Running $(APP_NAME)..."
	@.build/release/$(APP_NAME)

test:
	@echo "Running tests..."
	@swift test

install: build
	@echo "Installing $(APP_NAME)..."
	@mkdir -p ~/Applications
	@cp -r .build/release/$(APP_NAME).app ~/Applications/

help:
	@echo "Available targets:"
	@echo "  build   - Build the application"
	@echo "  clean   - Clean build artifacts"
	@echo "  run     - Build and run the application"
	@echo "  test    - Run unit tests"
	@echo "  install - Install to ~/Applications"

.PHONY: format
format:
	@swift package plugin --allow-writing-to-package-directory swiftformat

.PHONY: lint
lint:
	@swift package plugin --allow-writing-to-package-directory swiftformat --lint

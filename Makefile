.PHONY: format
format:
	@swift package plugin --allow-writing-to-package-directory swiftformat

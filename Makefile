.PHONY: test lint install coverage

# Run the RSpec test suite (Rakefile's spec task)
test:
	bundle exec rake spec

# Run RuboCop
lint:
	bundle exec rake rubocop

# Install gems into ./.bundle (matches BUNDLE_PATH from shell.nix)
install:
	bundle install

# Run the suite under SimpleCov, then print the coverage summary and the
# lowest-covered files, even if the coverage gate trips. The full per-line
# report is written to coverage/index.html.
coverage:
	@COVERAGE=1 bundle exec rake spec; status=$$?; \
	bundle exec simplecov report; \
	bundle exec simplecov uncovered; \
	exit $$status
# MoonBit Project Commands

version := `jq -r '.version' moon.mod.json`
tag := "v" + version
repo_git := `git rev-parse --git-common-dir`

# Default: check + test
default: check test

# Format code
fmt:
    moon fmt

# Check formatting (no changes applied)
fmt-check:
    moon fmt --check

# Type check
check:
    moon check --deny-warn

# Run tests
test:
    moon test

# Update snapshot tests
test-update:
    moon test --update

# Generate type definition files (.mbti)
info:
    moon info

# Clean build artifacts
clean:
    moon clean

# Run tests on all targets
test-all:
    moon test --target all

# Run benchmarks
bench:
    moon bench

# Coverage summary (runs tests with instrumentation internally)
coverage:
    moon coverage analyze -- -f summary

# Coverage HTML report (runs tests with instrumentation internally)
coverage-html:
    moon coverage analyze -- -f html

# Regenerate GCB tables from Unicode data
gen-tables:
    python3 tools/gen_gcb_table.py
    moon fmt

# Regenerate UAX #29 official tests
gen-tests:
    python3 tools/gen_uax29_tests.py
    moon fmt

# Regenerate all generated files
gen: gen-tables gen-tests

# Pre-release check
release-check: fmt-check check info test

# Release: check, tag, and push to trigger CI publish
[confirm]
release: release-check _release-preflight _release-push _release-tag
    @echo ""
    @echo "==> {{ tag }} released! CI will publish to mooncakes.io."

_release-preflight: _release-fetch _release-check-changelog _release-check-no-tag _release-check-clean

_release-fetch:
    @jj git fetch

_release-check-changelog:
    @grep -qF '## [{{ version }}]' CHANGELOG.md || { echo "ERROR: CHANGELOG.md has no entry for [{{ version }}]"; exit 1; }

_release-check-no-tag:
    @git --git-dir="{{ repo_git }}" rev-parse "refs/tags/{{ tag }}" >/dev/null 2>&1 && { echo "ERROR: Tag {{ tag }} already exists"; exit 1; } || true

_release-check-clean:
    @test "$(jj log -r @ --no-graph -T 'if(empty, "true", "false")')" = "true" || { echo "ERROR: @ has changes. Run 'jj describe -m \"...\" && jj new' first."; exit 1; }
    @test "$(jj log -r @ --no-graph -T 'if(description.first_line().len() > 0, "true", "false")')" = "false" || { echo "ERROR: @ has a description. Run 'jj new' to cut, or 'jj describe -m \"\"' to clear."; exit 1; }
    @echo "NOTE: Ensure README.md and docs/DESIGN.md are synced from their -ja.md originals."
    @echo "==> Release target for {{ tag }}:"
    @jj log -r '@-'

_release-push:
    jj bookmark set main -r @-
    jj git push --bookmark main

_release-tag:
    jj tag set "{{ tag }}" -r @-
    jj git export
    LEFTHOOK=0 GIT_WORK_TREE="{{ justfile_directory() }}" git --git-dir="{{ repo_git }}" push origin "{{ tag }}"

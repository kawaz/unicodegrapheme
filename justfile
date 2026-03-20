# MoonBit Project Commands

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
release: release-check
    #!/usr/bin/env bash
    set -euo pipefail

    # Version and tag from moon.mod.json
    version=$(jq -r '.version' moon.mod.json)
    tag="v${version}"
    echo "==> Releasing ${tag}"

    # Fetch latest remote state
    jj git fetch

    # CHANGELOG.md must have an entry for this version
    if ! grep -qF "## [${version}]" CHANGELOG.md; then
        echo "ERROR: CHANGELOG.md has no entry for [${version}]"
        exit 1
    fi

    # Tag must not already exist
    REPO_GIT=$(git rev-parse --git-common-dir)
    if git --git-dir="${REPO_GIT}" rev-parse "refs/tags/${tag}" >/dev/null 2>&1; then
        echo "ERROR: Tag ${tag} already exists"
        exit 1
    fi

    # Determine release target based on @ state
    is_empty=$(jj log -r @ --no-graph -T 'if(empty, "true", "false")')
    has_desc=$(jj log -r @ --no-graph -T 'if(description.first_line().len() > 0, "true", "false")')
    parent_count=$(jj log -r 'parents(@)' --no-graph -T '"x\n"' | wc -l | tr -d '[:space:]')

    if [ "$is_empty" = "false" ]; then
        # Pattern A: @ has changes — describe and cut
        echo "@ has uncommitted changes. Opening editor to describe this commit."
        jj describe
        jj new
    elif [ "$has_desc" = "false" ] && [ "$parent_count" -le 1 ]; then
        # Pattern B1: empty, no desc, single parent — already new'd, @- is ready
        :
    elif [ "$has_desc" = "false" ]; then
        # Pattern B2: merge commit without description — describe and cut
        echo "@ is a merge commit without description. Opening editor to describe."
        jj describe
        jj new
    else
        # Pattern C: empty with description — ambiguous, ask user
        echo "@ is empty but has a description:"
        jj log -r '@-::@'
        echo ""
        echo "  [1] @ is the release commit (will cut with jj new)"
        echo "  [2] @- is the release commit (@ is a leftover working change)"
        read -rp "Which? [1/2]: " choice
        case "$choice" in
            1) jj new ;;
            2) ;;
            *) echo "Aborted."; exit 1 ;;
        esac
    fi

    target="@-"

    # Doc sync reminder
    echo ""
    echo "NOTE: Ensure README.md and docs/DESIGN.md are synced from their -ja.md originals."
    echo ""

    # Show target and confirm
    echo "==> Release target for ${tag}:"
    jj log -r "${target}"
    echo ""
    read -rp "Proceed with release? [y/N] " confirm
    [[ "$confirm" =~ ^[yY]$ ]] || { echo "Aborted."; exit 1; }

    # Push bookmark
    jj bookmark set main -r "${target}"
    jj git push --bookmark main

    # Tag and push (jj cannot push tags yet, use git)
    jj tag set "${tag}" -r "${target}"
    jj git export
    git --git-dir="${REPO_GIT}" push origin "${tag}"

    echo ""
    echo "==> ${tag} released! CI will publish to mooncakes.io."

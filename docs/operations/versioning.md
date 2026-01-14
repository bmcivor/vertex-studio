# Versioning

This project uses [bump2version](https://github.com/c4urself/bump2version) for semantic versioning.

## Version Format

Follows semantic versioning: `MAJOR.MINOR.PATCH`

- **PATCH** - Bug fixes, minor changes
- **MINOR** - New features, backwards compatible
- **MAJOR** - Breaking changes

## Usage

Bump the version using make targets:

```bash
# Patch: 0.1.0 -> 0.1.1
make bump-patch

# Minor: 0.1.0 -> 0.2.0
make bump-minor

# Major: 0.1.0 -> 1.0.0
make bump-major
```

## What Happens

When you run a bump command:

1. Version updated in `pyproject.toml`
2. Git commit created with message "Bump version: X.X.X → Y.Y.Y"
3. Git tag created: `vY.Y.Y`

## Current Version

Check current version:

```bash
grep version pyproject.toml
```

Or check git tags:

```bash
git tag --list 'v*'
```

## Configuration

Versioning is configured in `.bumpversion.cfg`.

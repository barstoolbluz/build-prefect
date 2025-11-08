# Prefect Build from PyPI with Flox

This repository builds the Prefect workflow orchestration platform using **Flox Nix Expression Builds**. It provides a reproducible build of Prefect for Nix and Flox users.

## Overview

This provides **two ways** to build and use Prefect:

### Option 1: Nix Flake (for Nix users)
- Use `nix build`, `nix run`, `nix develop` directly
- No Flox required
- Standard Nix flake interface
- Perfect for integrating into existing Nix workflows

### Option 2: Flox Environment (for Flox users)
- Use Flox's **§10 Nix Expression Builds** feature
- Build, publish, and share via Flox Catalog
- Composable with other Flox environments

## Structure

```
prefect-build/
├── flake.nix                   # Nix flake interface
├── flake.lock                  # Locked flake inputs
├── default.nix                 # Backward compatibility for non-flake users
├── .flox/
│   ├── env/
│   │   └── manifest.toml       # Flox environment definition
│   └── pkgs/
│       └── prefect.nix         # Nix expression building Prefect
└── README.md                   # This file
```

**Note**: We use a **PyPI wheel-based build** (UI pre-included) which is simpler and faster than building from source.

## Quick Start

### Option A: Using the Nix Flake

For Nix users without Flox:

#### 1. Build the Package

```bash
cd prefect-build

# Build Prefect (uses Nix cache if available)
nix build .#prefect

# Or use without experimental features flag (if flakes enabled globally)
nix build
```

#### 2. Run Prefect CLI Directly

```bash
# Run main prefect CLI
nix run .#prefect -- --version

# Run prefect server
nix run .#prefect-server -- server start --help
```

#### 3. Enter Development Shell

```bash
# Enter shell with Prefect available
nix develop

# Now you can use all Prefect commands
prefect --version
prefect server start
python -c "import prefect; print(prefect.__version__)"
```

#### 4. Use in Your Own Flake

Add to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    prefect.url = "github:yourname/prefect-build";  # Update with your repo
  };

  outputs = { self, nixpkgs, prefect }:
    let
      system = "x86_64-linux";  # or your system
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          prefect.packages.${system}.prefect
        ];
      };
    };
}
```

#### 5. Non-Flake Usage

For users without flakes enabled:

```bash
# Build with legacy nix-build
nix-build

# Result symlink points to Prefect
./result/bin/prefect --version
```

### Option B: Using Flox

For Flox users:

#### 1. Build the Package

```bash
cd prefect-build

# Build Prefect package
flox build
```

#### 2. Activate and Use

```bash
# Activate environment
flox activate

# Check Prefect installation
python -c "import prefect; print(prefect.__version__)"
```

#### 3. Publish to Catalog

```bash
# First time: authenticate
flox auth login

# Publish to your personal catalog
flox publish

# Packages will be available as:
# - your-handle/prefect
```

## Updating to Different Versions

**Current Version:** Prefect 3.1.7

To build a different version:

1. **Edit `.flox/pkgs/prefect.nix`** - Change version:
   ```nix
   version = "X.Y.Z";  # Update to desired version
   hash = "";          # Clear hash
   ```

2. **Get correct hash**:
   ```bash
   # For Nix users:
   nix build .#prefect  # Error shows correct hash
   # Update hash in prefect.nix

   # For Flox users:
   flox build  # Error shows correct hash
   # Update hash in prefect.nix
   ```

3. **Test the build**:
   ```bash
   # Nix:
   nix run .#prefect -- --version

   # Flox:
   flox activate -- prefect --version
   ```

## How It Works

**PyPI Wheel-Based Build:**

This build fetches the pre-built Prefect wheel from PyPI, which includes:
- Complete Prefect Python package
- **Pre-built web UI** (no Node.js build needed!)
- All server components
- Worker capabilities
- CLI tools

**Advantages over source build:**
- ✅ Faster builds (no UI compilation)
- ✅ No Node.js dependency
- ✅ More reliable (no build failures from UI)
- ✅ Simpler Nix expression

**Dependencies included:**
- ~70 Python packages (asyncpg, fastapi, sqlalchemy, etc.)
- C libraries (cryptography requires OpenSSL, asyncpg requires PostgreSQL headers)
- Build tools (gcc, gcc-unwrapped for C extensions)

## Package Components

**Main Prefect Package:**
- Prefect server (API + scheduler + UI)
- Prefect worker (flow execution)
- Prefect CLI (management commands)
- Database support (SQLite + PostgreSQL)
- Work pool support (Process, Docker, Kubernetes, Serverless)

**Available Commands:**
```bash
prefect --version           # Show version
prefect server start        # Start Prefect server + UI
prefect worker start        # Start worker
prefect deploy              # Deploy flows
prefect profile use <name>  # Switch profiles (dev/staging/prod)
```

## Supported Platforms

- ✅ x86_64-linux
- ✅ aarch64-linux
- ✅ x86_64-darwin (macOS Intel)
- ✅ aarch64-darwin (macOS Apple Silicon)

## Dependencies

### Python Dependencies (~70 packages)

**Core:**
- Python 3.12
- fastapi, uvicorn (web framework)
- sqlalchemy, alembic (database)
- asyncpg (PostgreSQL), aiosqlite (SQLite)
- pydantic (data validation)
- httpx (HTTP client)

**C Extension Dependencies:**
- cryptography (requires OpenSSL)
- asyncpg (requires PostgreSQL client libraries)
- psycopg2 (optional, for sync PostgreSQL)

### Build Dependencies

Included in manifest:
- gcc (C compiler for building extensions)
- gcc-unwrapped (provides libstdc++)
- python312 (Python runtime)

## Troubleshooting

### Hash Mismatch Error

```
error: hash mismatch in fixed-output derivation
```

**Solution**: Leave `hash = "";` in prefect.nix, run build, copy the hash from the error message, and update the file.

### Missing Python Dependencies

```
ModuleNotFoundError: No module named 'xyz'
```

**Solution**: Add the missing package to `propagatedBuildInputs` in `.flox/pkgs/prefect.nix`.

### Build Takes Forever

The first build fetches and compiles everything. Subsequent builds are cached.

**For Nix users:** Use `nix build -L` for live build logs
**For Flox users:** Use `flox build -v` for verbose output

## Maintenance Workflow

### Updating to a New Prefect Version

```bash
# 1. Check for new Prefect releases
#    https://github.com/PrefectHQ/prefect/releases
#    or https://pypi.org/project/prefect/

# 2. Edit .flox/pkgs/prefect.nix
#    Update version and clear hash

# 3. Get correct hash
nix build .#prefect  # or: flox build
# Copy hash from error, update prefect.nix

# 4. Build and test
nix build .#prefect  # or: flox build
nix run .#prefect -- --version  # or: flox activate -- prefect --version

# 5. Commit and publish
git add .flox/pkgs/prefect.nix
git commit -m "Update Prefect to X.Y.Z"
git push

# For Flox users:
flox publish
```

## Using Published Packages

After publishing, anyone can use your package:

```bash
# In any Flox environment
flox install your-handle/prefect

# Or in manifest.toml
[install]
prefect.pkg-path = "your-handle/prefect"
```

## Benefits of This Approach

✅ **No Fork Required** - Fetches directly from PyPI
✅ **Version Control** - Track exactly which version you're using
✅ **Reproducible** - Same inputs = same outputs
✅ **Shareable** - Publish for team or personal use
✅ **Maintainable** - Update version and rebuild
✅ **Composable** - Mix with other Flox environments
✅ **UI Included** - No separate Node.js build needed

## Comparison with Dagster Build

| Aspect | Dagster | Prefect |
|--------|---------|---------|
| **Package count** | 6 packages | **1 package** |
| **Source** | 5 from GitHub + 1 from PyPI | **1 from PyPI** |
| **UI build** | Fetched from PyPI (pre-built) | **Fetched from PyPI (pre-built)** |
| **Nix expression complexity** | Complex (symlinkJoin, 6 builds) | **Simple (single buildPythonPackage)** |
| **Build time** | Longer (multiple packages) | **Faster (single package)** |

**Prefect is simpler!**

## Next Steps

### For Local Development

See the companion `prefect-dev` environment (if available) which includes:
- Full Prefect installation
- PostgreSQL 16 server
- Redis (optional)
- Helper scripts for starting/stopping services

### For Production Deployment

Consider these patterns:
- **Kubernetes**: Use Prefect Helm charts with this package
- **Docker**: Build worker images using this Nix expression
- **Prefect Cloud**: Use cloud-hosted server with self-hosted workers

## Resources

- [Prefect Documentation](https://docs.prefect.io/)
- [Prefect GitHub](https://github.com/PrefectHQ/prefect)
- [Flox Documentation](https://flox.dev/docs)
- [Flox Build System](https://flox.dev/docs/tutorials/building-packages/)
- [Nix Package Building](https://nixos.org/manual/nixpkgs/stable/#chap-pkgs-python)

## License

This build configuration is MIT. Prefect itself is Apache License 2.0.

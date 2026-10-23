#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
export DOTNET_ROOT="$PROJECT_ROOT/.tools/dotnet"
export DOTNET_CLI_HOME="$PROJECT_ROOT/.tools/dotnet-home"
export NUGET_PACKAGES="$PROJECT_ROOT/.tools/nuget"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1
if [[ ! -x "$DOTNET_ROOT/dotnet" ]]; then
    echo 'Run python3 tools/bootstrap.py first.' >&2
    exit 1
fi
IMAGE_PYTHON="$PROJECT_ROOT/.tools/python/bin/python"
if [[ ! -x "$IMAGE_PYTHON" ]]; then
    echo 'Run python3 tools/bootstrap.py to prepare the pinned image environment first.' >&2
    exit 1
fi
"$IMAGE_PYTHON" tools/prepare_assets.py
"$IMAGE_PYTHON" tools/bake_character.py
"$IMAGE_PYTHON" tools/validate_character.py --update-development-manifest
"$IMAGE_PYTHON" -m unittest discover -s tests -p 'test_*.py'
"$DOTNET_ROOT/dotnet" run --project tests/WukongKnight.Core.Tests --configuration Release
"$DOTNET_ROOT/dotnet" build src/WukongKnight/WukongKnight.csproj --configuration Release --nologo "$@"
"$IMAGE_PYTHON" tools/package.py --checks-passed

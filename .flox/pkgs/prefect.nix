# Prefect workflow orchestration platform - PyPI wheel-based build with pre-built UI
{ python312
, python312Packages
, fetchPypi
, lib
}:

python312Packages.buildPythonPackage rec {
  pname = "prefect";
  version = "3.1.7";
  pyproject = true;

  # Fetch from PyPI (tarball includes UI assets)
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eEuyFs00Kun/tl8CBYbRAMIFm5PfO/w+caMnAXlP7t4=";
  };

  # Build system
  build-system = with python312Packages; [
    setuptools
    wheel
  ];

  # Runtime dependencies
  propagatedBuildInputs = with python312Packages; [
    # Core async/concurrency
    anyio
    asgi-lifespan
    asyncpg  # PostgreSQL async driver (requires C)

    # Web framework
    fastapi
    httpcore
    httpx
    starlette
    uvicorn
    websockets

    # Database & ORM
    alembic
    sqlalchemy
    aiosqlite

    # Data validation & serialization
    pydantic
    pydantic-settings
    pydantic-extra-types
    orjson
    jsonschema
    jsonpatch

    # CLI & UI
    click
    typer
    rich
    readchar

    # Scheduling & time
    croniter
    pendulum
    python-dateutil
    python-slugify
    dateparser
    pytz

    # Serialization & packaging
    cloudpickle
    packaging
    toml
    pyyaml
    ruamel-yaml

    # Kubernetes & Docker integration
    docker
    kubernetes

    # Utilities
    apprise
    cachetools
    coolname
    fsspec
    graphene
    graphviz
    griffe
    humanize
    jinja2
    jinja2-humanize-extension
    opentelemetry-api
    pathspec
    prometheus-client
    python-socks
    rfc3339-validator
    typing-extensions
    ujson

    # Cryptography (requires C/OpenSSL)
    cryptography

    # Optional but commonly used
    exceptiongroup
    psycopg2  # PostgreSQL synchronous driver
  ];

  # Skip tests during build (requires server setup)
  doCheck = false;

  # Disable strict runtime dependency checking due to nixpkgs version mismatches
  # Prefect specifies upper bounds that are too restrictive for nixpkgs
  dontCheckRuntimeDeps = true;

  pythonImportsCheck = [ "prefect" ];

  meta = with lib; {
    description = "Workflow orchestration framework for building resilient data pipelines";
    longDescription = ''
      Prefect is a modern workflow orchestration tool for building, observing,
      and reacting to data pipelines. This build includes:

      - Complete Prefect platform (server, workers, CLI)
      - Pre-built web UI (included in PyPI wheel)
      - PostgreSQL and SQLite database support
      - Kubernetes and Docker work pool support
      - Full async/await support for Python 3.10+

      Provides CLI commands: prefect, prefect server, prefect worker
    '';
    homepage = "https://www.prefect.io/";
    changelog = "https://github.com/PrefectHQ/prefect/releases/tag/${version}";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.unix;
  };
}

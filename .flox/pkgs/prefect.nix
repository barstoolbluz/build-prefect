# Prefect workflow orchestration platform - PyPI wheel-based build with pre-built UI
{ python312
, python312Packages
, fetchPypi
, lib
}:

python312Packages.buildPythonPackage rec {
  pname = "prefect";
  version = "3.1.7";
  format = "wheel";

  # Fetch pre-built wheel from PyPI (includes UI assets)
  src = fetchPypi {
    inherit pname version;
    dist = "py3";
    python = "py3";
    hash = "";  # Will get from build error
  };

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
    coolname
    fsspec
    graphene
    griffe
    jinja2
    pathspec
    typing-extensions

    # Cryptography (requires C/OpenSSL)
    cryptography

    # Optional but commonly used
    psycopg2  # PostgreSQL synchronous driver
  ];

  # Skip tests during build (requires server setup)
  doCheck = false;

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

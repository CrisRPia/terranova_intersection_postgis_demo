# Start from the official image
FROM postgis/postgis:16-3.4

# Install the PostGIS client tools (shp2pgsql)
# We switch to root to install, then drop back to the default behavior
USER root
RUN apt-get update \
    && apt-get install -y postgis \
    && rm -rf /var/lib/apt/lists/*

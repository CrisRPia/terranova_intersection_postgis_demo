#!/usr/bin/env bash
set -e

# Configuration
SHP_PATH="/data/uruguay.shp" # Path inside the container
TABLE_NAME="uruguay_soils"
DB_USER="$POSTGRES_USER"
DB_NAME="$POSTGRES_DB"

echo "Checking for shapefile at $SHP_PATH..."

if [ -f "$SHP_PATH" ]; then
    echo "Shapefile found. Importing..."

    # 1. Run shp2pgsql
    # -I: Create spatial index
    # -s 32721: Force SRID to Uruguay UTM 21S (Change to 4326 if Lat/Lon)
    # -g geometry: Rename the geometry column to 'geometry'
    # -D: Use dump format (faster imports)
    shp2pgsql -I -s 32721 -g geometry -D "$SHP_PATH" public.$TABLE_NAME | psql -U "$DB_USER" -d "$DB_NAME"

    # 2. Modify the table to use UUID Primary Key
    echo "Converting ID to UUID..."
    psql -v ON_ERROR_STOP=1 --username "$DB_USER" --dbname "$DB_NAME" <<-EOSQL
        -- Add new UUID column
        ALTER TABLE $TABLE_NAME ADD COLUMN id UUID DEFAULT gen_random_uuid() NOT NULL;
        
        -- Remove old Primary Key (gid)
        ALTER TABLE $TABLE_NAME DROP CONSTRAINT IF EXISTS ${TABLE_NAME}_pkey;
        ALTER TABLE $TABLE_NAME DROP COLUMN gid;

        -- Set UUID as new Primary Key
        ALTER TABLE $TABLE_NAME ADD PRIMARY KEY (id);
EOSQL

    echo "Import finished successfully!"
else
    echo "No shapefile found. Skipping import."
fi

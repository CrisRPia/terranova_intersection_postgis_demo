#!/usr/bin/env bash

set -e

# 1. Import RED Band (Band 04)
# -I: Create Index, -C: Add Constraints (vital for speed), -M: Vacuum
# -t 100x100: Tile the image into small 100x100 pixel chunks (makes queries fast)
raster2pgsql -I -C -M -t 100x100 data/sentinel/GRANULE/L2A_T21HWB_A006243_20251115T134953/IMG_DATA/R60m/T21HWB_20251115T134221_B04_60m.jp2 public.band_red | psql -U myuser -d geodb

# 2. Import NIR Band (Band 08)
raster2pgsql -I -C -M -t 100x100 data/sentinel/GRANULE/L2A_T21HWB_A006243_20251115T134953/IMG_DATA/R60m/T21HWB_20251115T134221_B8A_60m.jp2 public.band_nir | psql -U myuser -d geodb

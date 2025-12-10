-- Create a new table to store the calculated NDVI raster
CREATE TABLE ndvi_layer AS
SELECT 
    -- We assume the tiles align perfectly (they do in Sentinel-2)
    r.rid,
    ST_MapAlgebra(
        r.rast, -- Red Band (Raster 1)
        n.rast, -- NIR Band (Raster 2)
        -- The Formula: (NIR - RED) / (NIR + RED)
        -- We add 0.00001 to the denominator to prevent "Divide by Zero" errors
        '([rast2] - [rast1]) / ([rast2] + [rast1] + 0.00001)::float',
        '32BF' -- Store output as 32-bit Float
    ) AS rast
FROM 
    band_red r
JOIN 
    band_nir n 
    -- Join where the tiles are the same spatial location
    ON ST_Intersects(r.rast, n.rast);

-- Add a spatial index to the new NDVI layer so we can query it fast
CREATE INDEX idx_ndvi_rast_gist ON ndvi_layer USING gist (ST_ConvexHull(rast));

WITH input_shape AS (
    SELECT ST_Transform(
        ST_GeomFromText(
            -- This is a complex polygon (defined in Lat/Lon)
            -- Points must go Counter-Clockwise and close back to the start
            'POLYGON((
              -56.15322 -34.85605,
              -56.16409 -34.86274,
              -56.15207 -34.87380,
              -56.13576 -34.86218,
              -56.14039 -34.84901,
              -56.14383 -34.85401,
              -56.15322 -34.85605
            ))',
            4326 -- Input is Lat/Lon
        ),
        32721 -- Transform to Uruguay Meters (UTM 21S)
    ) AS geom
)
SELECT
    m.*,
    -- 1. The Geometry of the overlap
    ST_Intersection(m.geometry, i.geom) AS overlap_shape,

    -- 2. Area in Square Meters
    ST_Area(ST_Intersection(m.geometry, i.geom)) AS area_sqm,

    -- 3. Percentage of the SOIL shape that is covered by your input
    (ST_Area(ST_Intersection(m.geometry, i.geom)) / ST_Area(i.geom)) * 100 AS composition_percentage

FROM
    uruguay_soils m,
    input_shape i
WHERE
    -- Filter: Only find soils that touch our complex shape
    ST_Intersects(m.geometry, i.geom);

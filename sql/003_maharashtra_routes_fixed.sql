-- Fixed Complete Maharashtra Routes Database Update (Continued)
-- All cities, routes, and stops for Maharashtra with proper duplicate handling

-- Aurangabad stops (continued)
INSERT INTO stops (name, city_id, is_active) 
SELECT 'Kranti Chowk', (SELECT id FROM cities WHERE name = 'Aurangabad' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Kranti Chowk' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Aurangabad' AND state = 'Maharashtra')
);

INSERT INTO stops (name, city_id, is_active) 
SELECT 'Railway Station', (SELECT id FROM cities WHERE name = 'Aurangabad' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Railway Station' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Aurangabad' AND state = 'Maharashtra')
);

-- Nagpur stops
INSERT INTO stops (name, city_id, is_active) 
SELECT 'Nagpur Central', (SELECT id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Nagpur Central' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra')
);

INSERT INTO stops (name, city_id, is_active) 
SELECT 'Itwari', (SELECT id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Itwari' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra')
);

INSERT INTO stops (name, city_id, is_active) 
SELECT 'Sitabuldi', (SELECT id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Sitabuldi' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra')
);

-- Kolhapur stops
INSERT INTO stops (name, city_id, is_active) 
SELECT 'Kolhapur Central', (SELECT id FROM cities WHERE name = 'Kolhapur' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Kolhapur Central' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Kolhapur' AND state = 'Maharashtra')
);

INSERT INTO stops (name, city_id, is_active) 
SELECT 'Station Road', (SELECT id FROM cities WHERE name = 'Kolhapur' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Station Road' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Kolhapur' AND state = 'Maharashtra')
);

-- Thane stops
INSERT INTO stops (name, city_id, is_active) 
SELECT 'Thane Station', (SELECT id FROM cities WHERE name = 'Thane' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Thane Station' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Thane' AND state = 'Maharashtra')
);

INSERT INTO stops (name, city_id, is_active) 
SELECT 'Thane Bus Depot', (SELECT id FROM cities WHERE name = 'Thane' AND state = 'Maharashtra'), true 
WHERE NOT EXISTS (
    SELECT 1 FROM stops 
    WHERE name = 'Thane Bus Depot' 
    AND city_id = (SELECT id FROM cities WHERE name = 'Thane' AND state = 'Maharashtra')
);

-- Add default stops for all cities that don't have specific stops yet
-- Bus Stand for every city
INSERT INTO stops (name, city_id, is_active)
SELECT c.name || ' Bus Stand', c.id, true
FROM cities c
WHERE c.state = 'Maharashtra'
  AND NOT EXISTS (
    SELECT 1 FROM stops s WHERE s.city_id = c.id AND s.name = c.name || ' Bus Stand'
  );

-- Railway Station for major cities (but handle the duplicate error)
INSERT INTO stops (name, city_id, is_active)
SELECT c.name || ' Railway Station', c.id, true
FROM cities c
WHERE c.state = 'Maharashtra'
  AND c.name IN ('Solapur', 'Satara', 'Ahmednagar', 'Jalgaon', 'Sangli', 'Akola', 'Dhule', 'Nanded', 'Latur', 'Amravati')
  AND NOT EXISTS (
    SELECT 1 FROM stops s WHERE s.city_id = c.id AND s.name = c.name || ' Railway Station'
  );

-- Add route-stop relationships for key routes
-- Mumbai → Pune Express stops
INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Mumbai → Pune Express'),
    (SELECT id FROM stops WHERE name = 'Dadar' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra')),
    'Dadar',
    1
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Mumbai → Pune Express') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Dadar' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra'))
);

INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Mumbai → Pune Express'),
    (SELECT id FROM stops WHERE name = 'Kurla' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra')),
    'Kurla',
    2
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Mumbai → Pune Express') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Kurla' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra'))
);

INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Mumbai → Pune Express'),
    (SELECT id FROM stops WHERE name = 'Swargate' AND city_id = (SELECT id FROM cities WHERE name = 'Pune' AND state = 'Maharashtra')),
    'Swargate',
    3
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Mumbai → Pune Express') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Swargate' AND city_id = (SELECT id FROM cities WHERE name = 'Pune' AND state = 'Maharashtra'))
);

-- Nashik → Mumbai Highway stops
INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway'),
    (SELECT id FROM stops WHERE name = 'Nashik Road' AND city_id = (SELECT id FROM cities WHERE name = 'Nashik' AND state = 'Maharashtra')),
    'Nashik Road',
    1
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Nashik Road' AND city_id = (SELECT id FROM cities WHERE name = 'Nashik' AND state = 'Maharashtra'))
);

INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway'),
    (SELECT id FROM stops WHERE name = 'Igatpuri' AND city_id = (SELECT id FROM cities WHERE name = 'Nashik' AND state = 'Maharashtra')),
    'Igatpuri',
    2
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Igatpuri' AND city_id = (SELECT id FROM cities WHERE name = 'Nashik' AND state = 'Maharashtra'))
);

INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway'),
    (SELECT id FROM stops WHERE name = 'Borivali' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra')),
    'Borivali',
    3
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Borivali' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra'))
);

INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT 
    (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway'),
    (SELECT id FROM stops WHERE name = 'Dadar' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra')),
    'Dadar',
    4
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops 
    WHERE route_id = (SELECT id FROM routes WHERE name = 'Nashik → Mumbai Highway') 
    AND stop_id = (SELECT id FROM stops WHERE name = 'Dadar' AND city_id = (SELECT id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra'))
);

-- Ensure ALL routes have at least default origin and destination stops
-- Add origin terminal stops if they don't exist
INSERT INTO stops (name, city_id, is_active)
SELECT r.origin || ' Terminal', r.from_city_id, true
FROM routes r
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops rs WHERE rs.route_id = r.id
) AND NOT EXISTS (
    SELECT 1 FROM stops s WHERE s.name = r.origin || ' Terminal' AND s.city_id = r.from_city_id
) AND r.from_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');

-- Add default origin stops to routes without any stops
INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT r.id, s.id, s.name, 1
FROM routes r
JOIN stops s ON s.city_id = r.from_city_id AND s.name = r.origin || ' Terminal'
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops rs WHERE rs.route_id = r.id
) AND r.from_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');

-- Add destination terminal stops if they don't exist
INSERT INTO stops (name, city_id, is_active)
SELECT r.destination || ' Terminal', r.to_city_id, true
FROM routes r
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops rs 
    JOIN stops st ON st.id = rs.stop_id 
    WHERE rs.route_id = r.id AND st.city_id = r.to_city_id
) AND NOT EXISTS (
    SELECT 1 FROM stops s WHERE s.name = r.destination || ' Terminal' AND s.city_id = r.to_city_id
) AND r.to_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');

-- Add destination stops to routes
INSERT INTO route_stops (route_id, stop_id, stop_name, stop_order)
SELECT r.id, s.id, s.name, 2
FROM routes r
JOIN stops s ON s.city_id = r.to_city_id AND s.name = r.destination || ' Terminal'
WHERE NOT EXISTS (
    SELECT 1 FROM route_stops rs 
    JOIN stops st ON st.id = rs.stop_id 
    WHERE rs.route_id = r.id AND st.city_id = r.to_city_id
) AND r.to_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');

-- Create indexes for better performance if they don't exist
CREATE INDEX IF NOT EXISTS idx_routes_from_to_cities ON routes(from_city_id, to_city_id);
CREATE INDEX IF NOT EXISTS idx_route_stops_route_order ON route_stops(route_id, stop_order);
CREATE INDEX IF NOT EXISTS idx_stops_city_name ON stops(city_id, name);
CREATE INDEX IF NOT EXISTS idx_cities_name_state ON cities(name, state);

-- Final summary and verification
DO $$
DECLARE
    cities_count integer;
    routes_count integer;
    stops_count integer;
    route_stops_count integer;
BEGIN
    SELECT COUNT(*) INTO cities_count FROM cities WHERE state = 'Maharashtra';
    SELECT COUNT(*) INTO routes_count FROM routes WHERE from_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');
    SELECT COUNT(*) INTO stops_count FROM stops WHERE city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');
    SELECT COUNT(*) INTO route_stops_count FROM route_stops rs JOIN routes r ON r.id = rs.route_id WHERE r.from_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra');
    
    RAISE NOTICE 'MAHARASHTRA DATA SUMMARY:';
    RAISE NOTICE '- Cities: %', cities_count;
    RAISE NOTICE '- Routes: %', routes_count;
    RAISE NOTICE '- Stops: %', stops_count;
    RAISE NOTICE '- Route-Stop connections: %', route_stops_count;
END $$;

-- Show sample routes created
SELECT 
    r.name AS route_name,
    r.distance_km || ' km' as distance,
    r.estimated_duration_minutes || ' min' as duration,
    COUNT(rs.id) AS stops_count,
    CASE 
        WHEN COUNT(rs.id) = 0 THEN 'NO STOPS - ERROR'
        ELSE 'OK'
    END as status
FROM routes r
LEFT JOIN route_stops rs ON r.id = rs.route_id
WHERE r.from_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra')
GROUP BY r.id, r.name, r.distance_km, r.estimated_duration_minutes
ORDER BY r.name
LIMIT 15;

-- Check for any routes without stops (should be 0)
SELECT 
    'Routes without stops:' as check_type,
    COUNT(*) as count
FROM routes r
WHERE r.from_city_id IN (SELECT id FROM cities WHERE state = 'Maharashtra')
  AND NOT EXISTS (SELECT 1 FROM route_stops rs WHERE rs.route_id = r.id);

-- Check for any cities without stops (should be 0)
SELECT 
    'Cities without stops:' as check_type,
    COUNT(*) as count
FROM cities c
WHERE c.state = 'Maharashtra'
  AND NOT EXISTS (SELECT 1 FROM stops s WHERE s.city_id = c.id);

COMMIT;
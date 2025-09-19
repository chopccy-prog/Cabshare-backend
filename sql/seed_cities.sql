-- SQL script to seed cities and routes data for testing
-- Run this to populate the cities table with test data

-- Insert major Indian cities if they don't exist
INSERT INTO cities (id, name, state, country, is_active, display_order) VALUES 
(gen_random_uuid(), 'Mumbai', 'Maharashtra', 'India', true, 1),
(gen_random_uuid(), 'Pune', 'Maharashtra', 'India', true, 2),
(gen_random_uuid(), 'Delhi', 'Delhi', 'India', true, 3),
(gen_random_uuid(), 'Bangalore', 'Karnataka', 'India', true, 4),
(gen_random_uuid(), 'Chennai', 'Tamil Nadu', 'India', true, 5),
(gen_random_uuid(), 'Kolkata', 'West Bengal', 'India', true, 6),
(gen_random_uuid(), 'Hyderabad', 'Telangana', 'India', true, 7),
(gen_random_uuid(), 'Ahmedabad', 'Gujarat', 'India', true, 8),
(gen_random_uuid(), 'Nashik', 'Maharashtra', 'India', true, 9),
(gen_random_uuid(), 'Nagpur', 'Maharashtra', 'India', true, 10),
(gen_random_uuid(), 'Aurangabad', 'Maharashtra', 'India', true, 11),
(gen_random_uuid(), 'Solapur', 'Maharashtra', 'India', true, 12),
(gen_random_uuid(), 'Kolhapur', 'Maharashtra', 'India', true, 13),
(gen_random_uuid(), 'Satara', 'Maharashtra', 'India', true, 14),
(gen_random_uuid(), 'Sangli', 'Maharashtra', 'India', true, 15)
ON CONFLICT (name, state) DO NOTHING;

-- Create some sample routes between major cities
DO $$ 
DECLARE
    mumbai_id uuid;
    pune_id uuid;
    delhi_id uuid;
    bangalore_id uuid;
    nashik_id uuid;
    nagpur_id uuid;
    route_id uuid;
BEGIN
    -- Get city IDs
    SELECT id INTO mumbai_id FROM cities WHERE name = 'Mumbai' AND state = 'Maharashtra' LIMIT 1;
    SELECT id INTO pune_id FROM cities WHERE name = 'Pune' AND state = 'Maharashtra' LIMIT 1;
    SELECT id INTO delhi_id FROM cities WHERE name = 'Delhi' AND state = 'Delhi' LIMIT 1;
    SELECT id INTO bangalore_id FROM cities WHERE name = 'Bangalore' AND state = 'Karnataka' LIMIT 1;
    SELECT id INTO nashik_id FROM cities WHERE name = 'Nashik' AND state = 'Maharashtra' LIMIT 1;
    SELECT id INTO nagpur_id FROM cities WHERE name = 'Nagpur' AND state = 'Maharashtra' LIMIT 1;
    
    -- Create Mumbai-Pune route
    IF mumbai_id IS NOT NULL AND pune_id IS NOT NULL THEN
        INSERT INTO routes (id, name, code, origin, destination, from_city_id, to_city_id, distance_km, estimated_duration_minutes, is_active)
        VALUES (gen_random_uuid(), 'Mumbai to Pune Express', 'MUM-PUN', 'Mumbai', 'Pune', mumbai_id, pune_id, 150, 180, true)
        ON CONFLICT DO NOTHING;
        
        -- Get the route ID for stops
        SELECT id INTO route_id FROM routes WHERE from_city_id = mumbai_id AND to_city_id = pune_id LIMIT 1;
        
        IF route_id IS NOT NULL THEN
            -- Add stops for Mumbai-Pune route
            INSERT INTO stops (id, route_id, name, address, city_name, stop_order, is_pickup, is_drop, is_active) VALUES
            (gen_random_uuid(), route_id, 'Mumbai Central Station', 'Mumbai Central Railway Station', 'Mumbai', 1, true, true, true),
            (gen_random_uuid(), route_id, 'Dadar Junction', 'Dadar Railway Station', 'Mumbai', 2, true, true, true),
            (gen_random_uuid(), route_id, 'Thane Station', 'Thane Railway Station', 'Thane', 3, true, true, true),
            (gen_random_uuid(), route_id, 'Lonavala', 'Lonavala Bus Stand', 'Lonavala', 4, true, true, true),
            (gen_random_uuid(), route_id, 'Pune Station', 'Pune Railway Station', 'Pune', 5, true, true, true),
            (gen_random_uuid(), route_id, 'Shivaji Nagar', 'Shivaji Nagar Bus Stand', 'Pune', 6, true, true, true)
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;
    
    -- Create Pune-Mumbai route (reverse)
    IF pune_id IS NOT NULL AND mumbai_id IS NOT NULL THEN
        INSERT INTO routes (id, name, code, origin, destination, from_city_id, to_city_id, distance_km, estimated_duration_minutes, is_active)
        VALUES (gen_random_uuid(), 'Pune to Mumbai Express', 'PUN-MUM', 'Pune', 'Mumbai', pune_id, mumbai_id, 150, 180, true)
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Create Mumbai-Nashik route
    IF mumbai_id IS NOT NULL AND nashik_id IS NOT NULL THEN
        INSERT INTO routes (id, name, code, origin, destination, from_city_id, to_city_id, distance_km, estimated_duration_minutes, is_active)
        VALUES (gen_random_uuid(), 'Mumbai to Nashik Highway', 'MUM-NSK', 'Mumbai', 'Nashik', mumbai_id, nashik_id, 165, 200, true)
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Create Nashik-Mumbai route (reverse)
    IF nashik_id IS NOT NULL AND mumbai_id IS NOT NULL THEN
        INSERT INTO routes (id, name, code, origin, destination, from_city_id, to_city_id, distance_km, estimated_duration_minutes, is_active)
        VALUES (gen_random_uuid(), 'Nashik to Mumbai Highway', 'NSK-MUM', 'Nashik', 'Mumbai', nashik_id, mumbai_id, 165, 200, true)
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Create Pune-Bangalore route
    IF pune_id IS NOT NULL AND bangalore_id IS NOT NULL THEN
        INSERT INTO routes (id, name, code, origin, destination, from_city_id, to_city_id, distance_km, estimated_duration_minutes, is_active)
        VALUES (gen_random_uuid(), 'Pune to Bangalore Highway', 'PUN-BLR', 'Pune', 'Bangalore', pune_id, bangalore_id, 840, 600, true)
        ON CONFLICT DO NOTHING;
    END IF;
    
END $$;

-- Verify the data
SELECT 'Cities inserted:' as info, count(*) as count FROM cities WHERE is_active = true;
SELECT 'Routes created:' as info, count(*) as count FROM routes WHERE is_active = true;
SELECT 'Stops created:' as info, count(*) as count FROM stops WHERE is_active = true;

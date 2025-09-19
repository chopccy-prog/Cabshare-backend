-- Updated schema for RedBus-style car sharing system
-- This includes cities, routes, and route stops management

-- Cities table (centralized city list)
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'India',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Routes table (specific routes between cities)
CREATE TABLE IF NOT EXISTS routes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL, -- e.g., "Via NH60 Express"
    code VARCHAR(50) UNIQUE, -- e.g., "NSK-MUM-NH60"
    from_city_id INTEGER REFERENCES cities(id) ON DELETE CASCADE,
    to_city_id INTEGER REFERENCES cities(id) ON DELETE CASCADE,
    distance_km DECIMAL(8,2),
    estimated_duration_mins INTEGER,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(from_city_id, to_city_id, code)
);

-- Route stops table (pickup/drop points for each route)
CREATE TABLE IF NOT EXISTS route_stops (
    id SERIAL PRIMARY KEY,
    route_id INTEGER REFERENCES routes(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL, -- e.g., "Deolali Camp", "Chakan MIDC"
    sequence_order INTEGER NOT NULL, -- 1, 2, 3... (order along the route)
    distance_from_start_km DECIMAL(8,2) DEFAULT 0,
    eta_from_start_mins INTEGER DEFAULT 0,
    landmark TEXT, -- Additional description
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(route_id, sequence_order),
    UNIQUE(route_id, name)
);

-- Update the rides table to include route information
ALTER TABLE rides ADD COLUMN IF NOT EXISTS route_id INTEGER REFERENCES routes(id);
ALTER TABLE rides ADD COLUMN IF NOT EXISTS selected_pickup_stops INTEGER[] DEFAULT '{}'; -- Array of route_stop IDs
ALTER TABLE rides ADD COLUMN IF NOT EXISTS selected_drop_stops INTEGER[] DEFAULT '{}'; -- Array of route_stop IDs

-- Update bookings table to include specific pickup/drop stops
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS pickup_stop_id INTEGER REFERENCES route_stops(id);
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS drop_stop_id INTEGER REFERENCES route_stops(id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_routes_cities ON routes(from_city_id, to_city_id);
CREATE INDEX IF NOT EXISTS idx_route_stops_route ON route_stops(route_id, sequence_order);
CREATE INDEX IF NOT EXISTS idx_rides_route ON rides(route_id);
CREATE INDEX IF NOT EXISTS idx_bookings_stops ON bookings(pickup_stop_id, drop_stop_id);

-- Insert sample cities
INSERT INTO cities (name, state) VALUES 
    ('Nashik', 'Maharashtra'),
    ('Pune', 'Maharashtra'),
    ('Mumbai', 'Maharashtra'),
    ('Thane', 'Maharashtra'),
    ('Aurangabad', 'Maharashtra'),
    ('Nagpur', 'Maharashtra')
ON CONFLICT (name) DO NOTHING;

-- Insert sample routes
INSERT INTO routes (name, code, from_city_id, to_city_id, distance_km, estimated_duration_mins) 
SELECT 
    'Via NH60 Express',
    'NSK-PNQ-NH60',
    (SELECT id FROM cities WHERE name = 'Nashik'),
    (SELECT id FROM cities WHERE name = 'Pune'),
    210,
    240
WHERE NOT EXISTS (SELECT 1 FROM routes WHERE code = 'NSK-PNQ-NH60');

INSERT INTO routes (name, code, from_city_id, to_city_id, distance_km, estimated_duration_mins) 
SELECT 
    'Via Expressway',
    'PNQ-MUM-EXP',
    (SELECT id FROM cities WHERE name = 'Pune'),
    (SELECT id FROM cities WHERE name = 'Mumbai'),
    150,
    180
WHERE NOT EXISTS (SELECT 1 FROM routes WHERE code = 'PNQ-MUM-EXP');

INSERT INTO routes (name, code, from_city_id, to_city_id, distance_km, estimated_duration_mins) 
SELECT 
    'Via Kalyan Route',
    'NSK-MUM-KLY',
    (SELECT id FROM cities WHERE name = 'Nashik'),
    (SELECT id FROM cities WHERE name = 'Mumbai'),
    180,
    200
WHERE NOT EXISTS (SELECT 1 FROM routes WHERE code = 'NSK-MUM-KLY');

-- Insert sample route stops for Nashik to Pune route
DO $$
DECLARE
    route_id_nsk_pnq INTEGER;
BEGIN
    SELECT id INTO route_id_nsk_pnq FROM routes WHERE code = 'NSK-PNQ-NH60';
    
    IF route_id_nsk_pnq IS NOT NULL THEN
        INSERT INTO route_stops (route_id, name, sequence_order, distance_from_start_km, eta_from_start_mins) VALUES
            (route_id_nsk_pnq, 'Nashik CBS', 1, 0, 0),
            (route_id_nsk_pnq, 'Deolali Camp', 2, 8, 15),
            (route_id_nsk_pnq, 'Ghoti', 3, 45, 60),
            (route_id_nsk_pnq, 'Manchar', 4, 95, 120),
            (route_id_nsk_pnq, 'Chakan MIDC', 5, 160, 180),
            (route_id_nsk_pnq, 'Pimpri Chinchwad', 6, 180, 200),
            (route_id_nsk_pnq, 'Pune Station', 7, 210, 240)
        ON CONFLICT (route_id, name) DO NOTHING;
    END IF;
END $$;

-- Insert sample route stops for Pune to Mumbai route
DO $$
DECLARE
    route_id_pnq_mum INTEGER;
BEGIN
    SELECT id INTO route_id_pnq_mum FROM routes WHERE code = 'PNQ-MUM-EXP';
    
    IF route_id_pnq_mum IS NOT NULL THEN
        INSERT INTO route_stops (route_id, name, sequence_order, distance_from_start_km, eta_from_start_mins) VALUES
            (route_id_pnq_mum, 'Pune Station', 1, 0, 0),
            (route_id_pnq_mum, 'Hinjewadi', 2, 25, 30),
            (route_id_pnq_mum, 'Lonavala', 3, 65, 75),
            (route_id_pnq_mum, 'Khopoli', 4, 85, 95),
            (route_id_pnq_mum, 'Panvel', 5, 120, 140),
            (route_id_pnq_mum, 'Vashi', 6, 135, 155),
            (route_id_pnq_mum, 'Mumbai CST', 7, 150, 180)
        ON CONFLICT (route_id, name) DO NOTHING;
    END IF;
END $$;

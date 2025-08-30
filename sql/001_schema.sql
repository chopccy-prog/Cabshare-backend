-- Users table (drivers, riders, agencies later)
create table if not exists profiles (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  name text,
  phone text,
  role text check (role in ('driver','rider','agency')) default 'rider',
  created_at timestamp default now()
);

-- Rides table
create table if not exists rides (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid references profiles(id),
  "from" text not null,
  "to" text not null,
  "when" timestamptz not null,
  seats int not null check (seats > 0),
  price numeric not null check (price >= 0),
  pool text check (pool in ('private','commercial','commercial_private')) default 'private',
  booked boolean default false,
  created_at timestamp default now()
);

-- Conversations
create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  title text,
  members uuid[] not null,
  last_text text,
  created_at timestamp default now()
);

-- Messages
create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id),
  sender_id uuid references profiles(id),
  text text not null,
  ts timestamptz default now()
);

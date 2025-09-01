-- sql/dump_schema.sql
-- One-shot JSON snapshot of your PUBLIC schema
-- Output: a single row, single column named "snapshot" (type jsonb)

WITH
ctx AS (
  SELECT current_database() AS database,
         current_user       AS db_user,
         current_schema()   AS search_path,
         now()              AS captured_at
),
t_tables AS (
  SELECT table_schema, table_name, table_type
  FROM information_schema.tables
  WHERE table_schema = 'public'
),
t_columns AS (
  SELECT c.table_name, c.ordinal_position, c.column_name, c.data_type,
         c.udt_name, c.character_maximum_length, c.is_nullable, c.column_default
  FROM information_schema.columns c
  WHERE c.table_schema = 'public'
),
t_constraints AS (
  SELECT conrelid::regclass::text AS table_name,
         conname AS name,
         contype,
         pg_get_constraintdef(c.oid) AS definition
  FROM pg_constraint c
  JOIN pg_namespace n ON n.oid = c.connamespace
  WHERE n.nspname='public'
),
t_indexes AS (
  SELECT tablename AS table_name, indexname AS name, indexdef AS definition
  FROM pg_indexes
  WHERE schemaname='public'
),
t_policies AS (
  SELECT schemaname, tablename AS table_name, policyname AS name,
         roles, cmd, permissive, qual, with_check
  FROM pg_policies
  WHERE schemaname='public'
),
t_triggers AS (
  SELECT c.relname AS table_name, t.tgname AS name,
         pg_get_triggerdef(t.oid) AS definition, p.proname AS function_name
  FROM pg_trigger t
  JOIN pg_class c ON c.oid = t.tgrelid
  JOIN pg_proc p ON p.oid = t.tgfoid
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname='public' AND NOT t.tgisinternal
),
t_views AS (
  SELECT table_name AS view_name, view_definition
  FROM information_schema.views
  WHERE table_schema='public'
),
t_functions AS (
  SELECT p.proname AS name,
         pg_get_function_arguments(p.oid) AS args,
         pg_get_function_result(p.oid) AS returns,
         l.lanname AS language,
         p.prokind AS kind
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid=p.pronamespace
  JOIN pg_language l ON l.oid=p.prolang
  WHERE n.nspname='public'
),
t_enums AS (
  SELECT t.typname AS enum_type, e.enumlabel AS enum_value, e.enumsortorder
  FROM pg_type t
  JOIN pg_enum e ON t.oid=e.enumtypid
  JOIN pg_namespace n ON n.oid=t.typnamespace
  WHERE n.nspname='public'
),
t_sequences AS (
  SELECT sequence_name, data_type, start_value, minimum_value,
         maximum_value, increment, cycle_option
  FROM information_schema.sequences
  WHERE sequence_schema='public'
),
t_extensions AS (
  SELECT extname AS name, extversion AS version
  FROM pg_extension
),
t_rowcounts AS (
  SELECT c.relname AS table_name, c.reltuples::bigint AS approx_rowcount
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE n.nspname='public' AND c.relkind='r'
)
SELECT jsonb_build_object(
  'context', (SELECT row_to_json(ctx) FROM ctx),
  'tables', (SELECT jsonb_agg(to_jsonb(t) ORDER BY t.table_name) FROM t_tables t),
  'columns', (SELECT jsonb_agg(to_jsonb(c) ORDER BY c.table_name, c.ordinal_position) FROM t_columns c),
  'constraints', (SELECT jsonb_agg(to_jsonb(k) ORDER BY k.table_name, k.name) FROM t_constraints k),
  'indexes', (SELECT jsonb_agg(to_jsonb(i) ORDER BY i.table_name, i.name) FROM t_indexes i),
  'policies', (SELECT jsonb_agg(to_jsonb(p) ORDER BY p.table_name, p.name) FROM t_policies p),
  'triggers', (SELECT jsonb_agg(to_jsonb(tr) ORDER BY tr.table_name, tr.name) FROM t_triggers tr),
  'views', (SELECT jsonb_agg(to_jsonb(v) ORDER BY v.view_name) FROM t_views v),
  'functions', (SELECT jsonb_agg(to_jsonb(f) ORDER BY f.name) FROM t_functions f),
  'enums', (SELECT jsonb_agg(to_jsonb(e) ORDER BY e.enum_type, e.enumsortorder) FROM t_enums e),
  'sequences', (SELECT jsonb_agg(to_jsonb(s) ORDER BY s.sequence_name) FROM t_sequences s),
  'extensions', (SELECT jsonb_agg(to_jsonb(x) ORDER BY x.name) FROM t_extensions x),
  'rowcounts', (SELECT jsonb_agg(to_jsonb(r) ORDER BY r.table_name) FROM t_rowcounts r)
) AS snapshot;

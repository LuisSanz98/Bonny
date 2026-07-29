-- Esquema para la app de control de glucemia del perro
-- Pega y ejecuta todo este archivo en Supabase: SQL Editor > New query > Run

create extension if not exists "pgcrypto";

-- Cuidadores (lista simple de nombres, sin login)
create table if not exists caregivers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

-- Lecturas de glucemia
create table if not exists glucose_readings (
  id uuid primary key default gen_random_uuid(),
  value_mgdl numeric not null,
  measured_at timestamptz not null default now(),
  caregiver_name text not null,
  notes text,
  created_at timestamptz not null default now()
);

-- Comidas e insulina
create table if not exists feedings (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('comida', 'insulina')),
  description text,
  insulin_units numeric,
  given_at timestamptz not null default now(),
  caregiver_name text not null,
  created_at timestamptz not null default now()
);

-- Notas e historial médico
create table if not exists notes (
  id uuid primary key default gen_random_uuid(),
  category text not null default 'general' check (category in ('general', 'sintoma', 'veterinario')),
  text text not null,
  caregiver_name text not null,
  created_at timestamptz not null default now()
);

-- Recordatorios habituales (horarios de comida/insulina/glucemia)
create table if not exists reminders (
  id uuid primary key default gen_random_uuid(),
  label text not null,
  time_of_day time not null,
  kind text not null check (kind in ('comida', 'insulina', 'glucemia')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Seguridad a nivel de fila.
-- Esta app no tiene login individual: cualquiera con el enlace y la clave
-- pública (anon key) puede leer y escribir. Es aceptable para un uso
-- familiar/privado, pero no trates el enlace como algo para compartir fuera
-- del circulo de cuidadores.
alter table caregivers enable row level security;
alter table glucose_readings enable row level security;
alter table feedings enable row level security;
alter table notes enable row level security;
alter table reminders enable row level security;

drop policy if exists "public all caregivers" on caregivers;
create policy "public all caregivers" on caregivers for all using (true) with check (true);

drop policy if exists "public all glucose_readings" on glucose_readings;
create policy "public all glucose_readings" on glucose_readings for all using (true) with check (true);

drop policy if exists "public all feedings" on feedings;
create policy "public all feedings" on feedings for all using (true) with check (true);

drop policy if exists "public all notes" on notes;
create policy "public all notes" on notes for all using (true) with check (true);

drop policy if exists "public all reminders" on reminders;
create policy "public all reminders" on reminders for all using (true) with check (true);

-- Activar realtime para que todos los cuidadores vean los cambios al instante
alter publication supabase_realtime add table caregivers, glucose_readings, feedings, notes, reminders;

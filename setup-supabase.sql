-- Run once in Supabase SQL Editor. Do not expose service_role keys in the website.
create table if not exists public.site_admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.site_content (
 key text primary key,
 value jsonb not null,
 updated_at timestamptz not null default now()
);
alter table public.site_admins enable row level security;
alter table public.site_content enable row level security;
-- The only admin identity information a signed-in user can read is their own row.
create policy "read own admin membership" on public.site_admins
 for select to authenticated using (user_id = (select auth.uid()));
create policy "public can read published content" on public.site_content
 for select to anon, authenticated using (true);
create policy "admins insert content" on public.site_content
 for insert to authenticated with check (exists(select 1 from public.site_admins where user_id=(select auth.uid())));
create policy "admins update content" on public.site_content
 for update to authenticated using (exists(select 1 from public.site_admins where user_id=(select auth.uid())))
 with check (exists(select 1 from public.site_admins where user_id=(select auth.uid())));
create policy "admins delete content" on public.site_content
 for delete to authenticated using (exists(select 1 from public.site_admins where user_id=(select auth.uid())));
-- Public images: upload and deletion are restricted to signed-in admins.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
 values ('imba-images','imba-images',true,10485760,array['image/jpeg','image/png','image/webp'])
 on conflict (id) do update set public=true,file_size_limit=10485760,allowed_mime_types=array['image/jpeg','image/png','image/webp'];
create policy "admins upload IMBA images" on storage.objects
 for insert to authenticated with check(bucket_id='imba-images' and exists(select 1 from public.site_admins where user_id=(select auth.uid())));
create policy "admins remove IMBA images" on storage.objects
 for delete to authenticated using(bucket_id='imba-images' and exists(select 1 from public.site_admins where user_id=(select auth.uid())));
create policy "public read IMBA images" on storage.objects
 for select to anon,authenticated using(bucket_id='imba-images');
-- AFTER creating the first user in Authentication > Users, grant admin rights in SQL Editor:
-- insert into public.site_admins(user_id) values ('REPLACE-WITH-AUTH-USER-UUID');
-- Never create public insert policies on site_admins.

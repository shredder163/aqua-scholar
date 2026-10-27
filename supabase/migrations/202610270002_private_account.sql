-- Apply AFTER the initial AQUA Scholar migration.
-- Restrict all academic data to one Supabase Auth user with verified UH email.
create or replace function public.aqua_is_owner()
returns boolean language sql stable security definer set search_path = ''
as $$ select exists (
 select 1 from auth.users u where u.id = (select auth.uid())
 and lower(u.email) = 'asaga@hawaii.edu' and u.email_confirmed_at is not null
); $$;
revoke all on function public.aqua_is_owner() from public;
grant execute on function public.aqua_is_owner() to authenticated;
do $$ declare t text; begin
 foreach t in array array['semesters','courses','assignments','import_suggestions','sync_sources'] loop
  execute format('drop policy if exists %I on public.%I', t||'_select', t);
  execute format('drop policy if exists %I on public.%I', t||'_insert', t);
  execute format('drop policy if exists %I on public.%I', t||'_update', t);
  execute format('drop policy if exists %I on public.%I', t||'_delete', t);
  execute format('create policy %I on public.%I for select to authenticated using ((select public.aqua_is_owner()) and user_id = (select auth.uid()))',t||'_select',t);
  execute format('create policy %I on public.%I for insert to authenticated with check ((select public.aqua_is_owner()) and user_id = (select auth.uid()))',t||'_insert',t);
  execute format('create policy %I on public.%I for update to authenticated using ((select public.aqua_is_owner()) and user_id = (select auth.uid())) with check ((select public.aqua_is_owner()) and user_id = (select auth.uid()))',t||'_update',t);
  execute format('create policy %I on public.%I for delete to authenticated using ((select public.aqua_is_owner()) and user_id = (select auth.uid()))',t||'_delete',t);
 end loop;
end $$;
-- Defense in depth: deny anonymous access to tables.
revoke all on public.semesters,public.courses,public.assignments,public.import_suggestions,public.sync_sources from anon;

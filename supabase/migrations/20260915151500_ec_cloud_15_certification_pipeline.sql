-- EC-CLOUD-15: privileged mission certification pipeline and reward gate.
create table public.mission_certification_audits (
  id bigint generated always as identity primary key,
  mission_id text not null,
  version integer not null,
  definition_sha256 text not null check (definition_sha256 ~ '^[0-9a-f]{64}$'),
  passed boolean not null,
  findings jsonb not null default '[]'::jsonb,
  audited_at timestamptz not null default now(),
  foreign key (mission_id, version) references public.mission_versions(mission_id, version) on delete restrict
);
alter table public.mission_certification_audits enable row level security;
-- No browser policies: audit details and writes remain privileged.

create or replace function public.certify_mission_version(p_mission_id text, p_version integer, p_audit_id bigint)
returns public.mission_versions
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_version public.mission_versions;
  v_audit public.mission_certification_audits;
begin
  select * into v_version from public.mission_versions
    where mission_id=p_mission_id and version=p_version for update;
  if not found then raise exception 'mission version not found'; end if;
  if v_version.certification_status <> 'draft' then raise exception 'only draft missions can be certified'; end if;
  select * into v_audit from public.mission_certification_audits
    where id=p_audit_id and mission_id=p_mission_id and version=p_version;
  if not found or not v_audit.passed then raise exception 'passing audit required'; end if;
  if v_audit.definition_sha256 <> v_version.definition_sha256 then raise exception 'definition changed after audit'; end if;
  update public.mission_versions set certification_status='certified', certified_at=now()
    where mission_id=p_mission_id and version=p_version returning * into v_version;
  return v_version;
end $$;
revoke all on function public.certify_mission_version(text,integer,bigint) from public, anon, authenticated;
grant execute on function public.certify_mission_version(text,integer,bigint) to service_role;

create or replace function public.quarantine_mission_version(p_mission_id text, p_version integer)
returns void language sql security definer set search_path='' as $$
  update public.mission_versions set certification_status='quarantined', certified_at=null
  where mission_id=p_mission_id and version=p_version and certification_status in ('draft','certified');
$$;
revoke all on function public.quarantine_mission_version(text,integer) from public, anon, authenticated;
grant execute on function public.quarantine_mission_version(text,integer) to service_role;

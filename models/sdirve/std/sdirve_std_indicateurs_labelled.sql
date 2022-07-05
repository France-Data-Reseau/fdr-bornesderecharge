
{{
  config(
    materialized="view",
  )
}}

with labelled as (
  {{ sdirve_indicateurs_labelled(ref('sdirve_src_indicateurs_translated')) }}
)
select * from labelled
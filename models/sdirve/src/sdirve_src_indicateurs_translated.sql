{#
Fully translated, indexed
en service ET abandonnées (données et champs)
#}


{% set fieldPrefix = var('use_case_prefix') + 'ind_' %}
{% set order_by_fields = [fieldPrefix + 'src_priority', fieldPrefix + 'src_id'] %} -- must include dedup relevancy order

{{
  config(
    materialized="table",
    indexes=[{'columns': ['"' + fieldPrefix + 'id_station"']},
      {'columns': order_by_fields},
      ]
  )
}}

with indicateurs as (
  {{ sdirve_indicateurs_translated(ref('sdirve_src_indicateurs_parsed')) }}
)
select * from indicateurs
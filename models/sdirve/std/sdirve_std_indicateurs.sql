{#
shortcut (TODO or DBT alias ?)
#}

{{
  config(
    materialized="view",
  )
}}

select * from {{ ref('sdirve_src_indicateurs_translated') }}
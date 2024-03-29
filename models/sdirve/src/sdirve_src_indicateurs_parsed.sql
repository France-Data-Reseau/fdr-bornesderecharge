{#
Generically parsed
#}

{{
  config(
    materialized="view",
  )
}}

{% set FDR_SOURCE_NOM = this.name | replace('src_', '') | replace('_parsed', '') | replace('_dict', '') %}
{% set has_dictionnaire_champs_valeurs = this.name.endswith('_dict') %}

{{ fdr_francedatareseau.fdr_source_union_from_name(FDR_SOURCE_NOM,
    has_dictionnaire_champs_valeurs,
    this,
    def_model=ref('sdirve_def_indicateurs_definition')) }}
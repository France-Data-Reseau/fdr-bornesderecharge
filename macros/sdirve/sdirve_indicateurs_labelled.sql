{#

#}

{% macro sdirve_indicateurs_labelled(translated_source_relation) %}

{% set modelVersion ='' %}

{% set fieldPrefix = var('use_case_prefix') + 'ind_' %}

with translated as (

    select * from {{ translated_source_relation }}
    {% if var('limit', 0) > 0 %}
    LIMIT {{ var('limit') }}
    {% endif %}

), labelled as (

    select
        translated.*,

        "data_owner_label" as "{{ fieldPrefix }}data_owner_label", -- TODO org_title ; OR data_owner_id becomes org_business_id or SIREN ??

        ind."Définition" as "{{ fieldPrefix }}indicateur_label"

    from translated

        left join {{ ref('l_irve_indicateurs' + modelVersion) }} ind -- LEFT join sinon seulement les lignes qui ont une valeur !! TODO indicateur count pour le vérifier
            on translated."{{ fieldPrefix }}indicateur" = ind."Valeur"

)

select * from labelled

{% endmacro %}
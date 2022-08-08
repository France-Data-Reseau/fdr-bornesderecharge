{#

TODO USED to produce definition ! as well as parse  tests.

Parsing of
- sources that are directly in the apcom types
- a priori (made-up), covering examples of the definition / interface.
- test _expected
Examples have to be **as representative** of all possible data as possible because they are also the basis of the definition.
For instance, for a commune INSEE id field, they should also include a non-integer value such as 2A035 (Belvédère-Campomoro).
Methodology :
1. copy the first line(s) from the specification document
2. add line(s) to contain further values for until they are covering for all columns
3. NB. examples specific to each source type are provided in _source_example along their implementation (for which they are covering)

TODO or _parsed, _definition_ ?
TODO can't be replaced by generic from_csv because is the actual definition, BUT could instead be by guided by metamodel !
{{ sdirve_def_indicateurs_from_csv(ref(model.name[:-4])) }}
#}

{% macro sdirve_def_session_from_csv(source_model=ref(model.name | replace('_stg', ''))) %}

{% set fieldPrefix = var('use_case_prefix') + 'ind_' %}
{% set source_relation = source_model %}{# TODO rename #}
{% set source_alias = None %}{# 'source' TODO rename #}

select

       {#
       listing all fields for doc purpose, and not only those having to be transformed using {{ dbt_utils.star(def_model, except=[...
       because this is the actual definition of the standardized "echange" format
       #}

        "id_station"::text as "{{ fieldPrefix }}id_station", -- FR*S74*P74137 ; TODO Q uuid ? ; source own id Identifiant unique de la station
        {{ fdr_appuiscommuns.to_date_or_null('date_debut', source_relation, ["YYYY-MM-DD HH24:MI:SS"], source_alias) }}::date as "{{ fieldPrefix }}date_debut", -- 2021-10-01 12:52:32 Début de la session
        {{ fdr_appuiscommuns.to_date_or_null('date_fin', source_relation, ["YYYY-MM-DD HH24:MI:SS"], source_alias) }}::date as "{{ fieldPrefix }}date_fin", -- 2021-10-01 12:52:32 Début de la session
        {{ fdr_appuiscommuns.to_numeric_or_null('duree_livraison', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}duree_livraison", -- 253 ; Durée de la livraison de l'énergie pendant la session
        {{ fdr_appuiscommuns.to_numeric_or_null('puissance_max', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}puissance_max", -- 22 ; Puissance maximale appelée pendant la livraison kW
        {{ fdr_appuiscommuns.to_numeric_or_null('consommation', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}consommation", -- 12.3 ; Energie livrée pendant la session en kWh
        "nature_client"::text as "{{ fieldPrefix }}nature_client", -- abonne ; l_irve_clients Nature de client concerné par la recharge
        "operateur_mobilite"::text as "{{ fieldPrefix }}operateur_mobilite" -- Opérateur  ; Nom de l'opérateur de mobilité

    from {{ source_model }}

{% endmacro %}
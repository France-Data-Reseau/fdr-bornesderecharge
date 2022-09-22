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

{% macro sdirve_def_indicateurs_from_csv(source_model=ref(model.name | replace('_stg', ''))) %}

{% set fieldPrefix = var('use_case_prefix') + 'ind_' %}
{% set source_relation = source_model %}{# TODO rename #}
{% set source_alias = None %}{# 'source' TODO rename #}

select

       {#
       listing all fields for doc purpose, and not only those having to be transformed using {{ dbt_utils.star(def_model, except=[...
       because this is the actual definition of the standardized "echange" format
       #}

        "id_station"::text as "{{ fieldPrefix }}id_station", -- FR*S74*P74137 ; TODO Q uuid ? ; source own id Identifiant unique de la station
        {{ fdr_francedatareseau.to_date_or_null('date', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}date", -- 2021-10-01 Date de validité de l'indicateur
        {{ fdr_francedatareseau.to_numeric_or_null('duree_validite', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}duree_validite", -- 523, entier Durée de validité en heures de l'indicateur
        {{ fdr_francedatareseau.to_numeric_or_null('plage_horaire', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}plage_horaire", -- 3, Entier [0;24[  Plage horaire d'application de l'indicateur
        indicateur::text as "{{ fieldPrefix }}indicateur", -- taux_dispo l_irve_indicateur Nom de l'indicateur
        {{ fdr_francedatareseau.to_numeric_or_null('valeur', source_relation, source_alias) }}::numeric as "{{ fieldPrefix }}valeur" -- 0.89, flottant Valeur de l'indicateur

    from {{ source_model }}

{% endmacro %}
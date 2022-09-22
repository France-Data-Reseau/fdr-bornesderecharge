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

{% macro sdirve_def_station_from_csv(source_model=ref(model.name | replace('_stg', ''))) %}

{% set fieldPrefix = var('use_case_prefix') + 'sta_' %}
{% set source_relation = source_model %}{# TODO rename #}
{% set source_alias = None %}{# 'source' TODO rename #}

select

       {#
       listing all fields for doc purpose, and not only those having to be transformed using {{ dbt_utils.star(def_model, except=[...
       because this is the actual definition of the standardized "echange" format

       à partir de l'exemple https://www.data.gouv.fr/fr/datasets/fichier-exemple-stations-de-recharge-de-vehicules-electriques/
       plus le schema https://schema.data.gouv.fr/etalab/schema-irve/2.0.2/ https://schema.data.gouv.fr/schemas/etalab/schema-irve/2.0.2/schema.json
       #}

        "nom_amenageur"::text as "{{ fieldPrefix }}nom_amenageur", -- Société X
        "siren_amenageur"::text as "{{ fieldPrefix }}siren_amenageur", -- 130025265
        "contact_amenageur"::text as "{{ fieldPrefix }}contact_amenageur", -- contact@societe-amenageur.com
        "nom_operateur"::text as "{{ fieldPrefix }}nom_operateur", -- Société Y
        "contact_operateur"::text as "{{ fieldPrefix }}contact_operateur", -- contact@societe-operateur.com
        "telephone_operateur"::text as "{{ fieldPrefix }}telephone_operateur", -- 111111111
        "nom_enseigne"::text as "{{ fieldPrefix }}nom_enseigne", -- Réseau de recharge ABC
        "id_station_itinerance"::text as "{{ fieldPrefix }}id_station_itinerance", -- FR*S74*P74137, rien si pas en itinérance
        "id_station_local"::text as "{{ fieldPrefix }}id_station_local", -- FR*S74*P74137, rien si en itinérance
        "nom_station"::text as "{{ fieldPrefix }}nom_station", -- Picpus
        "implantation_station"::text as "{{ fieldPrefix }}implantation_station", -- Voirie
        "adresse_station"::text as "{{ fieldPrefix }}adresse_station", -- 7 boulevard de Picpus 75012 Paris
        "code_insee_commune"::text as "{{ fieldPrefix }}code_insee_commune", -- 75012
        ST_GeomFROMText('POINT(' || replace(substr("coordonneesXY", 2, length("coordonneesXY") - 2), ',', ' ') || ')', 4326) as geometry, -- [2.400428, 48.840687]
        {{ fdr_francedatareseau.to_numeric_or_null('nbre_pdc', source_relation, source_alias) }}  as "{{ fieldPrefix }}nbre_pdc", -- 10
        "id_pdc_itinerance"::text as "{{ fieldPrefix }}id_pdc_itinerance", -- FRA68P680210015
        "id_pdc_local"::text as "{{ fieldPrefix }}id_pdc_local", --
        {{ fdr_francedatareseau.to_numeric_or_null('puissance_nominale', source_relation, source_alias) }} as "{{ fieldPrefix }}puissance_nominale", -- 22
        {{ fdr_francedatareseau.to_boolean_or_null('prise_type_ef', source_relation, source_alias) }} as "{{ fieldPrefix }}prise_type_ef", -- true
        {{ fdr_francedatareseau.to_boolean_or_null('prise_type_2', source_relation, source_alias) }} as "{{ fieldPrefix }}prise_type_2", -- true
        {{ fdr_francedatareseau.to_boolean_or_null('prise_type_combo_ccs', source_relation, source_alias) }} as "{{ fieldPrefix }}prise_type_combo_ccs", -- false
        {{ fdr_francedatareseau.to_boolean_or_null('prise_type_chademo', source_relation, source_alias) }} as "{{ fieldPrefix }}prise_type_chademo", -- false
        {{ fdr_francedatareseau.to_boolean_or_null('prise_type_autre', source_relation, source_alias) }} as "{{ fieldPrefix }}prise_type_autre", -- false
        {{ fdr_francedatareseau.to_boolean_or_null('gratuit', source_relation, source_alias) }} as "{{ fieldPrefix }}gratuit", -- false
        {{ fdr_francedatareseau.to_boolean_or_null('paiement_acte', source_relation, source_alias) }} as "{{ fieldPrefix }}paiement_acte", -- true
        {{ fdr_francedatareseau.to_boolean_or_null('paiement_cb', source_relation, source_alias) }} as "{{ fieldPrefix }}paiement_cb", -- true
        {{ fdr_francedatareseau.to_boolean_or_null('paiement_autre', source_relation, source_alias) }} as "{{ fieldPrefix }}paiement_autre", -- true
        "tarification"::text as "{{ fieldPrefix }}tarification", -- 0.40€ / kwh
        "condition_acces"::text as "{{ fieldPrefix }}condition_acces", -- Accès libre
        {{ fdr_francedatareseau.to_boolean_or_null('reservation', source_relation, source_alias) }} as "{{ fieldPrefix }}reservation", -- true
        "horaires"::text as "{{ fieldPrefix }}horaires", -- Mo-Fr 08:00-12:00,Mo-Fr 14:00-18:00,Th 08:00-18:00
        "accessibilite_pmr"::text as "{{ fieldPrefix }}accessibilite_pmr", -- Accessible mais non réservé PMR
        "restriction_gabarit"::text as "{{ fieldPrefix }}restriction_gabarit", -- Hauteur maximale 2m
        {{ fdr_francedatareseau.to_boolean_or_null('station_deux_roues', source_relation, source_alias) }} as "{{ fieldPrefix }}station_deux_roues", -- true
        "raccordement"::text as "{{ fieldPrefix }}raccordement", -- Direct
        "num_pdl"::text as "{{ fieldPrefix }}num_pdl", -- 12345678912345 Numéro du point de livraison d'électricité, y compris en cas de raccordement indirect. Dans le cas d'un territoire desservi par ENEDIS, ce numéro doit compoter 14 chiffres.
        {{ fdr_francedatareseau.to_date_or_null('date_mise_en_service', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}date_mise_en_service", -- 2020-01-14
        "observations"::text as "{{ fieldPrefix }}observations", --
        {{ fdr_francedatareseau.to_date_or_null('date_maj', source_relation, ['YYYY-MM-DD'], source_alias) }}::date as "{{ fieldPrefix }}date_maj" -- 2021-04-05

    from {{ source_model }}

{% endmacro %}
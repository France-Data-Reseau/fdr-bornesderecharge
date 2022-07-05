{#
Normalisation vers le modèle de données
à appliquer après le spécifique _from_csv, ou après le générique from_csv guidé par le modèle produit par _from_csv,
qui, eux, gèrent renommage et parsing générique
en service ET abandonnées (données et champs)

TODO :
- accepter en parsing lenient / souple ou pas de la part des collectivités ?? (ou les aide à corriger avec quelle info)
- uuid ?? OUI pbs : idCanalisation
   - (idCanalisation : pas unique donc rendu unique en rajoutant src_id ; ou par uuid (reproductibles) ? (certains le sont déjà !))
   - est text dans le modèle du jdb,
   - et pas unique entre les sources => préfixer par par _src_name le _src_id
- les listes de valeurs contraintes :
  - sont en format CSV séparé par des ";" et non des virgules
  - !!! EN DEHORS de ceux de standards réutilisés (tel ici le Géostandard RAEPA), les codes devraient être lisibles / sémantiquement significatif ! (de plus cela éviterait certains typés int4 où manque un zéro en tête)
    - ex. âme tôle => ame_tole
  - Alias : sert à unifier 2 valeurs en une => plutôt à mettre dans le dictionnaire de données, ou / et comme guide / doc de parsing
  - 5 ENUM : mauvais, à interdire (ou interpréter comme codes) !! heureusement dans les données ce n'en est pas, mais hélas soit des int sans sémantique (dans certains cas typés en varchar, notamment les source* dans ...19)
    - = liste fermée et non ENUM SQL
  - code : liste ouverte NON...
  - (NB. dans LibreOffice, attention, les zéros en tête du Code disparaissent)
- TODO pour aider debug erreurs :
  - -colonnes valeurs source en text,
  - ou quand le champ source et le champ parsé ne sont pas NULL en même temps,
  - ou colonnes supplémentaires champ_err contenant l'exception de parsing...
- (patch ogr2ogr to be able to quote columns !)
- le ...19 (Grand Annecy) a :
  - des ids non uuid (donc non uniques)
  - des "geometrie" varchar Line, mais le bon type dans "geom" ?! => détecter le type ??
  - des dates 2999-12-31 01:00:00.000 +0100, pour NULL ? mais anposeinf est fourni NULL...
  - les codes / ENUs en int4 donc (et non text), et donc dans certains manque un zéro en tête

- OUI OU à chaque fois pour plus de concision et lisibilité select * (les champs en trop sont alors enlevés à la fin par la __definition) ?
#}

{% macro sdirve_def_indicateurs_translated(parsed_source_relation, src_priority=None) %}

{% set modelVersion ='' %}

{% set containerUrl = 'http://' + 'datalake.francedatareseau.fr' %}
{% set typeUrlPrefix = containerUrl + '/dc/type/' %}
{% set type = 'sdirve_indicateur_raw/nativesrc_extract' %} -- spécifique à la source ; _2021 ? from this file ? prefix:typeName ?
{% set type = 'sdirve_indicateur' %} -- _2021 ? from this file ? prefix:typeName ?
{% set fdr_namespace = 'indicateur.' + var('fdr_namespace') %} -- ?
{% set typeName = 'Indicateur' %}
{% set sourcePrefix = 'osmposup' %} -- ?
{% set prefix = var('use_case_prefix') + 'ind' %} -- ?
{% set sourceFieldPrefix = sourcePrefix + ':' %}
{% set sourceFieldPrefix = sourcePrefix + '_' %}
{% set fieldPrefix = prefix + ':' %}
{% set fieldPrefix = prefix + '_' %}
{% set idUrlPrefix = typeUrlPrefix + type + '/' %}

with import_parsed as (

    select * from {{ parsed_source_relation }}
    {% if var('limit', 0) > 0 %}
    LIMIT {{ var('limit') }}
    {% endif %}

{#
rename and generic parsing is rather done
- in specific _from_csv
- in generic from_csv (called by fdr_source_union), which is guided by the previous one
#}

), specific_parsed as (

    -- handle official "echange" fields that are not fully perfect :
    select
        --*,
        {{ dbt_utils.star(parsed_source_relation, except=[
            fieldPrefix + 'id_station']) }},

        "{{ fieldPrefix }}id_station" as "{{ fieldPrefix }}src_id" -- TODO Q uuid ? ; source own id

    from import_parsed

), with_generic_fields as (

    {{ fdr_appuiscommuns.add_generic_fields('specific_parsed', fieldPrefix, fdr_namespace, src_priority) }}

), specific_renamed as (

    select
        *,

        "{{ fieldPrefix }}id" as "{{ fieldPrefix }}id_station"

    from with_generic_fields

)

select * from specific_renamed

{% endmacro %}
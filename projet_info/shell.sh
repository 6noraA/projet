#!/bin/bash

# Fonction d'aide
function show_help() {
    echo "Usage: $0 <fichier_dat> <type_station> <type_consommateur> [-h]"
    echo ""
    echo "Paramètres:"
    echo "  fichier_dat          : Chemin vers le fichier .dat contenant les données."
    echo "  type_station         : Type de station (hvb, hva, lv)."
    echo "  type_consommateur    : Type de consommateur (comp, indiv, all)."
    echo "  -h                   : Affiche cette aide."
    echo ""
    echo "Exemples d'utilisation:"
    echo "  $0 data.dat hvb comp"
    echo "  $0 data.dat lv all"
    echo "  $0 data.dat hva indiv"
    exit 1
}

# Vérification de l'option d'aide
if [[ "$1" == "-h" ]]; then
    show_help
fi

# Vérification des paramètres obligatoires
if [ $# -lt 3 ]; then
    echo "Erreur : Tous les paramètres obligatoires doivent être spécifiés."
    show_help
fi

# Assignation des paramètres
INPUT_FILE=$1
STATION_TYPE=$2
CONSUMER_TYPE=$3

# Vérification de l'existence du fichier
if [ ! -f "$INPUT_FILE" ]; then
    echo "Erreur : Le fichier $INPUT_FILE n'existe pas."
    exit 1
fi

# Vérification des valeurs des paramètres
if [[ ! "$STATION_TYPE" =~ ^(hvb|hva|lv)$ ]]; then
    echo "Erreur : Le type de station doit être 'hvb', 'hva', ou 'lv'."
    show_help
fi

if [[ ! "$CONSUMER_TYPE" =~ ^(comp|indiv|all)$ ]]; then
    echo "Erreur : Le type de consommateur doit être 'comp', 'indiv', ou 'all'."
    show_help
fi

# Vérification des combinaisons interdites
if [[ "$STATION_TYPE" == "hvb" && ( "$CONSUMER_TYPE" == "all" || "$CONSUMER_TYPE" == "indiv" ) ]]; then
    echo "Erreur : Les stations HV-B n'acceptent que 'comp'."
    show_help
fi

if [[ "$STATION_TYPE" == "hva" && ( "$CONSUMER_TYPE" == "all" || "$CONSUMER_TYPE" == "indiv" ) ]]; then
    echo "Erreur : Les stations HV-A n'acceptent que 'comp'."
    show_help
fi

# Compilation de c-wire
CWIRE_SOURCE="c-wire.c"
CWIRE_BINARY="./c-wire"

echo "Compilation de c-wire..."
if [ ! -f "$CWIRE_SOURCE" ]; then
    echo "Erreur : Le fichier source $CWIRE_SOURCE est introuvable."
    exit 1
fi

gcc -o "$CWIRE_BINARY" "$CWIRE_SOURCE"
if [ $? -ne 0 ]; then
    echo "Erreur : Échec de la compilation de c-wire."
    exit 1
fi
echo "Compilation réussie."

# Création du dossier tmp et nettoyage
mkdir -p tmp
rm -f tmp/*

# Enregistrement du début du traitement
start_time=$(date +%s)

# Lancement du traitement
echo "Traitement en cours pour le type de station '$STATION_TYPE' et consommateur '$CONSUMER_TYPE'..."

case $STATION_TYPE in
    hvb)
        if [[ "$CONSUMER_TYPE" == "comp" ]]; then
            awk -F';' '
    $2 != "-" && $3 == "-" && $4 == "-" && $6 == "-" {
        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
        print $2 ";" $7 ";" $8
    }
' "$INPUT_FILE" > tmp/hvb_comp.dat
            echo "Résultat : tmp/hvb_comp.dat"
            "$CWIRE_BINARY" tmp/hvb_comp.dat > tmp/hvb_result.dat
            echo "Résultat final : tmp/hvb_result.dat"
        fi
        ;;
    hva)
        if [[ "$CONSUMER_TYPE" == "comp" ]]; then
            awk -F';' '
                $3 != "-"  && $6 == "-" {
                    gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                    print $3 ";" $7 ";" $8
                }' "$INPUT_FILE" > tmp/hva_comp.dat
            echo "Résultat : tmp/hva_comp.dat"
            "$CWIRE_BINARY" tmp/hva_comp.dat > tmp/hva_resultat.dat
        fi
        ;;
    lv)
        case $CONSUMER_TYPE in
            comp)
                awk -F';' '
                    $4 != "-"  && $6 == "-" {
                        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                        print $4 ";" $7 ";" $8
                    }' "$INPUT_FILE" > tmp/lv_comp.dat
                echo "Résultat : tmp/lv_comp.dat"
                "$CWIRE_BINARY" tmp/lv_comp.dat > tmp/lv_resultat.dat
                ;;
            indiv)
                awk -F';' '
                    $4 != "-" && $5 == "-" {
                        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                        print $4 ";" $7 ";" $8
                    }' "$INPUT_FILE" > tmp/lv_indiv.dat
                echo "Résultat : tmp/lv_indiv.dat"
                "$CWIRE_BINARY" tmp/lv_indiv.dat > tmp/lv_indiv_resultat.dat
                ;;
            all)
                awk -F';' '
                    $4 != "-"  {
                        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                        print $4 ";" $7 ";" $8
                    }' "$INPUT_FILE" > tmp/lv_all.dat
                echo "Résultat : tmp/lv_all.dat"
                "$CWIRE_BINARY" tmp/lv_all.dat > tmp/lv_all_resultat.dat
                ;;
        esac
        ;;
    *)
        echo "Erreur : Type de station invalide."
        show_help
        ;;
esac

# Enregistrement de la fin du traitement
end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Affichage de la durée
echo "Durée du traitement : ${execution_time} secondes."

exit 0


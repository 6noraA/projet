#!/bin/bash

# Fonction d'aide
function show_help() {
    echo "Usage: $0 <fichier_dat> <type_station> <type_consommateur> <type_central> [-h]"
    echo ""
    echo "Paramètres:"
    echo "  fichier_dat          : Chemin vers le fichier .dat contenant les données."
    echo "  type_station         : Type de station (hvb, hva, lv)."
    echo "  type_consommateur    : Type de consommateur (comp, indiv, all)."
    echo "  type_central         : Numéro de la centrale (1,2,..,5) (optionnel)."
    echo "  -h                   : Affiche cette aide."
    echo ""
    echo "Exemples d'utilisation:"
    echo "  $0 data.dat hvb comp"
    echo "  $0 data.dat lv all"
    echo "  $0 data.dat hva indiv"
    exit 1
}

# Fonction pour archiver les anciens fichiers
function archive_old_files() {
    local dir=$1
    local archive_dir="test"
    mkdir -p "$archive_dir"
    
    if [ -d "$dir" ] && [ "$(ls -A "$dir")" ]; then
        mv "$dir"/* "$archive_dir/"
        echo "Les anciens fichiers de $dir ont été déplacés dans $archive_dir."
    else
        echo "Aucun fichier à archiver dans $dir."
    fi
}

# Répertoire contenant les fichiers C et le Makefile
PROG_DIR="./progc"

# Vérification du répertoire contenant le Makefile
if [ ! -d "$PROG_DIR" ]; then
    echo "Erreur : Le répertoire $PROG_DIR est introuvable."
    exit 1
fi

# Compilation de c-wire si l'exécutable est introuvable ou obsolète
if [ ! -x "$PROG_DIR/c-wire" ]; then
    echo "L'exécutable c-wire est introuvable ou non exécutable. Tentative de compilation..."
    cd "$PROG_DIR" || exit 1
    make clean
    make
    if [ $? -ne 0 ]; then
        echo "Erreur : Échec de la compilation avec Makefile."
        exit 1
    fi
    cd - >/dev/null || exit 1
    echo "Compilation réussie."
else
    echo "L'exécutable c-wire existe déjà."
fi

# Fonction pour exécuter c-wire avec animation
function process_c_wire() {
    local input_file=$1
    local output_file=$2

    "$PROG_DIR/c-wire" "$input_file" >> "$output_file" 
    if [ $? -ne 0 ]; then
        echo "Erreur : Échec du traitement avec c-wire."
        exit 1
    fi
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
INPUT_FILE="input/$1"
STATION_TYPE="$2"
CONSUMER_TYPE="$3"
CENTRAL="${4:-}" # optionnel

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

# Filtrage si CENTRAL est défini
echo "Valeur de CENTRAL : $CENTRAL"
if [[ -n "$CENTRAL" ]]; then
    awk -F';' -v val="$CENTRAL" '$1 == val { print $0 }' "$INPUT_FILE" > fichier.csv
    echo "Fichier trié."
    INPUT_FILE=fichier.csv
fi

# Création des dossiers temporaires
mkdir -p tmp result test
archive_old_files "tmp"
archive_old_files "result"

# Lancement du traitement basé sur les paramètres
echo "Traitement en cours pour le consommateur '$CONSUMER_TYPE' et station '$STATION_TYPE'..."
start_time=$(date +%s)
# Phase de prétraitement (avant l'appel de c-wire)
echo "Fichier est en train d'être pré-traité pour le consommateur '$CONSUMER_TYPE' et station '$STATION_TYPE' ..."

# Lancement du traitement avec c-wire
case $STATION_TYPE in
    hvb)
        if [[ "$CONSUMER_TYPE" == "comp" ]]; then
            awk -F';' '
                $2 != "-" && $3 == "-" && $4 == "-" && $6 == "-" {
                    gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                    print $2 ";" $7 ";" $8
                }' "$INPUT_FILE" > tmp/hvb_comp.dat
            echo "Résultat intermédiaire : tmp/hvb_comp.dat"
            echo "Station $STATION_TYPE : Capacité $CONSUMER_TYPE : Load" > "result/hvb_resultat.csv"
            process_c_wire tmp/hvb_comp.dat result/hvb_resultat.csv
            sort -t':' -k3,3n "result/hvb_resultat.csv" -o "result/hvb_resultat.csv"
            echo "Résultat final : result/hvb_resultat.csv"
        fi
        ;;
    hva)
        if [[ "$CONSUMER_TYPE" == "comp" ]]; then
            awk -F';' '
                $3 != "-" && $6 == "-" {
                    gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                    print $3 ";" $7 ";" $8
                }' "$INPUT_FILE" > tmp/hva_comp.dat
            echo "Résultat intermédiaire : tmp/hva_comp.dat"
            echo "Station $STATION_TYPE : Capacité $CONSUMER_TYPE : Load" > "result/hva_resultat.csv"
            process_c_wire tmp/hva_comp.dat result/hva_resultat.csv
            sort -t':' -k3,3n "result/hva_resultat.csv" -o "result/hva_resultat.csv"
            echo "Résultat final : result/hva_resultat.csv"
        fi
        ;;
    lv)
        case $CONSUMER_TYPE in
            comp)
                awk -F';' '
                    $4 != "-" && $6 == "-" {
                        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                        print $4 ";" $7 ";" $8
                    }' "$INPUT_FILE" > tmp/lv_comp.dat
                echo "Résultat intermédiaire : tmp/lv_comp.dat"
                echo "Station $STATION_TYPE : Capacité $CONSUMER_TYPE : Load" > "result/lv_comp_resultat.csv"
                process_c_wire tmp/lv_comp.dat result/lv_comp_resultat.csv
                sort -t':' -k3,3n "result/lv_comp_resultat.csv" -o "result/lv_comp_resultat.csv"
                echo "Résultat final : result/lv_comp_resultat.csv"
                ;;
            indiv)
                awk -F';' '
                    $4 != "-" && $5 == "-" {
                        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                        print $4 ";" $7 ";" $8
                    }' "$INPUT_FILE" > tmp/lv_indiv.dat
                echo "Résultat intermédiaire : tmp/lv_indiv.dat"
                echo "Station $STATION_TYPE : Capacité $CONSUMER_TYPE : Load" > "result/lv_indiv_resultat.csv"
                process_c_wire tmp/lv_indiv.dat result/lv_indiv_resultat.csv
                sort -t':' -k3,3n "result/lv_indiv_resultat.csv" -o "result/lv_indiv_resultat.csv"
                echo "Résultat final : result/lv_indiv_resultat.csv"
                ;;
            all)
                awk -F';' '
                    $4 != "-" && $2 == "-" {
                        gsub(/-/, "0", $7); gsub(/-/, "0", $8);
                        print $4 ";" $7 ";" $8
                    }' "$INPUT_FILE" > tmp/lv_all.dat
                echo "Résultat intermédiaire : tmp/lv_all.dat"
                echo "Station $STATION_TYPE : Capacité $CONSUMER_TYPE : Load" > "result/lv_all_resultat.csv"
                process_c_wire tmp/lv_all.dat result/lv_all_resultat.csv
                echo "Résultat final : result/lv_all_resultat.csv"
                # Étape 1 : Extraire les 5 premières et 5 dernières lignes triées par la 3ᵉ colonne (en ordre décroissant)
		tail -n +2 "result/lv_all_resultat.csv" | sort -t':' -k3,3nr | head -n 10 > "tmp/lv_all_minmax.csv"
		tail -n +2 "result/lv_all_resultat.csv" | sort -t':' -k3,3nr | tail -n 10 >> "tmp/lv_all_minmax.csv"

		# Étape 1 : Ajouter l'en-tête au fichier de sortie
		echo "Station $STATION_TYPE : Capacité $CONSUMER_TYPE : Load" > "result/lv_all_minmax.csv"

		# Étape 2 : Calculer la différence entre les colonnes 2 et 3, trier par cette différence, et supprimer la 4ᵉ colonne
		awk -F: '{diff = $2 - $3; print $0 ":" diff}' "tmp/lv_all_minmax.csv" | sort -t: -k4,4n | uniq | cut -d: -f1-3 >> "result/lv_all_minmax.csv"
		
		mkdir -p graphe
		mv "graphe"/* "test/"
		gnuplot graphe.gnu




                echo "resultat min max dans result/lv_all_minmax.csv"
                ;;
        esac
        ;;
    *)
        echo "Erreur : Type de station invalide."
        show_help
        ;;
esac

echo "Traitement terminé."
end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Nettoyage temporaire
rm -f fichier.csv
rm -f progc/*o
# Affichage de la durée
echo "Traitement terminé. Durée : ${execution_time} secondes."
exit 0

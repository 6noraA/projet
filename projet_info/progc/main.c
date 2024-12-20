#include <stdio.h>
#include <stdlib.h>
#include "avl.h" // Inclusion de l'en-tête contenant les fonctions et structures AVL nécessaires

int main(int argc, char* argv[]) {
    // Vérification du nombre d'arguments passés au programme
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <fichier_donnees>\n", argv[0]);
        return 1; // Quitter le programme si le nombre d'arguments est incorrect
    }

    // Ouverture du fichier CSV en mode lecture
    FILE* fichier = fopen(argv[1], "r");
    if (fichier == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        return 1; // Quitter si le fichier ne peut pas être ouvert
    }

    // Initialisation de la racine de l'arbre AVL à NULL
    noeud* racine = NULL;

    char ligne[1000]; // Tampon pour stocker une ligne du fichier
    // Lecture ligne par ligne du fichier CSV
    while (fgets(ligne, sizeof(ligne), fichier) != NULL) {
        int id;            // Identifiant de l'élément
        int capacité;      // Capacité associée à l'élément
        int consommation;  // Consommation associée à l'élément

        // Extraction des données à partir de la ligne au format "id;capacité;consommation"
        if (sscanf(ligne, "%d;%d;%d", &id, &capacité, &consommation) != 3) {
            fprintf(stderr, "Erreur de lecture de la ligne : %s\n", ligne);
            continue; // Ignorer la ligne si le format est incorrect
        }

        // Insertion des données dans l'arbre AVL
        racine = insertion(racine, id, capacité, consommation);
    }

    // Parcours infixe de l'arbre AVL pour afficher les données triées
    parcourinfixe(racine);

    // Fermeture du fichier pour libérer les ressources associées
    fclose(fichier);

    // Libération de la mémoire allouée pour l'arbre AVL
    libererMemoire(racine);

    return 0; // Indiquer que le programme s'est terminé avec succès
}

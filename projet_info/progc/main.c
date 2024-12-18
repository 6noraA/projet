#include <stdio.h>
#include <stdlib.h>
#include "avl.h"

int main(int argc, char* argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <fichier_donnees>\n", argv[0]);
        return 1;
    }

    FILE* fichier = fopen(argv[1], "r");
    if (fichier == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        return 1;
    }

    noeud* racine = NULL;

    char ligne[1000];
    while (fgets(ligne, sizeof(ligne), fichier) != NULL) {
        int id;
        int capacité;
        int consommation;
        if (sscanf(ligne, "%d;%d;%d", &id, &capacité, &consommation) != 3) {
            fprintf(stderr, "Erreur de lecture de la ligne : %s\n", ligne);
            continue;
        }

        racine = insertion(racine, id, capacité, consommation);
    }

    parcourinfixe(racine);

    fclose(fichier);
    libererMemoire(racine);

    return 0;
}


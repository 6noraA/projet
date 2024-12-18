#include <stdio.h>
#include <stdlib.h>
#include "avl.h"

int max(int a, int b) {
    return (a > b) ? a : b;
}

int hauteur(noeud* noeud) {
    return (noeud == NULL) ? 0 : noeud->hauteur;
}

noeud* rotationGauche(noeud* y) {
    if (y == NULL || y->droite == NULL) {
        return y;
    }

    noeud* x = y->droite;
    noeud* T2 = x->gauche;

    x->gauche = y;
    y->droite = T2;

    y->hauteur = 1 + max(hauteur(y->gauche), hauteur(y->droite));
    x->hauteur = 1 + max(hauteur(x->gauche), hauteur(x->droite));

    return x;
}

noeud* rotationDroite(noeud* x) {
    if (x == NULL || x->gauche == NULL) {
        return x;
    }

    noeud* y = x->gauche;
    noeud* T2 = y->droite;

    y->droite = x;
    x->gauche = T2;

    x->hauteur = 1 + max(hauteur(x->gauche), hauteur(x->droite));
    y->hauteur = 1 + max(hauteur(y->gauche), hauteur(y->droite));

    return y;
}

int getEquilibre(noeud* noeud) {
    return (noeud == NULL) ? 0 : hauteur(noeud->gauche) - hauteur(noeud->droite);
}

noeud* insertion(noeud* racine, int ID, int capa, int conso) {
    if (racine == NULL) {
        noeud* nouveau_noeud = malloc(sizeof(noeud));
        if (nouveau_noeud == NULL) {
            fprintf(stderr, "Erreur d'allocation de mémoire.\n");
            exit(EXIT_FAILURE);
        }

        nouveau_noeud->station_id = ID;
        nouveau_noeud->capacité = capa;
        nouveau_noeud->consommateur = conso;
        nouveau_noeud->gauche = NULL;
        nouveau_noeud->droite = NULL;
        nouveau_noeud->hauteur = 1;
        return nouveau_noeud;
    }

    if (racine->station_id == ID) {
        racine->capacité += capa;
        racine->consommateur += conso;
    } else {
        if (racine->station_id > ID) {
            racine->gauche = insertion(racine->gauche, ID, capa, conso);
        } else {
            racine->droite = insertion(racine->droite, ID, capa, conso);
        }
        racine->hauteur = 1 + max(hauteur(racine->gauche), hauteur(racine->droite));

        int equilibre = getEquilibre(racine);

        if (equilibre > 1) {
            if (ID < racine->station_id) {
                return rotationDroite(racine);
            } else {
                racine->gauche = rotationGauche(racine->gauche);
                return rotationDroite(racine);
            }
        }

        if (equilibre < -1) {
            if (ID > racine->station_id) {
                return rotationGauche(racine);
            } else {
                racine->droite = rotationDroite(racine->droite);
                return rotationGauche(racine);
            }
        }
    }

    return racine;
}

void parcourinfixe(noeud* racine) {
    if (racine == NULL) {
        return;
    }
    parcourinfixe(racine->gauche);
    printf("%d:%d:%d\n", racine->station_id, racine->capacité, racine->consommateur);
    parcourinfixe(racine->droite);
}

void libererMemoire(noeud* racine) {
    if (racine != NULL) {
        libererMemoire(racine->gauche);
        libererMemoire(racine->droite);
        free(racine);
    }
}


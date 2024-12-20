#include <stdio.h>
#include <stdlib.h>
#include "avl.h" // Inclusion de l'en-tête contenant les définitions de structures et fonctions AVL

// Fonction pour renvoyer le maximum entre deux entiers
int max(int a, int b) {
    return (a > b) ? a : b;
}

// Fonction pour calculer la hauteur d'un nœud
int hauteur(noeud* noeud) {
    return (noeud == NULL) ? 0 : noeud->hauteur;
}

// Rotation gauche pour rééquilibrer un sous-arbre
noeud* rotationGauche(noeud* y) {
    if (y == NULL || y->droite == NULL) { // Vérification que la rotation est possible
        return y;
    }

    noeud* x = y->droite;  // Nouveau nœud racine après la rotation
    noeud* T2 = x->gauche; // Sous-arbre gauche de x

    // Effectuer la rotation
    x->gauche = y;
    y->droite = T2;

    // Mettre à jour les hauteurs
    y->hauteur = 1 + max(hauteur(y->gauche), hauteur(y->droite));
    x->hauteur = 1 + max(hauteur(x->gauche), hauteur(x->droite));

    return x; // Retourner le nouveau nœud racine
}

// Rotation droite pour rééquilibrer un sous-arbre
noeud* rotationDroite(noeud* x) {
    if (x == NULL || x->gauche == NULL) { // Vérification que la rotation est possible
        return x;
    }

    noeud* y = x->gauche;  // Nouveau nœud racine après la rotation
    noeud* T2 = y->droite; // Sous-arbre droit de y

    // Effectuer la rotation
    y->droite = x;
    x->gauche = T2;

    // Mettre à jour les hauteurs
    x->hauteur = 1 + max(hauteur(x->gauche), hauteur(x->droite));
    y->hauteur = 1 + max(hauteur(y->gauche), hauteur(y->droite));

    return y; // Retourner le nouveau nœud racine
}

// Fonction pour obtenir le facteur d'équilibre d'un nœud
int getEquilibre(noeud* noeud) {
    return (noeud == NULL) ? 0 : hauteur(noeud->gauche) - hauteur(noeud->droite);
}

// Fonction d'insertion dans l'arbre AVL
noeud* insertion(noeud* racine, int ID, int capa, int conso) {
    // Cas de base : l'arbre est vide
    if (racine == NULL) {
        noeud* nouveau_noeud = malloc(sizeof(noeud)); // Allouer un nouveau nœud
        if (nouveau_noeud == NULL) { // Vérification de l'allocation mémoire
            fprintf(stderr, "Erreur d'allocation de mémoire.\n");
            exit(EXIT_FAILURE);
        }

        // Initialiser les valeurs du nouveau nœud
        nouveau_noeud->station_id = ID;
        nouveau_noeud->capacité = capa;
        nouveau_noeud->consommateur = conso;
        nouveau_noeud->gauche = NULL;
        nouveau_noeud->droite = NULL;
        nouveau_noeud->hauteur = 1;
        return nouveau_noeud;
    }

    // Mise à jour ou insertion selon la valeur de l'ID
    if (racine->station_id == ID) {
        // Si l'ID existe déjà, mettre à jour les valeurs
        racine->capacité += capa;
        racine->consommateur += conso;
    } else {
        // Insérer à gauche ou à droite selon la valeur de l'ID
        if (racine->station_id > ID) {
            racine->gauche = insertion(racine->gauche, ID, capa, conso);
        } else {
            racine->droite = insertion(racine->droite, ID, capa, conso);
        }

        // Mettre à jour la hauteur du nœud actuel
        racine->hauteur = 1 + max(hauteur(racine->gauche), hauteur(racine->droite));

        // Vérifier et corriger le déséquilibre
        int equilibre = getEquilibre(racine);

        // Cas : déséquilibre gauche-gauche
        if (equilibre > 1 && ID < racine->station_id) {
            return rotationDroite(racine);
        }
        // Cas : déséquilibre gauche-droit
        if (equilibre > 1 && ID > racine->station_id) {
            racine->gauche = rotationGauche(racine->gauche);
            return rotationDroite(racine);
        }
        // Cas : déséquilibre droite-droite
        if (equilibre < -1 && ID > racine->station_id) {
            return rotationGauche(racine);
        }
        // Cas : déséquilibre droite-gauche
        if (equilibre < -1 && ID < racine->station_id) {
            racine->droite = rotationDroite(racine->droite);
            return rotationGauche(racine);
        }
    }

    return racine; // Retourner la racine (équilibrée)
}

// Fonction pour effectuer un parcours infixe (ordre croissant)
void parcourinfixe(noeud* racine) {
    if (racine == NULL) { // Condition d'arrêt : nœud nul
        return;
    }
    parcourinfixe(racine->gauche); // Parcourir le sous-arbre gauche
    printf("%d:%d:%d\n", racine->station_id, racine->capacité, racine->consommateur); // Afficher le nœud actuel
    parcourinfixe(racine->droite); // Parcourir le sous-arbre droit
}

// Fonction pour libérer la mémoire allouée pour l'arbre AVL
void libererMemoire(noeud* racine) {
    if (racine != NULL) { // Condition d'arrêt : nœud nul
        libererMemoire(racine->gauche); // Libérer le sous-arbre gauche
        libererMemoire(racine->droite); // Libérer le sous-arbre droit
        free(racine); // Libérer le nœud actuel
    }
}

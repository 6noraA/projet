#ifndef AVL_H
#define AVL_H

typedef struct noeud {
    int station_id;              // Identifiant unique de la station
    int capacité;             // Capacité de la station en MW 
    int consommateur;         // Somme des valeurs de consommation 
    struct noeud* gauche;        // Pointeur vers le sous-arbre gauche
    struct noeud* droite;        // Pointeur vers le sous-arbre droit
    int hauteur;                 // Hauteur du nœud pour l'équilibre de l'AVL
} noeud;

// Fonctions AVL
int hauteur(noeud* noeud);
noeud* rotationGauche(noeud* y);
noeud* rotationDroite(noeud* x);
noeud* insertion(noeud* racine, int ID, int capa, int conso);
void parcourinfixe(noeud* racine);
void libererMemoire(noeud* racine);

#endif


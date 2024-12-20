# **Projet C-WIRE**

Bienvenue dans le projet **C-WIRE** réalisé par **Minkoulou Pemenzi Laurent**.

---

## **I. Structuration du Dossier**

Le projet est organisé dans un dossier nommé **projet_info** avec la structure suivante :

```
projet_info/
|
├── c-wire.sh       # Script principal pour l'exécution des traitements
├── graphe.gnu      # Fichier de configuration pour la génération des graphes
├── progc/          # Contient les fichiers nécessaires au code C
├── test/           # Stocke les résultats et fichiers des traitements précédents
├── graphe/         # Enregistre les graphiques générés
├── result/         # Contient les résultats finaux des traitements
├── tmp/            # Fichiers intermédiaires utilisés lors des traitements
└── input/          # Fichiers d'entrée fournis par l'utilisateur
```

### **Détails des éléments**

- **`progc/`**  
  Ce dossier regroupe tous les éléments nécessaires au bon déroulement du code C :  
  - Les fichiers sources : `main.c`, `avl.h`, `avl.c`.  
  - Le fichier `Makefile` pour la compilation.  
  - L'exécutable généré après compilation.  

- **`input/`**  
  Ce répertoire contient les fichiers de données que l’utilisateur souhaite traiter.  

- **`tmp/`**  
  Dossier dédié aux fichiers intermédiaires utilisés au cours des traitements.  

- **`graphe/`**  
  Ce répertoire contient les graphiques générés lors du traitement `lv_all_minmax`.  

- **`result/`**  
  Dossier qui héberge les résultats finaux des traitements effectués.  

- **`test/`**  
  Archive les résultats des précédents traitements ainsi que les anciens fichiers intermédiaires et graphes.  

- **`graphe.gnu`**  
  Fichier de configuration utilisé pour tracer les graphes dans le cadre du traitement `lv_all_minmax`.  

- **`c-wire.sh`**  
  Le cœur du projet. Ce script shell orchestre l’exécution de tous les traitements.  

---

## **II. Utilisation du Programme**

### **Étape 1 : Configuration des permissions**  
Avant d’utiliser le programme, accordez les permissions nécessaires au script avec la commande suivante :  
```bash
chmod +x c-wire.sh
```

### **Étape 2 : Préparation des fichiers**  
Placez votre fichier de données (`data.csv`) dans le dossier `input/`.  

### **Étape 3 : Exécution du programme**  
Exécutez le script en suivant les étapes ci-dessous :  
1. Lancez la commande `./c-wire.sh`.  
2. Fournissez le nom du fichier CSV (placé dans le dossier `input`).  
3. Indiquez le type de station.  
4. Spécifiez le type de consommateur.  
5. (Facultatif) Précisez le numéro de central.  

#### **Exemples d’exécution**  
```bash
./c-wire.sh c-wire_v25.dat lv all 3
./c-wire.sh c-wire_v00.dat hvb comp
```

### **Étape 4 : Assistance**  
Si vous avez besoin d’aide, un message d’assistance est disponible. Pour l’afficher, utilisez la commande suivante :  
```bash
./c-wire.sh -h
```

---

## **Remarques**

- Assurez-vous que vos fichiers de données sont correctement formatés avant de les placer dans le dossier `input/`.  
- Les résultats et graphiques générés seront automatiquement stockés dans les répertoires respectifs (`result/`, `graphe/`).  

---

Ce fichier README fournit une documentation claire et concise pour le projet **C-WIRE**. Bonne utilisation ! 😊


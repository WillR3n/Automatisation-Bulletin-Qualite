#!/bin/bash

# ============================================================
# collecte_auto.sh
# Collecte les donnees depuis les differents logs et les ajoute
# dans data_bulletin.txt
# ============================================================

echo "Collecte des donnees en cours..."

# ============================================================
# CHEMINS VERS LES FICHIERS DANS /tmp
# ============================================================
BASE_PATH="/tmp"

FICHIER_SYNTHESE="$BASE_PATH/synthese_tfjo_Bicec_20260420.txt"
FICHIER_SAUVE_AVANT="$BASE_PATH/sauveRMANavt.log"
FICHIER_SAUVE_APRES="$BASE_PATH/sauveRMANapt.log"
FICHIER_OUVERTURE="$BASE_PATH/ouverture_site_202604.txt"

# Pour les fichiers SMS, on prendra le plus récent automatiquement
# FICHIER_SMS sera déterminé plus tard

# ============================================================
# FONCTIONS D'EXTRACTION
# ============================================================

# Extraire une valeur après un signe égale
extraire_valeur() {
    local fichier=$1
    local pattern=$2
    if [ -f "$fichier" ]; then
        grep "$pattern" "$fichier" | cut -d'=' -f2 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
    else
        echo ""
    fi
}

# Extraire une heure au format HH:MM:SS ou HH:MM
extraire_heure() {
    local fichier=$1
    local pattern=$2
    if [ -f "$fichier" ]; then
        grep "$pattern" "$fichier" | grep -oE '([0-9]{2}:[0-9]{2}:[0-9]{2})|([0-9]{2}:[0-9]{2})' | head -1
    else
        echo ""
    fi
}

# Extraire un nombre (chiffres uniquement)
extraire_nombre() {
    local fichier=$1
    local pattern=$2
    if [ -f "$fichier" ]; then
        grep "$pattern" "$fichier" | grep -oE '[0-9]+' | head -1
    else
        echo ""
    fi
}

# ============================================================
# 1. EXTRACTION DEPUIS synthese_tfjo_Bicec_*.txt
# ============================================================
echo "  > Lecture du fichier de synthese TFJ..."

if [ ! -f "$FICHIER_SYNTHESE" ]; then
    echo "     ERREUR: Fichier $FICHIER_SYNTHESE introuvable !"
    DEBUT_TFJ=""
    FIN_TFJ=""
    DUREE_TFJ=""
    NB_EVENEMENTS=""
    NB_MOUVEMENTS=""
else
    DEBUT_TFJ=$(extraire_valeur "$FICHIER_SYNTHESE" "HEURE DEBUT")
    FIN_TFJ=$(extraire_valeur "$FICHIER_SYNTHESE" "HEURE FIN")
    DUREE_TFJ=$(extraire_valeur "$FICHIER_SYNTHESE" "DUREE TOTALE TFJ")
    NB_EVENEMENTS=$(extraire_nombre "$FICHIER_SYNTHESE" "EVENEMENTS")
    NB_MOUVEMENTS=$(extraire_nombre "$FICHIER_SYNTHESE" "MOUVEMENTS")
fi

# ============================================================
# 2. EXTRACTION DEPUIS sauveRMANavt.log (sauvegarde avant TFJ)
# ============================================================
echo "  > Lecture du fichier de sauvegarde avant TFJ..."

if [ -f "$FICHIER_SAUVE_AVANT" ]; then
    DEBUT_SAUVE_AVANT=$(grep "Debut sauvegarde physique BICEC" "$FICHIER_SAUVE_AVANT" | tail -1 | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
else
    echo "     ERREUR: Fichier $FICHIER_SAUVE_AVANT introuvable !"
    DEBUT_SAUVE_AVANT=""
fi

# ============================================================
# 3. EXTRACTION DEPUIS sauveRMANapt.log (sauvegarde après TFJ)
# ============================================================
echo "  > Lecture du fichier de sauvegarde apres TFJ..."

if [ -f "$FICHIER_SAUVE_APRES" ]; then
    DEBUT_SAUVE_APRES=$(grep "Fin sauvegarde physique" "$FICHIER_SAUVE_APRES" | tail -1 | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
else
    echo "     ERREUR: Fichier $FICHIER_SAUVE_APRES introuvable !"
    DEBUT_SAUVE_APRES=""
fi



# ============================================================
# 4. EXTRACTION DEPUIS snd_ftp_FILE_*.log (transfert SMS)
# ============================================================
echo "  > Lecture du fichier de transfert SMS..."

# Prendre le fichier SMS le plus récent dans /tmp
FICHIER_SMS_RECENT=$(ls -t $BASE_PATH/snd_ftp_FILE_*.log 2>/dev/null | head -1)

if [ -f "$FICHIER_SMS_RECENT" ]; then
    echo "     Fichier trouve: $(basename $FICHIER_SMS_RECENT)"
    TRANSFERT_SMS=$(grep "Debut de transfert" "$FICHIER_SMS_RECENT" | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}' | head -1)
else
    echo "     ERREUR: Aucun fichier snd_ftp_FILE_*.log trouve dans $BASE_PATH"
    TRANSFERT_SMS=""
fi

# ============================================================
# 5. EXTRACTION DEPUIS ouverture_site_*.txt (ouverture site)
# ============================================================
echo "  > Lecture du fichier d'ouverture site..."

if [ -f "$FICHIER_OUVERTURE" ]; then
    # Extraire la dernière ouverture du site
    OUVERTURE_SITE=$(grep "Ouverture" "$FICHIER_OUVERTURE" | tail -1 | grep -oE '[0-9]{2}:[0-9]{2}:[0-9]{2}')
else
    echo "     ERREUR: Fichier $FICHIER_OUVERTURE introuvable !"
    OUVERTURE_SITE=""
fi

# ============================================================
# 6. INFORMATIONS SUPPLEMENTAIRES
# ============================================================
DATE_COLLECTE=$(date '+%d-%m-%Y %H:%M:%S')

# ============================================================
# DEMANDE DU NOM DE L'OPERATEUR
# ============================================================
echo ""
read -p "Entrez votre nom (operateur ayant rempli le bulletin) : " NOM_OPERATEUR

# Si l'utilisateur n'entre rien, mettre "Non renseigne"
if [ -z "$NOM_OPERATEUR" ]; then
    NOM_OPERATEUR="Non renseigne"
fi

# ============================================================
# AFFICHAGE POUR VERIFICATION
# ============================================================
echo ""
echo "=========================================="
echo "DONNEES EXTRAITES :"
echo "=========================================="
echo "Debut sauvegarde avant     : $DEBUT_SAUVE_AVANT"
echo "Debut TFJ                  : $DEBUT_TFJ"
echo "Fin TFJ                    : $FIN_TFJ"
echo "Duree TFJ                  : $DUREE_TFJ"
echo "Fin sauvegarde apres       : $FIN_SAUVE_APRES"
echo "Ouverture site             : $OUVERTURE_SITE"
echo "Transfert SMS              : $TRANSFERT_SMS"
echo "Evenements                 : $NB_EVENEMENTS"
echo "Mouvements                 : $NB_MOUVEMENTS"
echo "=========================================="

# ============================================================
# AJOUT DANS data_bulletin.txt
# ============================================================
echo ""
echo "Ajout des donnees dans $HOME/Bulletin_Q/data/data_bulletin.txt..."

mkdir -p $HOME/Bulletin_Q/data

cat >> $HOME/Bulletin_Q/data/data_bulletin.txt << EOF

# ========================================
# TRAVAUX DU TFJO - $DATE_COLLECTE
# ========================================

DEBUT_SAUVE_AVANT=$DEBUT_SAUVE_AVANT
DEBUT_TFJ=$DEBUT_TFJ
FIN_TFJ=$FIN_TFJ
DUREE_TFJ=$DUREE_TFJ
FIN_SAUVE_APRES=$FIN_SAUVE_APRES

# OUVERTURE SITE
HEURE_OUVERTURE_SITE=$OUVERTURE_SITE

# TRANSFERT SMS
HEURE_TRANSFERT_SMS=$TRANSFERT_SMS

# VOLUMETRIE
NB_EVENEMENTS=$NB_EVENEMENTS
NB_MOUVEMENTS=$NB_MOUVEMENTS

# OPERATEUR AYANT REMPLI LE BULLETIN
OPERATEUR="$NOM_OPERATEUR"

EOF

echo ""
echo "=========================================="
echo "Collecte automatique terminee avec succes !"
echo "=========================================="
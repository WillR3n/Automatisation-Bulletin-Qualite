#!/bin/bash

# ========================================================
# bulletin_tfj.sh - Script principal
# Automatisation du Bulletin Qualite TFJO - BICEC
# ========================================================


clear 
echo "========================================================"
echo "            BULLETIN QUALITE TFJO - BICEC"
echo "            $(date '+%d/%m/%y a %H:%M:%S')"
echo "========================================================"
echo ""


# ========================================================
# DONNEES MANUELLE
# ========================================================


echo "--- TRAVAUX DU TFJO ---"
echo ""
echo -n "Controle disponibilite AMPLITUDE : "
read AMPLITUDE

echo ""
echo "--- MONETIQUE ---"
echo ""
echo -n "Disponiblite du resident PCA : "
read PCA


echo ""
echo "--- SERVICE A VALEUR AJOUTE ---"
echo ""
echo -n "Disponiblite du service STREAMSERVE : "
read STREAMSERVE 
echo -n "Disponibilite du service SWIFT :"
read SWIFT


echo ""
echo "--- DIDPONIBILTE DU SI ---"
echo ""
echo -n "Taux disponibilite de la journee : "
read TAUX_JOUR
echo -n "Taux disponibilite du mois :"
read TAUX_MOIS

echo ""
echo "--- INCIDENT DE PRODUCTON ---"
echo ""
echo -n "Y a-t-il eu un incident ? O/N : "
read HAS_INCIDENT

INCIDENT=""
ACTION=""
DUREE_INCIDENT=""

if [ "$HAS_INCIDENT" == "O" ] || [ "$HAS_INCIDENT" == "o" ]; then
   echo ""
   echo -n "Description de l incident : "
   read INCIDENT
   echo -n "Action immediate : "
   read ACTION
   echo -n "Duree de l incident : "
   read DUREE_INCIDENT
fi

echo ""
echo "--- AUTRE TRAITEMENT ---"
echo ""
echo "Entrez les traitements effectues un par un."
echo "Appuyer sur les entrees sans rien ecrire pour terminer."
echo ""

AUTRE_TRAITEMENTS=()
i=0
while true; do
    echo -n "Traitement $((i+1)) : "
    read TRAITEMENT
    if [ -z "$TRAITEMENT" ]; then
        break
    fi
    AUTRES_TRAITEMENTS+=("$TRAITEMENT")
    i=$((i+1))
done

echo ""
echo "============================================================"
echo "              RECAPITULATIF DES SAISIES"
echo "============================================================"
echo ""
echo "--- TRAVAUX DU TFJO ---"
echo "Controle disponibilite AMPLITUDE        : $AMPLITUDE"
echo ""
echo "--- MONETIQUE ---"
echo "Disponiblite du resident PCA         : $PCA"
echo ""
echo "--- SERVICES A VALEUR AJOUTE ---"
echo "Disponibilite du service STREAMSERVE : $STREAMSERVE"
echo "Disponibilite du service SWIFT       : $SWIFT"
echo ""
echo "--- DISPONIBILITE DU SI ---"
echo "Taux disponibilite de la journee   : $TAUX_JOUR"
echo "Taux disponibilite du mois   : $TAUX_MOIS"
echo ""
echo "--- INCIDENT ---"
echo "Incident                  : $INCIDENT"
echo "Action immediate          : $ACTION"
echo "Duree incident            : $DUREE_INCIDENT"
echo ""
echo "--- AUTRES TRAITEMENTS ---"
for TRAITEMENT in "${AUTRES_TRAITEMENTS[@]}"; do
    echo "  - $TRAITEMENT"
done
echo ""
echo "============================================================"
echo -n "Confirmer les donnees ? O/N : "
read CONFIRM

if [ "$CONFIRM" == "N" ] || [ "$CONFIRM" == "n" ]; then
    echo ""
    echo "Saisie annulee. Relancez le script."
    exit 1
fi

mkdir -p "$HOME/Bulletin_Q/data"
cat > $HOME/Bulletin_Q/data/data_bulletin.txt << EOF

#TRAVAUX DU TFJO
AMPLITUDE=$AMPLITUDE

#MONETIQUE
PCA=$PCA

#SERVICE A VALEUR AJOUTE
STREAMSERVE=$STREAMSERVE 
SWIFT=$SWIFT

# DISPONIBILITE DU SI
TAUX_JOUR=$TAUX_JOUR
TAUX_MOIS=$TAUX_MOIS

#INCIDENT DE PRODUCTION 

INCIDENT=$INCIDENT
ACTION=$ACTION
DUREE_INCIDENT=$DUREE_INCIDENT

# AUTRE TRAITEMENTS

NB_AUTRES=${#AUTRES_TRAITEMENTS[@]}

EOF

# Ajout des autres traitements
i=0
for TRAITEMENT in "${AUTRES_TRAITEMENTS[@]}"; do
    echo "AUTRE_$i=$TRAITEMENT" >> $HOME/Bulletin_Q/data/data_bulletin.txt 
    i=$((i+1))
done 

echo ""
echo "Donnees manuelles sauvegardees"


echo ""
echo "Lancement de la collecte automatique des donnee du TFJO"
bash $HOME/Bulletin_Q/collecte_auto.sh

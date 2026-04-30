#!/bin/bash

# ============================================================
# generate_bulletin.sh
# Genere le bulletin qualite TFJO au format HTML
# Les donnees sont lues depuis data_bulletin.txt
# BICEC - Automatisation Bulletin Qualite
# ============================================================

DATA_FILE="$HOME/Bulletin_Q/data/data_bulletin.txt"
OUTPUT_DIR="$HOME/Bulletin_Q/output"
DATE_BULLETIN=$(date '+%d%m%Y')
OUTPUT_FILE="$OUTPUT_DIR/bulletin_$DATE_BULLETIN.html"

mkdir -p "$OUTPUT_DIR"

if [ ! -f "$DATA_FILE" ]; then
    echo "ERREUR: Fichier $DATA_FILE introuvable !"
    exit 1
fi

echo "Lecture des donnees depuis data_bulletin.txt..."

# ============================================================
# FONCTION GET_VAL CORRIGEE
# ============================================================

get_val() {
    local var_name=$1
    local value=""
    
    # Chercher la ligne exacte (sans les '#' de commentaire)
    value=$(grep "^$var_name=" "$DATA_FILE" 2>/dev/null | head -1 | cut -d'=' -f2-)
    
    # Nettoyer la valeur
    if [ -n "$value" ]; then
        echo "$value" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/"//g' | sed 's/ !.*//' | sed 's/\.[0-9]*$//'
    else
        echo ""
    fi
}

# ============================================================
# FONCTION POUR EXTRAIRE UNE HEURE (premiere occurrence)
# ============================================================
get_heure() {
    local var_name=$1
    local value=$(get_val "$var_name")
    # Si pas trouve, chercher dans la partie auto
    if [ -z "$value" ]; then
        value=$(grep "^$var_name=" "$DATA_FILE" 2>/dev/null | tail -1 | cut -d'=' -f2- | sed 's/^[[:space:]]*//' | sed 's/ !.*//')
    fi
    echo "$value"
}

# ============================================================
# LECTURE DES DONNEES MANUELLES (début du fichier)
# ============================================================

AMPLITUDE=$(get_val "AMPLITUDE")
PCA=$(get_val "PCA")
STREAMSERVE=$(get_val "STREAMSERVE")
SWIFT=$(get_val "SWIFT")
TAUX_JOUR=$(get_val "TAUX_JOUR")
TAUX_MOIS=$(get_val "TAUX_MOIS")

# Incident
INCIDENT=$(get_val "INCIDENT")
ACTION=$(get_val "ACTION")
DUREE_INCIDENT=$(get_val "DUREE_INCIDENT")

# Autres traitements
NB_AUTRES=$(get_val "NB_AUTRES")

# ============================================================
# LECTURE DES DONNEES AUTOMATIQUES (fin du fichier)
# ============================================================

DEBUT_SAUVE_AVANT=$(get_heure "DEBUT_SAUVE_AVANT")
DEBUT_TFJ=$(get_heure "DEBUT_TFJ")
FIN_TFJ=$(get_heure "FIN_TFJ")
DUREE_TFJ=$(get_heure "DUREE_TFJ")
FIN_SAUVE_APRES=$(get_heure "FIN_SAUVE_APRES")
HEURE_OUVERTURE_SITE=$(get_heure "HEURE_OUVERTURE_SITE")
HEURE_TRANSFERT_SMS=$(get_heure "HEURE_TRANSFERT_SMS")
NB_EVENEMENTS=$(get_val "NB_EVENEMENTS")
NB_MOUVEMENTS=$(get_val "NB_MOUVEMENTS")
OPERATEUR=$(get_val "OPERATEUR")

# ============================================================
# DEBUG - Afficher ce qui a ete lu
# ============================================================
echo ""
echo "=========================================="
echo "VERIFICATION DES DONNEES LECTURES :"
echo "=========================================="
echo "AMPLITUDE (manuelle)        : $AMPLITUDE"
echo "PCA (manuelle)              : $PCA"
echo "STREAMSERVE (manuelle)      : $STREAMSERVE"
echo "SWIFT (manuelle)            : $SWIFT"
echo "TAUX_JOUR (manuelle)        : $TAUX_JOUR"
echo "TAUX_MOIS (manuelle)        : $TAUX_MOIS"
echo "INCIDENT (manuelle)         : $INCIDENT"
echo "ACTION (manuelle)           : $ACTION"
echo "DUREE_INCIDENT (manuelle)   : $DUREE_INCIDENT"
echo "NB_AUTRES (manuelle)        : $NB_AUTRES"
echo "------------------------------------------"
echo "DEBUT_SAUVE_AVANT (auto)    : $DEBUT_SAUVE_AVANT"
echo "DEBUT_TFJ (auto)            : $DEBUT_TFJ"
echo "FIN_TFJ (auto)              : $FIN_TFJ"
echo "DUREE_TFJ (auto)            : $DUREE_TFJ"
echo "FIN_SAUVE_APRES (auto)      : $FIN_SAUVE_APRES"
echo "HEURE_OUVERTURE_SITE (auto) : $HEURE_OUVERTURE_SITE"
echo "HEURE_TRANSFERT_SMS (auto)  : $HEURE_TRANSFERT_SMS"
echo "NB_EVENEMENTS (auto)        : $NB_EVENEMENTS"
echo "NB_MOUVEMENTS (auto)        : $NB_MOUVEMENTS"
echo "OPERATEUR (auto)            : $OPERATEUR"
echo "=========================================="
echo ""

# ============================================================
# CONSTRUCTION DE LA LISTE DES AUTRES TRAITEMENTS
# ============================================================
AUTRES_HTML=""
if [ -n "$NB_AUTRES" ] && [ "$NB_AUTRES" -gt 0 ] 2>/dev/null; then
    i=0
    while [ $i -lt $NB_AUTRES ]; do
        VAL=$(get_val "AUTRE_$i")
        if [ -n "$VAL" ]; then
            AUTRES_HTML="$AUTRES_HTML<li>$VAL</li>"
        fi
        i=$((i+1))
    done
fi

# ============================================================
# GESTION DE L'INCIDENT
# ============================================================
if [ -n "$INCIDENT" ] && [ "$INCIDENT" != "" ]; then
    INCIDENT_DISPLAY="$INCIDENT"
    ACTION_DISPLAY="$ACTION"
    DUREE_INC_DISPLAY="$DUREE_INCIDENT"
else
    INCIDENT_DISPLAY=""
    ACTION_DISPLAY=""
    DUREE_INC_DISPLAY=""
fi

# ============================================================
# VALEURS PAR DEFAUT
# ============================================================
[ -z "$AMPLITUDE" ] && AMPLITUDE="--"
[ -z "$PCA" ] && PCA="--"
[ -z "$STREAMSERVE" ] && STREAMSERVE="--"
[ -z "$SWIFT" ] && SWIFT="--"
[ -z "$TAUX_JOUR" ] && TAUX_JOUR="--"
[ -z "$TAUX_MOIS" ] && TAUX_MOIS="--"
[ -z "$DEBUT_SAUVE_AVANT" ] && DEBUT_SAUVE_AVANT="--"
[ -z "$DEBUT_TFJ" ] && DEBUT_TFJ="--"
[ -z "$FIN_TFJ" ] && FIN_TFJ="--"
[ -z "$DUREE_TFJ" ] && DUREE_TFJ="--"
[ -z "$FIN_SAUVE_APRES" ] && FIN_SAUVE_APRES="--"
[ -z "$HEURE_OUVERTURE_SITE" ] && HEURE_OUVERTURE_SITE="--"
[ -z "$HEURE_TRANSFERT_SMS" ] && HEURE_TRANSFERT_SMS="--"
[ -z "$NB_EVENEMENTS" ] && NB_EVENEMENTS="--"
[ -z "$NB_MOUVEMENTS" ] && NB_MOUVEMENTS="--"
[ -z "$AUTRES_HTML" ] && AUTRES_HTML="<li></li>"

DATE_COMPTABLE=$(date '+%d/%m/%Y')

echo "Generation du bulletin HTML..."

# ============================================================
# GENERATION DU BULLETIN HTML
# ============================================================

cat > "$OUTPUT_FILE" << ENDFICHIER
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Bulletin Qualite TFJO - BICEC - $DATE_COMPTABLE</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: Arial, sans-serif;
      background: #f5f5f5;
      color: #1a1a1a;
      font-size: 13px;
    }

    .header {
      background: #401202;
      color: white;
      padding: 20px 40px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .header-left h1 {
      font-size: 20px;
      font-weight: bold;
      color: #D96704;
      letter-spacing: 0.5px;
    }

    .header-left p {
      font-size: 11px;
      color: rgba(255,255,255,0.6);
      margin-top: 4px;
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    .header-right {
      text-align: right;
    }

    .header-right .date {
      font-size: 14px;
      font-weight: bold;
      color: #D96704;
    }

    .header-right .label {
      font-size: 10px;
      color: rgba(255,255,255,0.5);
      text-transform: uppercase;
      letter-spacing: 1px;
    }

    .container {
      max-width: 900px;
      margin: 30px auto;
      padding: 0 20px 60px;
    }

    /* TABLE PRINCIPALE */
    .bulletin-table {
      width: 100%;
      border-collapse: collapse;
      background: white;
      box-shadow: 0 2px 10px rgba(0,0,0,0.08);
      border-radius: 8px;
      overflow: hidden;
    }

    .bulletin-table th,
    .bulletin-table td {
      border: 1px solid #ddd;
      padding: 9px 14px;
      text-align: left;
    }

    /* EN-TETE DE SECTION */
    .section-header {
      background: #401202;
      color: white;
      font-weight: bold;
      font-size: 12px;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      text-align: center;
    }

    /* EN-TETE DES COLONNES */
    .col-header {
      background: #D96704;
      color: white;
      font-weight: bold;
      font-size: 11px;
      text-transform: uppercase;
      letter-spacing: 0.3px;
    }

    /* LIGNE PAIRE */
    .row-even {
      background: #FDF4EC;
    }

    /* LIGNE IMPAIRE */
    .row-odd {
      background: white;
    }

    /* CATEGORIE */
    .cat {
      font-weight: 500;
      color: #401202;
      width: 40%;
    }

    /* VALEUR */
    .val {
      color: #333;
      width: 35%;
    }

    /* NORME */
    .norme {
      color: #D96704;
      font-weight: bold;
      width: 25%;
    }

    /* STATUTS */
    .ok {
      background: #e8f5e9;
      color: #2e7d32;
      font-weight: bold;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 11px;
    }

    .alerte {
      background: #fff3e0;
      color: #e65100;
      font-weight: bold;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 11px;
    }

    .neant {
      color: #999;
      font-style: italic;
    }

    /* LISTE AUTRES TRAITEMENTS */
    .autres-list {
      list-style: none;
      padding: 0;
      margin: 0;
    }

    .autres-list li {
      padding: 3px 0;
      color: #333;
    }

    .autres-list li::before {
      content: "- ";
      color: #D96704;
      font-weight: bold;
    }

    /* BOUTON MODIFIER */
    .actions-bar {
      display: flex;
      justify-content: flex-end;
      gap: 12px;
      margin-top: 20px;
    }

    .btn-modifier {
      padding: 10px 28px;
      background: #D96704;
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 13px;
      font-weight: bold;
      cursor: pointer;
      transition: background 0.2s;
    }

    .btn-modifier:hover {
      background: #bf5a03;
    }

    .btn-annuler {
      padding: 10px 28px;
      background: white;
      color: #401202;
      border: 2px solid #401202;
      border-radius: 8px;
      font-size: 13px;
      font-weight: bold;
      cursor: pointer;
      display: none;
      transition: all 0.2s;
    }

    .btn-annuler:hover {
      background: #401202;
      color: white;
    }

    /* MODE EDITION */
    .editable {
      background: #fffbf0 !important;
      outline: 2px solid #D96704;
      border-radius: 3px;
      min-width: 80px;
      display: inline-block;
      padding: 2px 6px;
    }

    /* FOOTER */
    .footer {
      text-align: center;
      margin-top: 30px;
      font-size: 11px;
      color: #999;
    }

    .footer span {
      color: #D96704;
      font-weight: bold;
    }
  </style>
</head>
<body>

<!-- HEADER -->
<div class="header">
  <div class="header-left">
    <h1>Bulletin Qualite TFJO</h1>
    <p>Banque Internationale du Cameroun pour l Epargne et le Credit</p>
  </div>
  <div class="header-right">
    <div class="label">Date du bulletin</div>
    <div class="date">$DATE_COMPTABLE</div>
  </div>
</div>

<!-- CONTENU -->
<div class="container">

  <table class="bulletin-table" id="bulletin">

    <!-- EN-TETES COLONNES -->
    <thead>
      <tr>
        <th class="col-header">Categories</th>
        <th class="col-header">Heure et/ou Etat</th>
        <th class="col-header">Norme clientele</th>
      </tr>
    </thead>

    <tbody>

      <!-- ================================ -->
      <!-- SECTION : TRAVAUX DU TFJO        -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Travaux du TFJO</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Debut sauvegarde avant TFJ</td>
        <td class="val" id="v_debut_sauve_avant">$DEBUT_SAUVE_AVANT</td>
        <td class="norme">19H45</td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Debut TFJ</td>
        <td class="val" id="v_debut_tfj">$DEBUT_TFJ</td>
        <td class="norme">20H00</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Fin TFJ</td>
        <td class="val" id="v_fin_tfj">$FIN_TFJ</td>
        <td class="norme"></td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Duree TFJ</td>
        <td class="val" id="v_duree_tfj">$DUREE_TFJ</td>
        <td class="norme">06H00</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Fin sauvegarde apres TFJ</td>
        <td class="val" id="v_fin_sauve_apres">$FIN_SAUVE_APRES</td>
        <td class="norme"></td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Ouverture du site et portail</td>
        <td class="val" id="v_ouverture_site">$HEURE_OUVERTURE_SITE</td>
        <td class="norme">07H30</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Autorisation des connexions</td>
        <td class="val" id="v_autorisation">--</td>
        <td class="norme">07H30</td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Disponibilite Infocentre (DCO)</td>
        <td class="val" id="v_dco">--</td>
        <td class="norme">J - 1</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Controle disponibilite AMPLITUDE</td>
        <td class="val" id="v_amplitude">$AMPLITUDE</td>
        <td class="norme">06H30</td>
      </tr>

      <!-- ================================ -->
      <!-- SECTION : MONETIQUE              -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Monetique</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Disponibilite du resident PCA</td>
        <td class="val" id="v_pca">$PCA</td>
        <td class="norme"></td>
      </tr>

      <!-- ================================ -->
      <!-- SECTION : SERVICES A VALEUR AJOUTE -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Services a valeur ajoute</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Transfert SMS</td>
        <td class="val" id="v_transfert_sms">$HEURE_TRANSFERT_SMS</td>
        <td class="norme">06H30</td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Disponibilite du service STREAMSERVE</td>
        <td class="val" id="v_streamserve">$STREAMSERVE</td>
        <td class="norme"></td>
      </tr>
      <tr class="row-even">
        <td class="cat">Disponibilite du service SWIFT</td>
        <td class="val" id="v_swift">$SWIFT</td>
        <td class="norme"></td>
      </tr>

      <!-- ================================ -->
      <!-- SECTION : DISPONIBILITE DU SI    -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Disponibilite du SI</td>
      </tr>
      <tr class="row-even">
        <td colspan="3" style="text-align:center; font-weight:bold; color:#401202;">Amplitude UP v11.6.5 patch 40</td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Taux disponibilite de la journee</td>
        <td class="val" id="v_taux_jour">$TAUX_JOUR</td>
        <td class="norme"></td>
      </tr>
      <tr class="row-even">
        <td class="cat">Taux disponibilite du mois</td>
        <td class="val" id="v_taux_mois">$TAUX_MOIS</td>
        <td class="norme"></td>
      </tr>
      <tr class="row-odd">

      <!-- ================================ -->
      <!-- SECTION : VOLUMETRIE             -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Volumetrie</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Nombre d evenements</td>
        <td class="val" id="v_nb_evenements">$NB_EVENEMENTS</td>
        <td class="norme"></td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Nombre de mouvements</td>
        <td class="val" id="v_nb_mouvements">$NB_MOUVEMENTS</td>
        <td class="norme"></td>
      </tr>

      <!-- ================================ -->
      <!-- SECTION : INCIDENT DE PRODUCTION -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Incident de production</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Incident</td>
        <td class="val" id="v_incident" colspan="2">$INCIDENT_DISPLAY</td>
      </tr>
      <tr class="row-odd">
        <td class="cat">Action immediate</td>
        <td class="val" id="v_action" colspan="2">$ACTION_DISPLAY</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Duree incident</td>
        <td class="val" id="v_duree_incident" colspan="2">$DUREE_INC_DISPLAY</td>
      </tr>

      <!-- ================================ -->
      <!-- SECTION : AUTRES TRAITEMENTS     -->
      <!-- ================================ -->
      <tr>
        <td colspan="3" class="section-header">Autres Infos Traitements</td>
      </tr>
      <tr class="row-even">
        <td class="cat">Autres Traitements</td>
        <td colspan="2" class="val" id="v_autres">
          <ul class="autres-list">
            $AUTRES_HTML
          </ul>
        </td>
      </tr>

    </tbody>
  </table>

  <!-- BOUTONS -->
  <div class="actions-bar">
    <button class="btn-annuler" id="btn-annuler" onclick="annulerModification()">Annuler</button>
    <button class="btn-modifier" id="btn-modifier" onclick="toggleModification()">Modifier</button>
  </div>

  <!-- FOOTER -->
  <div class="footer">
    Bulletin genere automatiquement le $DATE_COMPTABLE &nbsp;|&nbsp;
    <span>BICEC</span> &nbsp;|&nbsp; Service Production Informatique
  </div>

</div>

<script>
  let modeEdition = false;
  let valeursOriginales = {};

  // IDs des cellules editables
  const cellulesEditables = [
    'v_debut_sauve_avant', 'v_debut_tfj', 'v_fin_tfj', 'v_duree_tfj',
    'v_fin_sauve_apres', 'v_ouverture_site', 'v_autorisation', 'v_dco',
    'v_amplitude', 'v_pca', 'v_transfert_sms', 'v_streamserve', 'v_swift',
    'v_taux_jour', 'v_taux_mois', 'v_taux_annee',
    'v_nb_evenements', 'v_nb_mouvements',
    'v_incident', 'v_action', 'v_duree_incident', 'v_autres'
  ];

  function toggleModification() {
    if (!modeEdition) {
      // Activer le mode edition
      modeEdition = true;
      document.getElementById('btn-modifier').textContent = 'Valider';
      document.getElementById('btn-annuler').style.display = 'inline-block';

      cellulesEditables.forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
          valeursOriginales[id] = el.innerHTML;
          el.contentEditable = 'true';
          el.classList.add('editable');
        }
      });
    } else {
      // Valider les modifications
      modeEdition = false;
      document.getElementById('btn-modifier').textContent = 'Modifier';
      document.getElementById('btn-annuler').style.display = 'none';

      cellulesEditables.forEach(function(id) {
        var el = document.getElementById(id);
        if (el) {
          el.contentEditable = 'false';
          el.classList.remove('editable');
        }
      });
    }
  }

  function annulerModification() {
    modeEdition = false;
    document.getElementById('btn-modifier').textContent = 'Modifier';
    document.getElementById('btn-annuler').style.display = 'none';

    // Restaurer les valeurs originales
    cellulesEditables.forEach(function(id) {
      var el = document.getElementById(id);
      if (el && valeursOriginales[id] !== undefined) {
        el.innerHTML = valeursOriginales[id];
        el.contentEditable = 'false';
        el.classList.remove('editable');
      }
    });
  }
</script>

</body>
</html>
ENDFICHIER

echo ""
echo "========================================================"
echo "  Bulletin genere avec succes !"
echo "  Fichier : $OUTPUT_FILE"
echo "========================================================"

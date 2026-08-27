#!/usr/bin/env bash
# Génère un spec OpenAPI à jour pour un module Spring Boot/JHipster (springdoc).
# Écrit le résultat dans .tmp-api-sync/openapi.json (relatif au répertoire courant).
#
# Usage : generate-openapi.sh <module-dir> [port] [context-path]
#   module-dir    : dossier du module Spring Boot contenant pom.xml (obligatoire)
#   port          : port local de l'app si elle tourne déjà (défaut 8080)
#   context-path  : context-path servlet de l'app (ex. /api), vide par défaut. `/v3/api-docs`
#                    est servi sous ce préfixe (server.servlet.context-path) — sans lui, la
#                    tentative 1 échoue en 404 même app lancée dès qu'un projet en définit un.

set -euo pipefail

MODULE_DIR="${1:?Usage: generate-openapi.sh <module-dir> [port] [context-path]}"
PORT="${2:-8080}"
CONTEXT_PATH="${3:-}"

ROOT_DIR="$(pwd)"
OUT_DIR="$ROOT_DIR/.tmp-api-sync"
mkdir -p "$OUT_DIR"

URL="http://localhost:${PORT}${CONTEXT_PATH}/v3/api-docs"

echo "→ Tentative 1 : instance déjà lancée (${URL})"
if curl -sf "$URL" -o "$OUT_DIR/openapi.json"; then
  echo "✓ Spec récupéré depuis l'app en cours d'exécution (${URL})."
  exit 0
fi
rm -f "$OUT_DIR/openapi.json"

echo "→ Tentative 2 : génération via springdoc-openapi-maven-plugin (sans lancer toute l'app)"
if [ -f "$MODULE_DIR/pom.xml" ] && grep -q "springdoc-openapi-maven-plugin" "$MODULE_DIR/pom.xml"; then
  (
    cd "$MODULE_DIR"
    mvn -q springdoc-openapi:generate \
      -Dspringdoc.outputDir="$OUT_DIR" \
      -Dspringdoc.outputFileName=openapi.json
  )
  if [ -f "$OUT_DIR/openapi.json" ]; then
    echo "✓ Spec généré via le plugin Maven (sans app lancée)."
    exit 0
  fi
fi

echo "✗ Impossible de générer le spec automatiquement."
echo "  → Soit lance l'app en local sur le port ${PORT} (contexte ${CONTEXT_PATH:-<aucun>}),"
echo "  → soit ajoute springdoc-openapi-maven-plugin au pom.xml de ${MODULE_DIR}."
exit 1

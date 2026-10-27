#!/usr/bin/env bash
# Génère un brouillon de release notes en Markdown pour la plage de commits ${FROM_REF}..${TO_REF},
# par parsing déterministe des commits conventionnels — aucun appel API.
#
# Remplace l'appel Codex de meta/tickets/15/ (voir meta/tickets/20/analyse.md) : les règles
# ci-dessous reprennent à l'identique celles qui étaient données à Codex dans l'ancien
# prompt.md (catégories, détection de breaking change, commit non conventionnel listé tel quel).
#
# Usage :
#   generate.sh <from_ref> <to_ref>
#   FROM_REF=<from_ref> TO_REF=<to_ref> generate.sh
#
# Écrit le résultat sur stdout.

set -euo pipefail

from_ref="${1:-${FROM_REF:-}}"
to_ref="${2:-${TO_REF:-HEAD}}"

if [ -z "$from_ref" ]; then
  echo "usage: generate.sh <from_ref> <to_ref>" >&2
  exit 1
fi

heading="## ${to_ref} — $(date -u +%Y-%m-%d)"

count="$(git rev-list --no-merges --count "${from_ref}..${to_ref}")"
if [ "$count" -eq 0 ]; then
  printf '%s\n\nAucun changement dans cette plage.\n' "$heading"
  exit 0
fi

declare -a feat=() fix=() docs=() autres=() breaking=()

# Regex en variable plutôt qu'inline dans le [[ =~ ]] : bash 3.2 (macOS) mal-parse des
# parenthèses littérales écrites directement dans la condition.
commit_re='^([a-zA-Z]+)(\(([^)]+)\))?(!)?:[[:space:]]*(.*)$'

# Une entrée par commit, séparée par NUL (-z) pour tolérer un corps de commit multi-ligne ;
# %x1f sépare sujet et corps au sein d'une même entrée. Lu par process substitution (pas
# `$(...)` : bash tronque au premier octet NUL en capturant dans une variable) et sans pipe
# (pour que les tableaux remplis dans la boucle survivent en dehors du sous-shell).
while IFS=$'\x1f' read -r -d '' subject body; do
  type='' scope='' bang='' summary=''
  if [[ "$subject" =~ $commit_re ]]; then
    type="${BASH_REMATCH[1]}"
    scope="${BASH_REMATCH[3]}"
    bang="${BASH_REMATCH[4]}"
    summary="${BASH_REMATCH[5]}"
  fi

  if [ -n "$scope" ]; then
    line="- (${scope}) ${summary}"
  elif [ -n "$type" ]; then
    line="- ${summary}"
  else
    # Pas de préfixe conventionnel reconnu — le commit va tel quel sous "Autres", jamais reclassé
    # à la devinette.
    line="- ${subject}"
  fi

  is_breaking=0
  [ -n "$bang" ] && is_breaking=1
  [[ "$body" == *'BREAKING CHANGE:'* ]] && is_breaking=1
  [ "$is_breaking" = 1 ] && breaking+=("$line")

  case "$type" in
    feat) feat+=("$line") ;;
    fix) fix+=("$line") ;;
    docs) docs+=("$line") ;;
    *) autres+=("$line") ;;
  esac
done < <(git log "${from_ref}..${to_ref}" --no-merges -z --format='%s%x1f%b')

out="$heading"$'\n'

if [ "${#breaking[@]}" -gt 0 ]; then
  out+=$'\n### Breaking changes\n\n'
  out+=$(printf '%s\n' "${breaking[@]}")
  out+=$'\n'
fi

emit_section() {
  local title="$1"
  shift
  out+=$'\n### '"$title"$'\n\n'
  out+=$(printf '%s\n' "$@")
  out+=$'\n'
}

# Garde de longueur avant d'expander "${arr[@]}" : sous `set -u`, bash 3.2 (macOS) lève
# "unbound variable" sur un tableau déclaré vide si on l'expanse malgré tout.
[ "${#feat[@]}" -gt 0 ] && emit_section "Fonctionnalités" "${feat[@]}"
[ "${#fix[@]}" -gt 0 ] && emit_section "Corrections" "${fix[@]}"
[ "${#docs[@]}" -gt 0 ] && emit_section "Documentation" "${docs[@]}"
[ "${#autres[@]}" -gt 0 ] && emit_section "Autres" "${autres[@]}"

printf '%s' "$out"

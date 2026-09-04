Reconstruit depuis la session qui l'a déclenché — à recouper avec le ticket réel
([issue #22](https://github.com/zYmMiJ/ai-playbook/issues/22)) dès qu'accessible.

## Contexte

En traitant [#20](https://github.com/zYmMiJ/ai-playbook/issues/20) (remplacement de Codex par un
script déterministe pour les release notes), la section `README.md` correspondante a accumulé, au
fil de plusieurs éditions successives dans la même session, du contenu qui n'aurait jamais dû y
atterrir :

> Aucun workflow actif ne l'utilise aujourd'hui : la génération des release notes en CI, son seul
> cas d'usage jusqu'ici (issue #15 / meta/tickets/15/), est passée à un script déterministe — voir
> issue #20 / meta/tickets/20/, la tâche n'a jamais eu besoin d'un modèle. [...]

Ce paragraphe explique **pourquoi** une décision a été prise (comparaison Codex vs script,
chronologie #15 → #20) plutôt que de décrire l'état actuel. Cette information existe déjà, en
détail, dans `meta/tickets/15/analyse.md` et `meta/tickets/20/analyse.md` — sa place légitime. Le
lien vers ces tickets existe déjà ailleurs, dans la colonne "Source" du tableau Inventaire (ligne
`release-notes`), qui est la convention déjà suivie par toutes les autres lignes du tableau.

## Problème

`CLAUDE.md` énonce déjà l'intention ("Le `README.md` reste le pitch/la référence pour tout lecteur
— structure, inventaire, origine") mais ne la formule pas comme un critère vérifiable au moment
d'écrire. Rien n'a arrêté la dérive en session : chaque édition individuelle semblait raisonnable
("juste une phrase de contexte en plus"), l'accumulation ne l'était plus.

Root cause : pas d'erreur d'un seul coup, mais l'absence d'un critère explicite à appliquer *au
moment d'écrire* une section README, faute duquel la aide (Claude Code) comble par défaut avec du
contexte narratif, plus naturel à produire qu'un résumé strictement factuel.

## Options considérées

1. **Hook technique qui détecte un README "trop narratif"** — rejeté : pas d'heuristique fiable
   (compter les liens `issue #`, la longueur de paragraphe... tout est contournable ou trop
   restrictif) pour un problème qui est une question de *nature* du contenu, pas de forme
   mesurable. Cohérent avec `rules/hooks.md` : un hook vaut pour un contrôle *toujours* vérifiable
   mécaniquement, pas pour un jugement éditorial.
2. **Règle écrite dans `CLAUDE.md`, appliquée à la relecture** — retenu. Le README n'est édité que
   par Claude Code sur ce repo (voir workflow "traiter un ticket de bout en bout") ; une règle
   explicite dans le fichier déjà chargé à chaque session est le bon niveau, cohérent avec le reste
   de `CLAUDE.md` (indicatif, suivi en pratique, pas un hook bloquant).
3. **Généraliser la règle dans `rules/`** (pour qu'un autre projet copié depuis ce repo en bénéficie
   aussi) — écarté pour ce ticket : le principe ("README = état actuel, pas de narratif de
   décision") est probablement transposable, mais formuler une version générique demanderait de la
   détacher du contexte précis de ce repo (tableau Inventaire, `meta/tickets/`) sans exemple concret
   sous la main pour la valider ailleurs. À reconsidérer une fois la règle éprouvée ici — pas
   introduite prématurément dans `rules/general-coding.md`.

## Deuxième repérage, en cadrant la règle

En rédigeant ce ticket, une deuxième dérive du même README a été repérée et confirmée avec
l'utilisateur : une sous-section `### Release notes en CI` (ajoutée pendant #20) décrivait la
mécanique d'un item précis du tableau Inventaire (`workflow_dispatch`, `generate.sh`, chemin du
workflow) — alors que ce même détail existe déjà dans la ligne `release-notes` du tableau *et* dans
`meta/automation/release-notes/README.md`, qui en est la référence complète. Aucun autre skill/
agent/rule/automation du tableau n'a de sous-section dédiée dans le corps du README — cette
sous-section rompait ce pattern sans raison. Supprimée (pas de version allégée conservée : le
tableau + le README dédié couvrent déjà le besoin).

Ça affine la règle : le tableau **Inventaire est le seul niveau de détail par item** dans ce README
— pas de sous-section dédiée à un skill/agent/rule/automation précis dans le corps du texte, même
allégée. La seule exception légitime est la section "AI tools" (Claude Code / OpenAI Codex) : elle
décrit les deux **moteurs transverses** du repo (un niveau au-dessus des items du tableau, pas un
item du tableau lui-même) — confirmée à garder telle quelle par l'utilisateur, à condition de
rester au niveau "rôle du moteur" et de ne jamais glisser vers le "pourquoi ce choix a été fait"
(la dérive corrigée dans la section précédente).

## Décision

Formaliser dans `CLAUDE.md` deux critères explicites (pas de narratif de décision ; pas de
sous-section dédiée à un item du tableau Inventaire hors "AI tools") et un test rapide de relecture,
sans nouveau hook ni généralisation vers `rules/` pour l'instant (voir Options ci-dessus).

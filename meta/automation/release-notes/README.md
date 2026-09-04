# Release notes en CI

Génère un brouillon de release notes pour une plage de commits, en CI, par un **script
déterministe** — aucun appel API, aucun secret requis, aucun coût. Voir
[`meta/tickets/20/`](../../tickets/20/) pour le contexte de cette décision : la génération repose
uniquement sur des commits conventionnels (`type(scope): résumé`, voir
[`writing-good-commits`](../../../skills/writing-good-commits/SKILL.md)) et des plages Git Flow
([`git-flow.md`](../../../rules/git-flow.md)) — un LLM n'apportait rien à cette tâche mécanique
(voir [issue #15](https://github.com/zYmMiJ/ai-playbook/issues/15) →
[issue #20](https://github.com/zYmMiJ/ai-playbook/issues/20)).

## Déclencher le workflow

`Actions` → `Release notes` → `Run workflow`, avec en entrée :

- `to_ref` : ref/tag de fin (défaut `HEAD`) ;
- `from_ref` : ref/tag de départ, exclu (laisser vide pour prendre automatiquement le dernier tag
  avant `to_ref` — échoue explicitement si aucun tag n'est trouvé).

Le résultat (`release-notes.md`) est disponible dans l'onglet `Summary` du run, section
`Artifacts`, une fois le job terminé.

## Tester en local

Le script est autonome, testable sans CI :

```bash
meta/automation/release-notes/generate.sh <from_ref> <to_ref>
# ou
FROM_REF=<from_ref> TO_REF=<to_ref> meta/automation/release-notes/generate.sh
```

## Règles de génération

Reprises de l'ancien prompt Codex (#15), maintenant encodées directement dans
[`generate.sh`](generate.sh) plutôt que décrites en langage naturel pour un modèle :

- Catégories, dans cet ordre, catégorie vide omise : `Fonctionnalités` (`feat`), `Corrections`
  (`fix`), `Documentation` (`docs`), `Autres` (tout le reste — `refactor`, `build`, `chore`,
  `test`, `ci`, un type non reconnu...).
- Un commit sans forme `type: résumé` reconnaissable est listé tel quel (sujet complet, non
  reformulé) sous `Autres`.
- Un `scope` de commit (ex. `(15)`, `(structure)`) est conservé entre parenthèses devant le résumé.
- Breaking change détecté uniquement sur marqueur explicite — `!` avant les deux-points du header,
  ou ligne `BREAKING CHANGE:` dans le corps — jamais par inférence. Listé à la fois dans une section
  `Breaking changes` en tête et dans sa catégorie normale.
- Plage sans commit (hors merges) → le fichier de sortie l'indique explicitement plutôt que d'être
  vide ou d'inventer du contenu.

## Retirer ce mécanisme

Supprimer `.github/workflows/release-notes.yml` et `meta/automation/release-notes/`. Aucun autre
fichier du repo n'en dépend (la plomberie Codex générale, si elle existe encore, est indépendante —
voir [`meta/automation/README.md`](../README.md)).

# Persistence (persistance)

| Situation | Résultat |
|---|---|
| cible de Story explicite | l'utiliser |
| Stories déjà existantes | conserver leur support et leurs identités |
| Epic parent | en dériver le support ; ne jamais écrire le contenu de la Story dans l'Epic |
| plusieurs cibles possibles restent | demander à l'utilisateur |
| aucune cible ne reste | demander session ou Markdown ; ne pas signaler l'absence de cible comme une erreur |
| une Story équivalente existe déjà | la réutiliser ou la mettre à jour |
| aucune correspondance | créer une nouvelle Story |

Utiliser les champs natifs du tracker quand ils sont supportés (si ce skill est branché à un
tracker externe — hors périmètre de base) ; sinon des ids explicites ou des chemins relatifs au
projet. Ne jamais dupliquer une même Story sur deux supports différents.

Écrire chaque Story Markdown dans son propre fichier `docs/backlog/stories/<slug>.md`, le titre en
kebab-case. C'est un choix par défaut, pas une convention imposée par
[`../../../rules/docs-structure.md`](../../../rules/docs-structure.md) — ce rule ne prévoit pas de
dossier `backlog/` par défaut ; n'ajouter ce dossier que si le projet en a un besoin réel constaté.

Markdown est le seul support que ce skill écrit par défaut. Brancher un autre support (Jira,
Linear...) est une intégration propre à chaque projet, à documenter séparément si elle existe.

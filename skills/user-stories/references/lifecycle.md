# Lifecycle (statuts)

`status` vit dans le frontmatter du fichier de Story.

| Statut | Signification | Peut évoluer vers |
|---|---|---|
| `proposed` | capturée mais pas encore prête | `ready`, `cancelled` |
| `ready` | acceptée pour livraison | `proposed`, `in-progress`, `cancelled` |
| `in-progress` | en cours de livraison | `ready`, `done`, `cancelled` |
| `done` | acceptation validée, et Definition of Done du projet si elle existe | terminal |
| `cancelled` | valeur plus poursuivie, raison sous `## Cancellation` | terminal |

Une Story qui change de statut ne décide rien pour son Epic parent, ni pour le travail qui lui est
rattaché en enfant : proposer leur sort en même temps, ne jamais le déduire automatiquement.

Un besoin qui change crée une nouvelle Story et préserve celle déjà terminée — ne pas réécrire une
Story `done`/`cancelled` pour lui faire porter un besoin différent.

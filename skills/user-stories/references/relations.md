# Relations

Stocker chaque relation une seule fois, sur son propriétaire ; `related_to` sur l'artefact dont le
chemin trie en premier.

Les liens inverses ne sont jamais stockés (`children`, `blocked_by`, `superseded_by`) — un lecteur
les déduit depuis le lien direct correspondant.

| Champ | Signification sur une Story |
|---|---|
| `source` | origine stable (ticket, doc, échange) |
| `parent` | Epic propriétaire |
| `depends_on` | prédécesseurs requis, un ou plusieurs |
| `related_to` | relation additive, une ou plusieurs |
| `supersedes` | artefacts remplacés, en priorité ceux à statut terminal ; un ou plusieurs |
| `order` | position autorisée parmi les Stories de son parent |
| `estimate` | effort autorisé selon l'échelle du projet |

Une Story ne porte aucun autre champ. Une Story indépendante omet `parent` — l'intention doit être
explicite, pas une omission par oubli. Quand un blocage se résout, préserver la relation et
réévaluer les écarts, l'estimation, l'ordre et l'Epic parent affectés. Le statut d'un enfant ne
termine jamais son Epic parent sans preuve de succès propre à l'Epic.

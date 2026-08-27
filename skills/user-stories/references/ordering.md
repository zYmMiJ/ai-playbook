# Ordering (ordonnancement)

N'utiliser que des signaux appuyés par la source ou le projet :

| Signal | Effet |
|---|---|
| prédécesseur requis | passe avant la Story qui en dépend |
| item bloqué | reste derrière son bloquant |
| valeur utilisateur plus proche dans le temps | peut avancer |
| coût ou obligation urgente | peut avancer |
| apprentissage ou réduction de risque décisifs | peut avancer |
| valeur ou urgence non appuyée par une preuve | n'a aucun poids d'ordonnancement |

Utiliser la méthode d'ordonnancement documentée dans le `CLAUDE.md` du projet si elle existe.
Sinon, proposer un ordre relatif motivé et laisser l'utilisateur (ou l'autorité que l'appelant a
explicitement donnée) trancher. Ne jamais fabriquer un score numérique sans preuve derrière.

# Handoffs (renvois)

Signaler à l'utilisateur ce qui a été observé et le type de ticket qui correspondrait mieux, puis
s'arrêter. Ne jamais créer ce type de ticket soi-même, ne jamais écrire en dehors d'une Story.

| Observé | Type qui correspondrait | Retour |
|---|---|---|
| résultat nécessitant plusieurs tranches livrables | Epic | signalement seulement ; aucune Story créée pour ce lot |
| travail sans valeur utilisateur indépendante | Task/tâche technique | signalement seulement |
| décalage produit observé (bug) | Defect/défaut | signalement seulement |
| incertitude bloquant la maturité | Spike | l'évaluation (`evaluer`) reprend après son résultat |
| aucune correspondance | rien | rapporter ce qui a été observé, sans forcer une Story |

> Ce repo n'a pas de skill dédié `epic`/`task`/`defect`/`spike` à ce jour (contrairement à la
> source `aidd-pm`, qui en a un pour chacun) — le renvoi reste donc un simple signalement en texte,
> jamais une invocation d'un autre skill.

# Vérification exécutable

Claude s'arrête quand le travail **a l'air** fini. Sans rien à lancer qui réponde « passe / ne passe
pas », « a l'air fini » est son seul critère — et c'est l'humain qui joue le rôle de suite de tests.
Lui donner un check exécutable est le levier le plus rentable d'une session : il change, lance le
check, lit la sortie, corrige, relance, sans attendre qu'on remarque l'erreur.

Fonctionnalités vérifiées dans la doc officielle Claude Code (`best-practices`, `goal`, `hooks`,
`code-review-local`, `skills`) le 2026-11-26.

## Ce qui compte comme check

N'importe quoi dont Claude peut lire le résultat :

- un fichier de test, ou un filtre de tests ciblés sur les fichiers touchés ;
- le code de sortie d'un build / d'un typecheck ;
- un linter ;
- un script qui compare une sortie à une fixture (`diff` attendu / obtenu) ;
- une capture d'écran du navigateur à côté de la maquette.

Si le projet en a déjà un, **la commande qui le lance est la ligne la plus utile de son
`CLAUDE.md`** — la commande seule, pas « pense à vérifier ».

## Quatre niveaux de contrainte

Du plus souple au plus strict ; monter d'un niveau seulement quand le précédent ne suffit plus.

| Niveau | Comment | Qui décide que c'est fini | Quand |
|---|---|---|---|
| Consigne | « lance les tests auth après, continue jusqu'à ce qu'ils passent » | Claude lui-même | Par défaut, toute tâche, sans setup |
| Goal | `/goal tous les tests de tests/auth passent et le lint est propre` | Un modèle séparé, après chaque tour | Long travail en arrière-plan qui s'arrête sur un résumé d'étape |
| Hook `Stop` | Script qui sort en code 2 tant que le check échoue | Le harness (déterministe) | Check qui doit passer **à chaque fois**, toutes sessions — gabarit dans [`hooks.md`](hooks.md#gabarit--bloquer-la-fin-du-tour-tant-que-le-check-échoue) |
| Relecteur vierge | `/code-review`, ou un agent comme [`plan-compliance-reviewer`](../agents/plan-compliance-reviewer.md) | Quelqu'un qui n'a pas vu le raisonnement | Avant de committer un changement non trivial |

`/goal` ne vaut que pour la session en cours (une goal à la fois) ; un hook `Stop` vit dans les
settings et s'applique à toutes les sessions de son scope.

## Exiger la preuve, pas l'affirmation

- Demander **la commande lancée et sa sortie** (ou la capture). « Tous les tests passent » seul ne
  dit presque rien ; lire la sortie va plus vite que relancer soi-même — et pour une session non
  surveillée, c'est la seule trace.
- « Ça compile » n'est pas « ça marche » : un build vert ne prouve que la syntaxe et les types.
  Pour un comportement, il faut un test qui l'exerce, ou lancer l'application — le skill intégré
  `/verify` construit et lance l'app pour regarder le résultat réel.
- Un check qui passe ne prouve que ce qu'il couvre (voir [`general-coding.md`](general-coding.md#revue)) :
  dire explicitement ce qui n'a pas été vérifié.

## Tests en cours d'implémentation

Pendant l'itération : **tests ciblés seulement**, lancés en arrière-plan pour ne pas bloquer la
session ; la suite complète reste réservée à la validation finale (voir
[`context-efficiency.md`](context-efficiency.md#tests)).

## Articulation

- Une Definition of Done (checklist de clôture d'un ticket) dit **quoi** vérifier avant de clore ;
  ce rule dit **comment** rendre chaque point vérifiable — la checklist y renvoie plutôt que de le
  redire.
- Dans [`start-ticket`](../skills/start-ticket/SKILL.md), la commande de vérification est fixée dans
  `plan.md` et sert de critère de fin d'implémentation.

# Refactor review

À utiliser avant de lancer un refactor qui touche plusieurs fichiers, pour forcer un plan
vérifiable plutôt qu'une édition directe.

```
Avant d'éditer quoi que ce soit : liste les fichiers impactés par ce refactor et le changement
attendu dans chacun. Donne un critère vérifiable de succès (ex. "aucune référence à <ancien nom>
ne subsiste", "build + lint passent"). N'édite qu'après validation de ce plan.

Refactor demandé : <décrire le refactor>
```

## Pourquoi

- Force à énumérer l'impact réel avant d'écrire du code — évite les refactors à moitié faits parce
  que la moitié des call sites n'avait pas été repérée.
- Le critère vérifiable donne une condition d'arrêt claire, à toi et à l'IA — sans ça la revue de
  fin de refactor est subjective.

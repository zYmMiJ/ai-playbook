# Spec interview

À utiliser avant une fonctionnalité trop grosse ou trop floue pour un plan direct : Claude
interviewe jusqu'à pouvoir écrire un `SPEC.md` autonome, puis l'implémentation se fait **dans une
nouvelle session** à partir de ce seul fichier.

```
Je veux <décrire la fonctionnalité en une ou deux phrases>, mais je ne l'ai pas encore pensée en
détail. Interviewe-moi avec AskUserQuestion, une question à la fois, en proposant des options quand
c'est possible, jusqu'à pouvoir écrire une spec complète. Explore le code autant que nécessaire pour
poser des questions précises, mais ne modifie rien.

Puis écris SPEC.md, lisible sans cette conversation :
- Objectif : le besoin, en deux ou trois phrases.
- Fichiers touchés : chemin + ce qui y change.
- Interfaces : signatures, contrats, formats de données nouveaux ou modifiés.
- Cas limites, chacun avec le comportement attendu.
- Hors périmètre : ce qu'on ne fait pas, explicitement.
- Vérification de bout en bout : la ou les commandes qui passent quand c'est fini, et le
  résultat attendu.

Ne commence pas l'implémentation.
```

Ensuite : `/clear` (ou une nouvelle session), puis
`Implémente SPEC.md. C'est fini quand la section « Vérification » passe ; montre-moi la sortie.`

## Pourquoi

- L'interview fait remonter les décisions avant qu'elles ne soient prises implicitement dans le
  code ; les questions à choix vont plus vite qu'une description libre.
- La nouvelle session démarre sans l'historique de l'interview : le `SPEC.md` doit se suffire, ce
  qui révèle ce qui manque. Et la section « Vérification » donne la condition d'arrêt (voir
  [`../rules/verification.md`](../rules/verification.md)).
- La spec sert ensuite de référence pour la revue :
  [`../agents/plan-compliance-reviewer.md`](../agents/plan-compliance-reviewer.md).

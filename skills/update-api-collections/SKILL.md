---
name: update-api-collections
description: >
  Régénère et synchronise les collections Bruno et Postman avec les endpoints REST actuels d'un
  backend Spring Boot/JHipster, à partir de son spec OpenAPI (springdoc). Utiliser cette skill dès
  que l'utilisateur demande de mettre à jour, synchroniser, régénérer ou rafraîchir ses collections
  API / Bruno / Postman, ou dit avoir modifié/ajouté/supprimé des endpoints et vouloir répercuter
  le changement dans les collections de test.
---

# Update API Collections (Bruno + Postman)

Garde les collections Bruno et Postman alignées avec les endpoints REST réels du backend, sans
écraser ce qui a été personnalisé à la main (auth, variables d'environnement, scripts
pre-request/tests, exemples).

Principe : le spec OpenAPI généré par springdoc est la source de vérité. Postman sait se
synchroniser nativement dessus pour les ajouts/modifications — pas pour les suppressions (voir
étape 2). Bruno ne sait rien synchroniser du tout — cette étape demande une réconciliation
manuelle faite avec jugement, pas juste un script.

> **À compléter par projet** avant premier usage, dans une section "Contexte de ce projet" ici
> même : périmètre du spec OpenAPI si restreint (`springdoc.packages-to-scan`), organisation propre
> de la collection Bruno (par ressource ? par mode d'auth ? — change ce que "1 endpoint = 1
> fichier" veut dire à l'étape 3), dossiers/requêtes qui ne viennent jamais du spec et ne doivent
> jamais être régénérés, contraintes locales (`bru` absent du `PATH`, plugin Maven absent du
> `pom.xml`, bugs connus de génération du spec...). Sans cette section, les étapes 1 et 3
> ci-dessous restent correctes en principe mais demandent plus de jugement à l'exécution.

## 0. Configuration (une seule fois par projet)

Chercher `.claude/api-sync.env` à la racine du repo.

- **S'il existe** : le charger (`source .claude/api-sync.env`) et passer à l'étape 1.
- **S'il n'existe pas** : le déduire du repo, ou demander à l'utilisateur si ambigu, puis le créer avec ces 5 valeurs :
  - `MODULE_DIR` : dossier du module Spring Boot (contient un `pom.xml` avec la dépendance/plugin `springdoc-openapi`)
  - `PORT` : port sur lequel l'app tourne en local (défaut `8080`)
  - `CONTEXT_PATH` : context-path servlet de l'app (ex. `/api`), vide si aucun
  - `BRUNO_DIR` : dossier de la collection Bruno existante (contient un `bruno.json`)
  - `POSTMAN_FILE` : chemin du fichier `*.postman_collection.json` existant

  Écrire ces valeurs dans `.claude/api-sync.env` (format `KEY=value`, une par ligne) pour que les prochains runs — et les collègues qui clonent le repo — n'aient pas à reconfigurer. Committer ce fichier. Ajouter `.tmp-api-sync/` au `.gitignore` s'il n'y est pas déjà.

## 1. Générer le spec OpenAPI à jour

```bash
bash .claude/skills/update-api-collections/scripts/generate-openapi.sh "$MODULE_DIR" "$PORT" "$CONTEXT_PATH"
```

Produit `.tmp-api-sync/openapi.json`. Le script essaie dans l'ordre : une instance déjà lancée en local, puis `springdoc-openapi-maven-plugin` (génération sans lancer toute l'app). S'il échoue, expliquer clairement pourquoi à l'utilisateur (app pas lancée / plugin absent du `pom.xml`) et proposer une solution avant de continuer — ne pas inventer un spec.

## 2. Postman — sync natif pour les ajouts/modifications, suppression manuelle

`openapi-to-postmanv2` sait fusionner un spec avec une collection existante sans perdre l'auth, les variables ou les scripts déjà en place, pour les endpoints **ajoutés ou modifiés** :

```bash
npx --yes openapi-to-postmanv2 \
  -s .tmp-api-sync/openapi.json \
  --sync "$POSTMAN_FILE" \
  --sync-options syncExamples=true \
  -o "$POSTMAN_FILE" -p
```

**`--sync` ne supprime pas les endpoints disparus du spec** — vérifié empiriquement (endpoint retiré puis resync : toujours présent dans le fichier après coup). Après le sync, comparer la liste des chemins du spec (`.tmp-api-sync/openapi.json`) à celle de la collection résultante — même principe que l'étape 3 pour Bruno : **ne pas supprimer automatiquement**, lister ces endpoints dans le rapport final (étape 4) pour que l'utilisateur décide. Ne les retirer à la main (et leur dossier parent s'il devient vide) que si l'utilisateur confirme.

Le diff Git du fichier montre ensuite ce qui a changé — pas besoin de tout relire, mais la suppression, elle, ne se fait jamais toute seule.

## 3. Bruno — pas de sync natif, réconciliation à faire soi-même

Le CLI Bruno (`bru import openapi`) ne sait que créer une collection **neuve** dans un dossier — il n'existe pas d'équivalent `--sync`. Ne jamais écrire directement dans `$BRUNO_DIR` à cette étape : générer d'abord une version de référence dans un dossier scratch.

```bash
npx --yes @usebruno/cli import openapi \
  --source .tmp-api-sync/openapi.json \
  --output .tmp-api-sync/bruno-fresh \
  --collection-format=bru
```

(Si `bru` n'est pas sur le `PATH`, utiliser `npx @usebruno/cli`, pas la commande nue.)

Puis comparer `.tmp-api-sync/bruno-fresh/` avec `$BRUNO_DIR`, requête par requête. Utiliser **méthode + chemin** comme clé de correspondance, pas le nom de fichier/dossier — les noms générés par `bru import` ne correspondent pas forcément à ceux déjà en place dans la collection existante :

- **Endpoint nouveau** → copier le `.bru` généré dans `$BRUNO_DIR`, dans le dossier logique correspondant (suivre l'arborescence déjà utilisée dans la collection existante, pas celle générée par l'import — voir "Contexte de ce projet" en tête de fichier si l'organisation n'est pas par ressource).
- **Endpoint modifié** (params, body, query, path) → éditer uniquement les blocs `params:query`, `params:path`, `body`, `url` du fichier existant. Ne jamais toucher aux blocs déjà présents s'ils existent : `auth`, `headers` custom, `script:pre-request`, `script:post-response`, `tests`, `vars:pre-request`.
- **Endpoint disparu du spec actuel** → ne pas supprimer automatiquement. Le lister dans le rapport final pour que l'utilisateur décide.
- Ne jamais toucher `$BRUNO_DIR/environments/*.bru`.

## 4. Rapport final (toujours, même si rien n'a changé)

Résumer clairement, sans détail d'implémentation :
- Endpoints ajoutés (liste)
- Endpoints mis à jour et ce qui a changé pour chacun
- Endpoints présents dans les collections mais absents du spec actuel (à vérifier par l'utilisateur, non supprimés)

Ne jamais committer automatiquement. L'utilisateur relit le diff Git et commit lui-même.

## 5. Nettoyage

Supprimer `.tmp-api-sync/` en fin de run (il ne doit jamais être committé). Garder uniquement `.claude/api-sync.env`, qui lui doit être committé.

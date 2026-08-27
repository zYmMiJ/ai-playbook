# Slicing (découpage)

Choisir le plus petit découpage qui préserve une valeur observable.

| Signal | Découpage utile |
|---|---|
| workflow utilisateur | une étape utile ou un chemin de bout en bout minimal |
| règles métier | commencer par une seule règle ou variation |
| variation de données | commencer par un cas de données significatif |
| opérations | séparer création, lecture, mise à jour, suppression quand chacune a sa propre valeur |
| candidat purement exploratoire | séparer en Spike |
| plusieurs résultats indépendants | séparer en Epics |

Éviter de découper par couche technique (frontend, backend, base de données, composant, service)
ou par phase de livraison — un découpage technique n'est jamais une Story.

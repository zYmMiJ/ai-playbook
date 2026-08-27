# Readiness (maturité) — critères INVEST

| INVEST | Passe quand |
|---|---|
| Independent (indépendante) | évite un couplage artificiel et nomme les dépendances réellement inévitables |
| Negotiable (négociable) | énonce le besoin sans figer la solution technique |
| Valuable (porteuse de valeur) | la source nomme un effet au-delà du comportement demandé |
| Estimable | peut être chiffrée, ou le projet ne pratique pas l'estimation |
| Small (petite) | tient dans la limite de livraison du projet (un sprint, une itération...) |
| Testable | l'acceptation est observable objectivement |

L'acceptation est la propre preuve de la Story : la satisfaire est ce qui fait passer son statut à
`done`. Les critères de qualité que toute l'équipe applique (lint, couverture minimale...)
relèvent de la Definition of Done du projet, jamais de l'acceptation d'une Story précise.

Une Story est `ready` quand INVEST passe entièrement, l'acceptation est complète, les relations
sont connues, et aucune question bloquante ne reste ouverte. Sinon elle reste `proposed` : une
inconnue bloquante devient un Spike (signalé, voir la note d'adaptation du `SKILL.md`), tout le
reste n'est simplement pas encore prêt à être écrit. La persistance n'exige pas d'être `ready`.

# noise-sonar

**Simulation d'un sonar à bruit**

*Projet de TAN Télécom Nancy 2017*

## Execute

Lancez Matlab puis charger le script **sonar.m**, changez la valeur des variables si vous le souhaitez ou laissez celles par défaut. Cliquez ensuite sur *Run*.

## Marche à suivre (d'après A. Parodi)

Utiliser le chapitre **5** du polycopié.

L'idée est de simuler un sonar qui est capable de fonctionner malgré le bruit ambiant *sans de faire détecter et encore moins localiser*,
et qui fournit la *réponse impulsionnelle de l'espace devant lui*, dont le maximum correspond à peu près à la position du submersible.

**Simulation de l'environnement:**
Simulation du bruit ambiant: signal aléatoire de densité de probabilité gaussienne et de densité spectrale de puissance à choisir.
On utilise un générateur aléatoire dont la sortie est bruit blanc (donc dont les échantillons successifs sont statistiquement indépendants) envoyés vers un filtre
dont la réponse fréquentielle correspond à la racine carrée de la densité spectrale de puissance désirée.

Le générateur aléatoire est gaussien, d'écart-type (donc de puissance) réglable.
Le filtre peut être un passe-bas pour commencer, avec fréquence de coupure réglable.

**Décor:**
On suppose que devant le sonar on a un ensemble de réflecteurs à des distances d diverses avec un coefficient de réflection r plus ou moins fort:
ceci peut être exprimé par une fonction r(d) où d est la distance relativement au sonar.
Elle peut être obtenue en sommant des fonctions diverses, par exemple des diracs à des distances diverses d0 (en numérique ro . delta(d-d0) ), cloches plus ou moins élevées et épaisses etc.

On peut ainsi simuler un banc de poissons avec un submersible etc.

**Simulation de l'émetteur du sonar:**
Le sonar envoie une onde sonore de durée T constituée d'un bruit blanc filtré par un passe-bande de fréquence centrale f0 et de largeur W;
dans un premier temps on utilisera un cas particulier où le filtre est un passe-bas de fréquence de coupure fc = W avec f0 = W/2.
le bruit avant filtrage peut être de densité de probabilité gaussienne, et d'écart-type (donc de puissance moyenne qui en est le carré) réglable.

Il faut que l'intensité du signal provenant du sonar soit très faible devant l'intensité du bruit ambiant pour ne pas se faire détecter.

**Simulation de l'interaction entre signal sonar et environnement:**
Chaque point d'environnement renvoie un signal proportionnel au signal sonar en ce point et à la réflexion de l'environnement en ce point;
A priori il faudrait tenir compte de l'affaiblissement en 1/d (path loss ...) du signal aussi bien de l'onde sonar incidente à partir du sonar, que de celle réfléchie à partir du point de réflexion;
ceci peut être omis dans un premier temps.

le signal reçu par par le récepteur du  sonar est la somme des signaux reçus en chaque point réfléchissant et du bruit ambiant passé dans un filtre passe-bande identique à celui
permettant de simuler le signal envoyé.

Le but est d'estimer la fonction r(d) en effectuant l'intercorrélation entre le signal reçu par le sonar et le signal envoyé.

Si on tient compte du path-loss c'est plus compliqué: il faut traiter le signal envoyé et revenant avec un gain dépendant du temps.

_*Suite*_

Pour fixer les idées, la fréquence maximale contenue dans les signaux sonar est fmax = f0 + W/2 = 100 kHz, d'où vous déduisez la fréquence d'échantillonnage.

La distance maximale dmax = 3km, la vitesse c des ondes dans l'eau est indiquée dans le premier polycopié,
T sera choisi de manière appropriée avec ces données.

La fonction d'intercorrélation à utiliser est celle qualifiée de "simplifiée" r(tau) dans le polycopié puisque le signal reçu est de durée finie; pour l'implémentation numérique,
elle peut s'exprimer avec une convolution, et le passage au numérique utilise simplement la correspondance entre convolution analogique et numérique.
La taille des suites à intercorréler est très grande et donc une FFT est nécessaire pour faire le calcul: vous pouvez utiliser la convolution de matlab.

Pour éviter la confusion avec la fonction de réflexion r(d), vous pouvez appeler l'intercorrélation simplifiée gamma(tau).
Vous pouvez modéliser mathématiquement le signal reçu y(t)  à partir de la fonction de réflexion r(d), du signal envoyé x(t) et du bruit ambiant n(t).

Ensuite calculez mathématiquement l'intercorrélation gamma(tau) entre x(t) et y(t)
à partir de la fonction de réflexion r(d) et des intercorrélations avec le bruit ambiiant (qui devrait s'affaiblir fortement)
et l'autocorrélation du signal envoyé qui est un pic de largeur en principe très faible relativement aux détails de r(d).

Attention, il y avait une coquille: l'affaiblissement dépend de 1/d avec d distance entre source et récepteur et pas 1/r. *(corrigé)*

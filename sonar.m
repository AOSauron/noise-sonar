%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Simulateur de sonar à bruit                 %
%                                                            %
%       Auteurs : G.Garcia  -  @Projet-TAN-TNCY-2017         %
%                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Variables de la simulation %%
T = 120000;  % Durée d'envoi d'une onde sonore <=> nb de points.
DSP = 40;    % Densité Spectrale de Puissance (dB) désirée pour le bruit ambiant
FFc = 500;   % Fréquence de coupure du filtre passe-bas en sortie du générateur aléatoire
B = 0.4;     % Ecart type de la distribution gaussienne du bruit

%% Constantes de base %%
Fmax = 100000;  % Fréquence maximale des signaux sonar
Fe = 2*Fmax;    % Fréquence d'echantillonage : Théorème de Shannon
t = (1:T)/Fe;   % Axe des temps

%% Simulation de l'environnement %%

% Création du bruit blanc
bruit_blanc = B*randn(1,T);

% Création du filtre de réponse fréquentielle la racine carrée de DSP
[z,p,k] = butter(2, FFc/(Fe/2), 'low');
k = k*sqrt(DSP);
[b,a] = zp2tf(z,p,k);
freqz(b,a)

%Filtrage
bruit_ambiant = filter(b, a, bruit_blanc);

% Affichage du bruit ambiant généré
figure
plot(t,bruit_ambiant)

figure
plot(t,bruit_blanc)
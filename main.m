%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Simulateur de sonar à bruit                  %
%                                                            %
% Auteurs : G.Garcia & N.Dubois  -  @Projet-TAN-TNCY-2017    %
%                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Variables de la simulation %%
T = 120000; % Durée d'envoi d'une onde sonore <=> nb de points.
DSP = 20; % Densité Spectrale de Puissance (dB) désirée pour le bruit ambiant
FFc = 100; % Fréquence de coupure du filtre passe-bas en sortie du générateur aléatoire

%% Constantes de base %%
Fmax = 100000; % Fréquence maximale des signaux sonar
Fe = 2*Fmax; % Fréquence d'echantillonage : Théorème de Shannon
t = (1:T)/Fe; % Axe des temps

%% Simulation de l'environnement %%

% Création du bruit ambiant
lol

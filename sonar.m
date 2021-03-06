%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                Simulateur de sonar � bruit                 %
%                                                            %
%       Auteurs : G.Garcia  -  @Projet-TAN-TNCY-2017         %
%                                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Variables de la simulation %%

% Sonar
T = 0.15;       % Dur�e de l'onde sonore envoy�e.
Te = 10;        % Dur�e d'�coute (finie pour la simulation) du sonar
Ps = 0.002;     % Puissance moyenne (W) du bruit blanc du sonar = carr� de l'�cart type Bs. 
W = 100000;     % Largeur de bande du filtre passe-bande : Fmax = f0 + W/2 => ici, W = 100000Hz car f0 = W/2 pour passe-bas
f0 = W/2;       % Fr�quence centrale du filtre passe-bande
fc = W;         % Fr�quence de coupure du filtre passe-bas
seuil = 110;    % Seuil de d�tection pour la reconstruction du d�cor

% Variables du bruit ambiant
DSP = 18;       % Densit� Spectrale de Puissance (dB) d�sir�e pour le bruit ambiant
FFc = W;        % Fr�quence de coupure du filtre passe-bas en sortie du g�n�rateur al�atoire = celle du filtre du sonar
Pa = 0.01;      % Puissance moyenne (W) du bruit ambiant = carr� de l'�cart type Ba.

% Variables de l'eau de mer (calcul de la c�l�rit� du son)
Temp = 0;       % Temp�rature de l'eau de mer
S = 35;         % Salinit� de l'eau de mer
z = 0;          % Profondeur du sonar

% Distances des r�flecteurs au sonar (Distance max = 3000; Taille du tableau non fix�e)
disref = [100, 600, 400, 1200, 2400, 2700, 1600, 2950];

% Coefficients de r�flexion des r�flecteurs (Valeurs = 0 � 1)
coefref = [0.3, 0.9, 0.4, 0.6, 0.2, 0.9, 0.7, 0.1];


%% Constantes de base %%
Fmax = 100000;       % Fr�quence maximale des signaux sonar. Fmax = f0 + W/2 => ici, W = 100000Hz car f0 = W/2
Fe = 2.5*Fmax;       % Fr�quence d'echantillonage : Th�or�me de Shannon
t = 0:1/Fe:T;        % Axe des temps pour le signal �mis
te = 0:1/Fe:Te;      % Axe des temps pour l'�coute
dmax = 3000;         % Distance max en m�tres des r�flecteurs
Nr = length(disref); % Nombre de r�flecteurs.
d = 1:dmax;          % Axe spatial pour les r�flecteurs (pas = 1);
p = 0.016*z;         % Pression
c = 1449.2+4.6*Temp+(1.34-0.010*Temp)*(S-35)+1.58*p*10^(-6); % Vitesse du son dans l'eau
Ba = sqrt(Pa);       % Ecart type de la distribution gaussienne du bruit ambiant
Bs = sqrt(Ps);       % Ecart type de la distribution gaussienne du bruit blanc envoy� par le sonar


%% Simulation de l'environnement %%

% Cr�ation du bruit blanc
bruit_blanc = Ba*randn(1,Te*Fe+1);

% Cr�ation du filtre de r�ponse fr�quentielle la racine carr�e de DSP
[z,p,k] = butter(2, FFc/(Fe/2), 'low'); % Filtre passe-bas dans un premier temps
k = k*sqrt(DSP);
[b,a] = zp2tf(z,p,k);
%freqz(b,a)

% Filtrage
bruit_ambiant = filter(b, a, bruit_blanc);

% Affichage du bruit ambiant g�n�r� + avant filtrage
figure(1);
subplot(2,1,1)
plot(te,bruit_blanc)
title('Bruit blanc avant filtrage');
xlabel('Temps te');
ylabel('Amplitude');
axis([0,Te,-2,2]);
subplot(2,1,2)
plot(te,bruit_ambiant)
title('Bruit ambiant (post filtrage) DSP = 18');
xlabel('Temps te');
ylabel('Amplitude');
axis([0,Te,-2.0,2.0]);

%% D�cor %%

% G�n�ration des r�flecteurs : Une simple somme de diracs coefficient�s, pour commencer, repr�sentera le d�cor.
r = 0;      % Fonction repr�sentant les r�flecteurs devant le sonar
for k=1:Nr
    tempDirac = zeros(size(d));
    tempDirac(d==disref(k)) = 1; % Dirac �gal � 1 (pas infini)
    r = r + coefref(k)*tempDirac; % Cr�ation de la fonction des r�flecteurs, en prenant en compte le coef de r�flexion de chaque r�f.
end
figure(2);
subplot(7,1,1)
plot(d,r)
title('D�cor r(d)');
xlabel('Distance d');
ylabel('Coeff de r�flexion r');
axis([0,dmax,0,1.0]);


%% Simulation de l'�metteur du sonar

% Cr�ation du bruit blanc gaussien constituant l'onde sonore envoy�e par le sonar
bruit_blanc_sonar = Bs*randn(1,T*Fe+1);

% Fitlrage du bruit par un filtre passe-bas, dans un premier temps. Plus
% tard : se fera avec un filtre passe-bande. Creation du filtre :
[b1,a1] = butter(2, fc/(Fe/2), 'low');
%freqz(b,a)

% Filtrage du bruit blanc
onde_sonar = filter(b1, a1, bruit_blanc_sonar);

% Affichage de l'onde sonore initiale : L'amplitude de l'onde doit �tre
% environ 10 fois moins grande que l'amplitude du bruit ambiant. En effet,
% l'intensit� de l'onde doit �tre tr�s petite devant celle du bruit ambiant
% pour ne pas se faire rep�rer. Pour la rendre encore plus faible : baisser
% la puissance Ps.
subplot(7,1,2)
plot(t,onde_sonar)
title('Onde sonore envoy�e : Ampli ~= Ampli(bruit ambiant) / 10');
xlabel('Temps t ');
ylabel('Amplitude');
axis([0,T,-0.2,0.2]);


%% Interaction entre signal sonar et environnement

fprintf("Vitesse du son : %d m/s\n", c);

% Tenir compte du PATHLOSS (affaiblissement du gain en 10*log(d) pour
% chacun des signaux r�fl�chis)
    % Ajouter la perte � l'aller onde incidente (gain d�p. du temps)
    PLa = 0;
    % Ajouter la perte au retour pnde r�fl�chie (gain d�p. du temps)
    PLr = 0;
    
% Construction des signaux r�fl�chis (retard�s donc). t = d/c
echo = zeros(size(te));
for i=1:Nr
    retard = 2*disref(i)/c; % Compter l'aller et le retour
    echo(1,floor(retard*Fe):floor((retard+T)*Fe)) = coefref(i)*onde_sonar;
end

% Affichage de la somme des signaux r�fl�chis re�us
subplot(7,1,3)
plot(te,echo)
title('Signaux re�us issus de la r�flexion');
xlabel('Temps te ');
ylabel('Amplitude, fonction de r');
axis([0,Te,-0.2,0.2]);


% Construction du signal re�u (�cho)
    % Signal re�u = [2*PathLoss(n�gatif) +] Somme(r(d==point de d�cor)*onde_sonar) + bruit_ambiant
    onde_recu = bruit_ambiant - PLa - PLr + echo;
    
    % Affichage du signal re�u
    subplot(7,1,4)
    plot(te,onde_recu)
    title('Onde totale re�ue au niveau du sonar');
    xlabel('Temps te ');
    ylabel('Amplitude');
    axis([0,Te,-2,2]);

 % Intercorr�lation "simplifi�e" : convolution de matlab x(tau)*y(-tau)
    % Construction du signal avec indices invers�s
    n = length(onde_recu);
    onde_recu_inv = onde_recu(n:-1:1);
 
    % gamma(Tau) = Somme (k = 0 : 1/Fe : T) { x(k)*y(k-Tau) }
    % Tau = t - theta, �cart de temps de x(t) et y(theta) deux signaux
    gamma_simpl = conv(onde_sonar, onde_recu_inv);

    % Echelle de temps pour la convolution
    tc = 1:1/Fe:Te+T+1;
    
    % Affichage de l'intercorr�lation
    subplot(7,1,5)
    plot(tc,gamma_simpl)
    title('Convolution entre signal �mis et signal re�u');
    xlabel('Temps tc');
    ylabel('Convolution');
    axis([1,12,0,50]);   
    
    
% Intercorr�lation 
    % Utilisation de la fonction xcorr de matlab
    gamma = xcorr(onde_sonar, onde_recu);
    
    % Echelle de temps pour l'intercorr�lation
    tx = 1:1/Fe:2*Te+1;

    % Affichage de l'intercorr�lation
    subplot(7,1,6)
    plot(tx,gamma)
    title('Intercorr�lation entre signal �mis et signal re�u');
    xlabel('Temps tx');
    ylabel('Intercorr�lation');
    axis([1,12,0,50]);
    
% Autocorr�lation du signal envoy�
    % Pic de largeur tr�s faible deant les d�tails de r(d)
    autocor = xcorr(onde_sonar);

    % Affichage
    subplot(7,1,7)
    plot(autocor)
    title('Autocorr�lation du signal �mis');
    xlabel('Temps');
    ylabel('Autocorrelation');
    %axis([1,80000,-1,50]);
    
 
%% Reconstruction finale de r(d)
 
% Calcul de la distance en tenant compte de c et de dt : d = c * dt / 2
rbis = c * gamma_simpl/200;
 
% Reverse
n = length(rbis);
rbis_inv = rbis(n:-1:1);
rbis_inv(rbis_inv < seuil) = 0;

% Affichage du r�sultat final
figure(3);
subplot(2,1,1)
plot(d,r)
title('D�cor r(d)');
xlabel('Distance d');
ylabel('Coeff de r�flexion r');
axis([0,dmax,0,1.0]);

subplot(2,1,2)
plot(tc,rbis_inv)
title('Reconstitution du d�cor');
xlabel('Distance d (unit� arbitraire)');
ylabel('R�flexion re�ue');
axis([1,6,0,650]);

% Comparaison des deux m�thodes
figure(4);
subplot(2,1,1);
plot(tx,gamma)
title('Intercorr�lation entre signal �mis et signal re�u (xcorr)');
xlabel('Temps tx');
ylabel('Intercorr�lation');
axis([1,12,0,65]);
subplot(2,1,2);
plot(tc,gamma_simpl)
title('Convolution entre signal �mis et signal re�u (conv avec indice invers� pour y)');
xlabel('Temps tc');
ylabel('Convolution');
axis([1,12,0,65]);   
    
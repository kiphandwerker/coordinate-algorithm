function [PelvisACS,ThighACS,ShankACS,FootACS] = Handwerker_ACS(data)
% Handwerker_ACS.m Creates an anatomical coordinate system (ACS) based on
% anatomical markers on the iliac crests, left and right greater
% trochanter, medial and lateral femoral epicondyles, medial and lateral
% malleolus, first and fifth metatarsals.
%
% [PelvisACS,ThighACS,ShankACS,FootACS] = Handwerker_ACS(data)
%
% NOMENCLATURE:
%               RICR: Right Iliac Crest
%               LICR: Left Iliac Crest
%               RGTR: Right Greater Trochanter
%               LGTR: Left Greater Trochanter
%               RLEP: Right Lateral Epicondyl
%               LLEP: Left Lateral Epicondyl
%               RLMA: Right Lateral Malleolus
%               RMMA: Right Medial Malleolus
%               RMT5: Right 5th Metatarsal 
%               RMT1: Right 1st Metatarsal 
%
%___  RICR LICR RGTR LGTR RLKN RMKN RLMA RMMA RMT5 RMT1
% x |  51   54   57   60   63   66   69   72   75   78
% y |  52   55   58   61   64   67   70   73   76   79
% z |  53   56   59   62   65   68   71   74   77   80
%
%   RICR ____________ LICR  
%       |            |      
%       |   PELVIS   |      
%  RGTR |____________| LGTR
%        ___
%       | T |
%       | H |
%       | I |
%       | G | 
%  RLEP |_H_| RMEP
%        ___
%       | S |
%       | H |
%       | A |
%       | N | 
%  RLMA |_K_| RMMA
%        ___
%  RMT5 /_F_\ RMT1
% 
%
% INPUTS:
%           (data) - Should be a 1x80 vector   
%                    Columns 3:50 Technical
%                    Columns 5:80 Anatomical    
%
%
% OUTPUTS:
% Identity matrix for the following:
%           PelvisACS
%           ThighACS
%           ShankACS
%           FootACS
%
%
% DEPENDENCIES:
%       none
%
% SEE ALSO:
%       cross
%       norm
%
% Created by Kip Handwerker (2018)


% Pelvis
xvecP = data(:,57:59) - data(:,60:62);      % RGTR - LGTR
vvecP = data(:,54:56) - data(:,60:62);      % LICR - LGTR
yvecP = cross(vvecP,xvecP);                 % y = v cross x
zvecP = cross(xvecP,yvecP);                 % z = x cross y

iP = (xvecP / norm(xvecP))';                % x / ||x||'
jP = (yvecP / norm(yvecP))';                % y / ||y||'
kP = (zvecP / norm(zvecP))';                % z / ||z||'

PelvisACS = [iP jP kP];

% Thigh
xvecT = data(:,63:65) - data(:,66:68);      % RLEP - RMEP
vvecT = data(:,57:59) - data(:,66:68);      % RGTR - RMEP
yvecT = cross(vvecT,xvecT);                 % y = v cross x
zvecT = cross(xvecT, yvecT);                % z = x cross y

iT = (xvecT / norm(xvecT))';                % x / ||x||'
jT = (yvecT / norm(yvecT))';                % y / ||y||'
kT = (zvecT / norm(zvecT))';                % z / ||z||'

ThighACS = [iT jT kT];

% Shank
xvecS = data(:,63:65) - data(:,66:68);      % RLEP - RMEP
vvecS = data(:,72:74) - data(:,66:68);      % RMMA - RMEP
yvecS = cross(xvecS,vvecS);                 % y = x cross v
zvecS = cross(xvecS,yvecS);                 % z = x cross y

iS = (xvecS / norm(xvecS))';                % x / ||x||'
jS = (yvecS / norm(yvecS))';                % y / ||y||'
kS = (zvecS / norm(zvecS))';                % z / ||z||'

ShankACS = [iS jS kS]';

% Foot
xvecF = data(:,69:71) - data(:,72:74);      % RLMA - RMMA
vvecF = data(:,78:80) - data(:,72:74);      % RMT1 - RMMA
yvecF = cross(xvecF,vvecF);                 % y = x cross v
zvecF = cross(xvecF,yvecF);                 % z = x cross y

iF = (xvecF / norm(xvecF))';                % x / ||x||'
jF = (yvecF / norm(yvecF))';                % y / ||y||'
kF = (zvecF / norm(zvecF))';                % z / ||z||'

FootACS = [iF jF kF]'*[1 0 0;0 0 -1;0 1 0];
end









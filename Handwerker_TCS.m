function [PelvisTCS,ThighTCS,ShankTCS,FootTCS] = Handwerker_TCS(data)
% Handwerker_TCS.m Creates the technical coordinate system (TCS) based on 
% rigid body markers in specified order. Righ-hand-rule nomenclature is
% used to determine vector coordinates in XYZ. i j k are unit vectors and
% then creates orthonormal right hand coordinate system.
%
% [PelvisTCS,ThighTCS,ShankTCS,FootTCS] = Handwerker_TCS(data)
%
% NOMENCLATURE: 
%               **TB: **Top Back
%               **TF: **Top Front
%               **BB: **Bottom Back
%               **BF: **Bottom Front
%                 RP: Pelvis
%                 RT: Right Thigh
%                 RS: Right Shank
%                 RF: Right Foot
%
%    _______PELVIS______ _______THIGH_______ _______SHANK_______
%___ PV01 PV02 PV03 PV04 RTTF RTTB RTBF RTBB RSTF RSTB RSBF RSBB  
% x | 3   6    9    12    15   18   21   24   27   30   33   36   
% y | 4   7    10   13    16   19   22   25   28   31   34   37  
% z | 5   8    11   14    17   20   23   26   29   32   35   38  
% 
%    ________FOOT_______
%    RTFT RFTB RFBF RFBB
%     39   42   45   48
%     40   43   46   49
%     41   44   47   50
%
%
%    (PV01) **TB _______________________________ **TF (PV02)
%               |                               |
%               |                               |
%               |                               |               
%               |                               |
%               |                               |
%               |                               |
%               |                               |
%               |                               |
%   (PV04) **BB |_______________________________| **BF (PV03)
%
%
% INPUTS:
%           (data) - Should be a 1x80 vector   
%                    Columns 3:50 Technical
%                    Columns 5:80 Anatomical 
%
% OUTPUTS:
%           PelvisTCS   1 0 0
%                       0 1 0
%                       0 0 1
%
%           ThighTCS    0 1 0
%                      -1 0 0
%                       0 0 1
%
%           ShankTCS    0 1 0
%                      -1 0 0
%                       0 0 1
%
%           FootTCS     1 0 0
%                       0 1 0
%                       0 0 1
%
% DEPENDENCIES:
%       none
%
% SEE ALSO:
%   cross
%   norm
%
% Created by Kip Handwerker (2018)

% Pelvis
xvecP = data(:,9:11) - data(:,12:14);   % PV03 - PV04
vvecP = data(:,3:5) - data(:,12:14);    % PV01 - PV04
yvecP = cross(vvecP,xvecP);             % y = v cross x
zvecP = cross(xvecP,yvecP);             % z = x cross y

iP = (xvecP / norm(xvecP))';            % x / ||x||'
jP = (yvecP / norm(yvecP))';            % y / ||y||'
kP = (zvecP / norm(zvecP))';            % z / ||z||'

PelvisTCS = [iP jP kP];

% Thigh
xvecT = data(:,24:26) - data(:,21:23);  % RTBB - RTBF
vvecT = data(:,18:20) - data(:,21:23);  % RTTB - RTBF
yvecT = cross(vvecT,xvecT);             % y = v cross x
zvecT = cross(xvecT,yvecT);             % z = x cross y

iT = (xvecT / norm(xvecT))';            % x / ||x||'
jT = (yvecT / norm(yvecT))';            % y / ||y||'
kT = (zvecT / norm(zvecT))';            % z / ||z||'

ThighTCS = [iT jT kT];

% Shank
xvecS = data(:,36:38) - data(:,33:35);  % RSBB - RSBF
vvecS = data(:,27:29) - data(:,33:35);  % RSTF - RSBF
yvecS = cross(vvecS,xvecS);             % y = v cross x
zvecS = cross(xvecS,yvecS);             % z = x cross y

iS = (xvecS / norm(xvecS))';            % x / ||x||'
jS = (yvecS / norm(yvecS))';            % y / ||y||'
kS = (zvecS / norm(zvecS))';            % z / ||z||'

ShankTCS = [iS jS kS];

% Foot
xvecF = data(:,45:47) - data(:,48:50);  % RFBF - RFBB
vvecF = data(:,42:44) - data(:,48:50);  % RFTB - RFBB
yvecF = cross(vvecF,xvecF);             % y = v cross x
zvecF = cross(xvecF,yvecF);             % z = x cross y

iF = (xvecF / norm(xvecF))';            % x / ||x||'
jF = (yvecF / norm(yvecF))';            % y / ||y||'
kF = (zvecF / norm(zvecF))';            % z / ||z||'

FootTCS = [iF jF kF];
end













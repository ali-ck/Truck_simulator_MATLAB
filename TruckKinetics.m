% This function uses the output of the "TruckSyms.m" script to compute
% numerical values for simulation.
% The function arguments are class objects containing global, truck, and
% trailer properties.
% The function outputs are...
% vAx_dot - Truck forward acceleration
% lambda1 - Truck front wheel lateral force
% lambda2 - Truck rear wheel lateral force
% lambda3 - Trailer rear wheel lateral force

function [vAx_dot,lambda1,lambda2,lambda3] =...
    TruckKinetics(Global,Truck,Trailer)

% Rename all incoming global, truck, and trailer properties to equivalent
% symbolic variables (purely for visual purposes)
IzzA = Truck.MOI;
IzzB = Trailer.MOI;
mA = Truck.Mass;
mB = Trailer.Mass;
g = Global.GravAccel;
mu_k = Global.DynFricCoeff;
L1 = Truck.CG2FrontLength;
L2 = Truck.CG2RearLength;
L3 = Trailer.Pivot2CG_Length;
L4 = Trailer.Pivot2RearLength;
phi = Truck.WheelAngle;
phi_dot = Truck.WheelAngVel;
T = Truck.ThrustForce;
vAx = Truck.LongVel; 
vAy = Truck.LatVel;
omegaA = Truck.AngVel;
omegaB = Trailer.AngVel;
gamma = Trailer.AngleRel2Truck;
C_D = Truck.DragCoeff;
rho = Global.AirDensity;
A = Truck.DragArea;

% Define relavant position vectors
r_A_1 = [L1 0 0]';
r_A_2 = [-L2 0 0]';
r_2_3 = [-L4*cos(gamma) -L4*sin(gamma) 0]';

% Define wheel normal forces
N1 = L2/(L1 + L2)*mA*g;
N2 = L1/(L1 + L2)*mA*g + (L4 - L3)/L4*mB*g;
N3 = L3/L4*mB*g;

% Define relevant angular velocity and velocity vectors
omegaA_vec = [0 0 omegaA]';
omegaB_vec = [0 0 omegaB]';
vA_vec = [vAx vAy 0]';
v1_vec = vA_vec + cross(omegaA_vec,r_A_1);
v2_vec = vA_vec + cross(omegaA_vec,r_A_2);
v3_vec =...
    vA_vec +...
    cross(omegaB_vec,r_2_3) +...
    cross(omegaA_vec,r_A_2 + r_2_3);

% Define unit vectors that align with friction forces
u_phi = [cos(phi) sin(phi) 0]';
u_gamma = [cos(gamma) sin(gamma) 0]';

% Define the aerodynamic drag force
F_D = -(1/2)*C_D*rho*A*sqrt(vAx^2 + vAy^2)*vA_vec;
F_Dx = F_D(1);
% Define friction forces at the three wheel sets
Ff1 = -tanh(dot(v1_vec,u_phi))*mu_k*N1*u_phi;
Ff1x = Ff1(1);Ff1y = Ff1(2);
Ff2 = -tanh(dot(v2_vec,[1 0 0]'))*mu_k*N2*[1 0 0]';
Ff2x = Ff2(1);
Ff3 = -tanh(dot(v3_vec,u_gamma))*mu_k*N3*u_gamma;
Ff3x = Ff3(1);Ff3y = Ff3(2);

% Compute function outputs using the analytical expressions derived from
% "TruckSyms.m"
vAx_dot = (F_Dx*L1^2*L4^3*cos(phi)^3 + F_Dx*L2^2*L4^3*cos(phi)^3 + Ff1x*L1^2*L4^3*cos(phi)^3 + Ff1x*L2^2*L4^3*cos(phi)^3 + Ff2x*L1^2*L4^3*cos(phi)^3 + Ff2x*L2^2*L4^3*cos(phi)^3 + L1^2*L4^3*T*cos(phi)^2 + L2^2*L4^3*T*cos(phi)^2 + Ff1y*L1^2*L4^3*cos(phi)^2*sin(phi) + Ff1y*L2^2*L4^3*cos(phi)^2*sin(phi) + 2*F_Dx*L1*L2*L4^3*cos(phi)^3 + 2*Ff1x*L1*L2*L4^3*cos(phi)^3 + 2*Ff2x*L1*L2*L4^3*cos(phi)^3 - IzzA*L4^3*phi_dot*vAx*sin(phi) - L2^3*L4^3*mB*omegaA^2*cos(phi)^3 + IzzB*L1^2*vAx^2*cos(gamma)*cos(phi)^3 + IzzB*L2^2*vAx^2*cos(gamma)*cos(phi)^3 + 2*L1*L2*L4^3*T*cos(phi)^2 + Ff3x*L1^2*L4^3*cos(gamma)^2*cos(phi)^3 + Ff3x*L2^2*L4^3*cos(gamma)^2*cos(phi)^3 - IzzB*L1^2*vAx^2*cos(gamma)^3*cos(phi)^3 - IzzB*L2^2*vAx^2*cos(gamma)^3*cos(phi)^3 + 2*Ff1y*L1*L2*L4^3*cos(phi)^2*sin(phi) + 2*IzzB*L1*L2*vAx^2*cos(gamma)*cos(phi)^3 + L1^2*L4^3*mA*omegaA*vAy*cos(phi)^3 + L2^2*L4^3*mA*omegaA*vAy*cos(phi)^3 + L1^2*L4^3*mB*omegaA*vAy*cos(phi)^3 + L2^2*L4^3*mB*omegaA*vAy*cos(phi)^3 + 2*Ff3x*L1*L2*L4^3*cos(gamma)^2*cos(phi)^3 - L1^2*L3^2*mB*vAx^2*cos(gamma)^3*cos(phi)^3 - L2^2*L3^2*mB*vAx^2*cos(gamma)^3*cos(phi)^3 - 2*L1*L2^2*L4^3*mB*omegaA^2*cos(phi)^3 - L1^2*L2*L4^3*mB*omegaA^2*cos(phi)^3 + L2^3*L3*L4^2*mB*omegaA^2*cos(phi)^3 - 2*IzzB*L1*L2*vAx^2*cos(gamma)^3*cos(phi)^3 + Ff3y*L1^2*L4^3*cos(gamma)*cos(phi)^3*sin(gamma) + Ff3y*L2^2*L4^3*cos(gamma)*cos(phi)^3*sin(gamma) - L2^2*L4^3*mA*phi_dot*vAx*sin(phi) + L1^2*L3^2*mB*vAx^2*cos(gamma)*cos(phi)^3 + L2^2*L3^2*mB*vAx^2*cos(gamma)*cos(phi)^3 - L2^2*L4^3*mA*omegaA*vAx*cos(phi)^2*sin(phi) + 2*L1*L2*L4^3*mA*omegaA*vAy*cos(phi)^3 + 2*L1*L2*L4^3*mB*omegaA*vAy*cos(phi)^3 - L1^2*L3*L4^3*mB*omegaA^2*cos(gamma)*cos(phi)^3 - L1^2*L3*L4^3*mB*omegaB^2*cos(gamma)*cos(phi)^3 - L2^2*L3*L4^3*mB*omegaA^2*cos(gamma)*cos(phi)^3 - L2^2*L3*L4^3*mB*omegaB^2*cos(gamma)*cos(phi)^3 - 2*L1*L2*L3^2*mB*vAx^2*cos(gamma)^3*cos(phi)^3 + L1^2*L3*L4*mB*vAx^2*cos(gamma)^3*cos(phi)^3 + L2^2*L3*L4*mB*vAx^2*cos(gamma)^3*cos(phi)^3 - L1^2*L3*L4^2*mB*omegaA*vAy*cos(phi)^3 - L2^2*L3*L4^2*mB*omegaA*vAy*cos(phi)^3 - L2^3*L3*L4^2*mB*omegaA^2*cos(gamma)^2*cos(phi)^3 + 2*L1*L2^2*L3*L4^2*mB*omegaA^2*cos(phi)^3 + L1^2*L2*L3*L4^2*mB*omegaA^2*cos(phi)^3 + 2*Ff3y*L1*L2*L4^3*cos(gamma)*cos(phi)^3*sin(gamma) + 2*L1*L2*L3^2*mB*vAx^2*cos(gamma)*cos(phi)^3 - L1^2*L3*L4*mB*vAx^2*cos(gamma)*cos(phi)^3 - L2^2*L3*L4*mB*vAx^2*cos(gamma)*cos(phi)^3 + L1*L3^2*L4^2*mB*phi_dot*vAx*cos(phi)*sin(gamma) + L2*L3^2*L4^2*mB*phi_dot*vAx*cos(phi)*sin(gamma) - L1*L2*L4^3*mA*omegaA*vAx*cos(phi)^2*sin(phi) - 2*L1*L2*L3*L4^3*mB*omegaA^2*cos(gamma)*cos(phi)^3 - 2*L1*L2*L3*L4^3*mB*omegaB^2*cos(gamma)*cos(phi)^3 + 2*L1*L2*L3*L4*mB*vAx^2*cos(gamma)^3*cos(phi)^3 - 2*L1^2*L3*L4^3*mB*omegaA*omegaB*cos(gamma)*cos(phi)^3 - 2*L2^2*L3*L4^3*mB*omegaA*omegaB*cos(gamma)*cos(phi)^3 - 2*L1*L2*L3*L4^2*mB*omegaA*vAy*cos(phi)^3 - L1*L3*L4^3*mB*phi_dot*vAx*cos(phi)*sin(gamma) - L2*L3*L4^3*mB*phi_dot*vAx*cos(phi)*sin(gamma) + L1^2*L3*L4^2*mB*omegaA*vAy*cos(gamma)^2*cos(phi)^3 + L2^2*L3*L4^2*mB*omegaA*vAy*cos(gamma)^2*cos(phi)^3 - 2*L1*L2*L3*L4*mB*vAx^2*cos(gamma)*cos(phi)^3 + IzzB*L1*L4*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma)*sin(phi) + IzzB*L2*L4*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma)*sin(phi) - 2*L1*L2^2*L3*L4^2*mB*omegaA^2*cos(gamma)^2*cos(phi)^3 - L1^2*L2*L3*L4^2*mB*omegaA^2*cos(gamma)^2*cos(phi)^3 - L1^2*L3*L4^2*mB*omegaA*vAx*cos(gamma)*cos(phi)^3*sin(gamma) - L2^2*L3*L4^2*mB*omegaA*vAx*cos(gamma)*cos(phi)^3*sin(gamma) - 4*L1*L2*L3*L4^3*mB*omegaA*omegaB*cos(gamma)*cos(phi)^3 + 2*L1*L2*L3*L4^2*mB*omegaA*vAy*cos(gamma)^2*cos(phi)^3 - L1*L3*L4^2*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma)*sin(phi) + L1*L3^2*L4*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma)*sin(phi) - L2*L3*L4^2*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma)*sin(phi) + L2*L3^2*L4*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma)*sin(phi) - 2*L1*L2*L3*L4^2*mB*omegaA*vAx*cos(gamma)*cos(phi)^3*sin(gamma))/(L4*(IzzA*L4^2*cos(phi) + IzzB*L1^2*cos(phi)^3 + IzzB*L2^2*cos(phi)^3 - IzzA*L4^2*cos(phi)^3 + L1^2*L4^2*mA*cos(phi)^3 + L1^2*L3^2*mB*cos(phi)^3 + L1^2*L4^2*mB*cos(phi)^3 + L2^2*L3^2*mB*cos(phi)^3 + L2^2*L4^2*mB*cos(phi)^3 + 2*IzzB*L1*L2*cos(phi)^3 - IzzB*L1^2*cos(gamma)^2*cos(phi)^3 - IzzB*L2^2*cos(gamma)^2*cos(phi)^3 + L2^2*L4^2*mA*cos(phi) + 2*L1*L2*L4^2*mA*cos(phi)^3 + 2*L1*L2*L3^2*mB*cos(phi)^3 + 2*L1*L2*L4^2*mB*cos(phi)^3 - 2*L1^2*L3*L4*mB*cos(phi)^3 - 2*L2^2*L3*L4*mB*cos(phi)^3 - L1^2*L3^2*mB*cos(gamma)^2*cos(phi)^3 - L2^2*L3^2*mB*cos(gamma)^2*cos(phi)^3 - 2*IzzB*L1*L2*cos(gamma)^2*cos(phi)^3 - 4*L1*L2*L3*L4*mB*cos(phi)^3 - 2*L1*L2*L3^2*mB*cos(gamma)^2*cos(phi)^3 + 2*L1^2*L3*L4*mB*cos(gamma)^2*cos(phi)^3 + 2*L2^2*L3*L4*mB*cos(gamma)^2*cos(phi)^3 + L1*L3*L4^2*mB*cos(phi)^2*sin(gamma)*sin(phi) - L1*L3^2*L4*mB*cos(phi)^2*sin(gamma)*sin(phi) + L2*L3*L4^2*mB*cos(phi)^2*sin(gamma)*sin(phi) - L2*L3^2*L4*mB*cos(phi)^2*sin(gamma)*sin(phi) + 4*L1*L2*L3*L4*mB*cos(gamma)^2*cos(phi)^3));
lambda1 = ((F_Dx*IzzA*L1*L4^3*sin(2*phi))/2 - Ff1y*IzzB*L2^3*L4*cos(phi)^2 - Ff1y*IzzB*L1^3*L4*cos(phi)^2 + (F_Dx*IzzA*L2*L4^3*sin(2*phi))/2 + (Ff1x*IzzA*L1*L4^3*sin(2*phi))/2 + (Ff1x*IzzA*L2*L4^3*sin(2*phi))/2 + (Ff2x*IzzA*L1*L4^3*sin(2*phi))/2 + (Ff2x*IzzA*L2*L4^3*sin(2*phi))/2 + (IzzA*IzzB*L4*vAx^2*sin(2*gamma))/2 - L1^3*L4^3*T*mA*(sin(phi) - sin(phi)^3) - L1^3*L4^3*T*mB*(sin(phi) - sin(phi)^3) - L2^3*L4^3*T*mB*(sin(phi) - sin(phi)^3) + L2^3*L4^3*mA^2*phi_dot*vAx - Ff1y*L1^3*L4^3*mA*cos(phi)^2 - Ff1y*L2^3*L4^3*mA*cos(phi)^2 - Ff1y*L1^3*L4^3*mB*cos(phi)^2 - Ff1y*L2^3*L4^3*mB*cos(phi)^2 + (F_Dx*L2^3*L4^3*mA*sin(2*phi))/2 + (Ff1x*L2^3*L4^3*mA*sin(2*phi))/2 + (Ff2x*L2^3*L4^3*mA*sin(2*phi))/2 + IzzA*L1*L4^3*T*(sin(phi) - sin(phi)^3) + IzzA*L2*L4^3*T*(sin(phi) - sin(phi)^3) - IzzB*L1^3*L4*T*(sin(phi) - sin(phi)^3) - IzzB*L2^3*L4*T*(sin(phi) - sin(phi)^3) + (IzzB*L2^2*L4*mA*vAx^2*sin(2*gamma))/2 - (IzzA*L3*L4^2*mB*vAx^2*sin(2*gamma))/2 + (IzzA*L3^2*L4*mB*vAx^2*sin(2*gamma))/2 - 3*IzzB*L1*L2^2*L4*T*(sin(phi) - sin(phi)^3) - 3*IzzB*L1^2*L2*L4*T*(sin(phi) - sin(phi)^3) + Ff1y*IzzB*L1^3*L4*cos(gamma)^2*cos(phi)^2 + Ff1y*IzzB*L2^3*L4*cos(gamma)^2*cos(phi)^2 - 3*Ff1y*IzzB*L1*L2^2*L4*cos(phi)^2 - 3*Ff1y*IzzB*L1^2*L2*L4*cos(phi)^2 + IzzA*IzzB*L1*L4*phi_dot*vAx + IzzA*IzzB*L2*L4*phi_dot*vAx + L2^3*L4^3*mA*mB*phi_dot*vAx - (IzzA*L2^2*L4^3*mB*omegaA^2*sin(2*phi))/2 + L2^3*L4^3*mA^2*omegaA*vAx*cos(phi)^2 - (L2^4*L4^3*mA*mB*omegaA^2*sin(2*phi))/2 - 2*L1*L2^2*L4^3*T*mA*(sin(phi) - sin(phi)^3) - 3*L1^2*L2*L4^3*T*mA*(sin(phi) - sin(phi)^3) - 3*L1*L2^2*L4^3*T*mB*(sin(phi) - sin(phi)^3) - 3*L1^2*L2*L4^3*T*mB*(sin(phi) - sin(phi)^3) + 2*L1^3*L3*L4^2*T*mB*(sin(phi) - sin(phi)^3) - L1^3*L3^2*L4*T*mB*(sin(phi) - sin(phi)^3) + 2*L2^3*L3*L4^2*T*mB*(sin(phi) - sin(phi)^3) - L2^3*L3^2*L4*T*mB*(sin(phi) - sin(phi)^3) + (L2^3*L4^3*mA^2*omegaA*vAy*sin(2*phi))/2 + L1*L2^2*L4^3*mA^2*phi_dot*vAx - 3*Ff1y*L1*L2^2*L4^3*mA*cos(phi)^2 - 3*Ff1y*L1^2*L2*L4^3*mA*cos(phi)^2 - 3*Ff1y*L1*L2^2*L4^3*mB*cos(phi)^2 - 3*Ff1y*L1^2*L2*L4^3*mB*cos(phi)^2 + 2*Ff1y*L1^3*L3*L4^2*mB*cos(phi)^2 - Ff1y*L1^3*L3^2*L4*mB*cos(phi)^2 + 2*Ff1y*L2^3*L3*L4^2*mB*cos(phi)^2 - Ff1y*L2^3*L3^2*L4*mB*cos(phi)^2 + IzzA*L1*L4^3*mA*phi_dot*vAx + IzzA*L2*L4^3*mA*phi_dot*vAx + IzzB*L2^3*L4*mA*phi_dot*vAx + IzzA*L1*L4^3*mB*phi_dot*vAx + IzzA*L2*L4^3*mB*phi_dot*vAx + (F_Dx*L1*L2^2*L4^3*mA*sin(2*phi))/2 + (Ff1x*L1*L2^2*L4^3*mA*sin(2*phi))/2 + (Ff2x*L1*L2^2*L4^3*mA*sin(2*phi))/2 - 2*Ff1y*L1^3*L3*L4^2*mB*cos(gamma)^2*cos(phi)^2 + Ff1y*L1^3*L3^2*L4*mB*cos(gamma)^2*cos(phi)^2 - 2*Ff1y*L2^3*L3*L4^2*mB*cos(gamma)^2*cos(phi)^2 + Ff1y*L2^3*L3^2*L4*mB*cos(gamma)^2*cos(phi)^2 + IzzB*L2^3*mA*vAx^2*cos(gamma)*cos(phi)*sin(phi) - IzzB*L2^3*L4*mA*phi_dot*vAx*cos(gamma)^2 + IzzB*L2^3*L4*mA*omegaA*vAx*cos(phi)^2 - L1^2*L3^2*L4^2*T*mB*cos(phi)^3*sin(gamma) - L2^2*L3^2*L4^2*T*mB*cos(phi)^3*sin(gamma) + 6*Ff1y*L1*L2^2*L3*L4^2*mB*cos(phi)^2 - 3*Ff1y*L1*L2^2*L3^2*L4*mB*cos(phi)^2 + 6*Ff1y*L1^2*L2*L3*L4^2*mB*cos(phi)^2 - 3*Ff1y*L1^2*L2*L3^2*L4*mB*cos(phi)^2 + IzzB*L1^3*L4*T*cos(gamma)^2*cos(phi)^2*sin(phi) + IzzB*L2^3*L4*T*cos(gamma)^2*cos(phi)^2*sin(phi) + (IzzA*L1*L4^3*mA*omegaA*vAy*sin(2*phi))/2 + (IzzA*L2*L4^3*mA*omegaA*vAy*sin(2*phi))/2 + (IzzA*L1*L4^3*mB*omegaA*vAy*sin(2*phi))/2 + (IzzA*L2*L4^3*mB*omegaA*vAy*sin(2*phi))/2 + IzzB*L1*L2^2*L4*mA*phi_dot*vAx - 2*IzzA*L1*L3*L4^2*mB*phi_dot*vAx + IzzA*L1*L3^2*L4*mB*phi_dot*vAx - 2*IzzA*L2*L3*L4^2*mB*phi_dot*vAx + IzzA*L2*L3^2*L4*mB*phi_dot*vAx + Ff3x*L2^3*L4^3*mA*cos(gamma)^2*cos(phi)*sin(phi) - (IzzA*L1*L2*L4^3*mB*omegaA^2*sin(2*phi))/2 - L1^2*L3*L4^3*T*mB*cos(phi)*sin(gamma) - L2^2*L3*L4^3*T*mB*cos(phi)*sin(gamma) - IzzB*L2^3*mA*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) + 3*Ff1y*IzzB*L1*L2^2*L4*cos(gamma)^2*cos(phi)^2 + 3*Ff1y*IzzB*L1^2*L2*L4*cos(gamma)^2*cos(phi)^2 + IzzA*IzzB*L1*vAx^2*cos(gamma)*cos(phi)*sin(phi) + IzzA*IzzB*L2*vAx^2*cos(gamma)*cos(phi)*sin(phi) - IzzA*IzzB*L1*L4*phi_dot*vAx*cos(gamma)^2 - IzzA*IzzB*L2*L4*phi_dot*vAx*cos(gamma)^2 + L2^3*L4^3*mA*mB*omegaA*vAx*cos(phi)^2 + (L2^3*L4^3*mA*mB*omegaA*vAy*sin(2*phi))/2 + L1*L2^2*L4^3*mA*mB*phi_dot*vAx - 2*L2^3*L3*L4^2*mA*mB*phi_dot*vAx + L2^3*L3^2*L4*mA*mB*phi_dot*vAx + Ff3x*IzzA*L1*L4^3*cos(gamma)^2*cos(phi)*sin(phi) + Ff3x*IzzA*L2*L4^3*cos(gamma)^2*cos(phi)*sin(phi) + (IzzA*L2^2*L3*L4^2*mB*omegaA^2*sin(2*phi))/2 + L1^2*L3^2*L4^2*T*mB*cos(phi)*sin(gamma) + L2^2*L3^2*L4^2*T*mB*cos(phi)*sin(gamma) + L1^2*L3*L4^3*T*mB*cos(phi)^3*sin(gamma) + L2^2*L3*L4^3*T*mB*cos(phi)^3*sin(gamma) + 2*L1*L2^2*L4^3*mA^2*omegaA*vAx*cos(phi)^2 + L1^2*L2*L4^3*mA^2*omegaA*vAx*cos(phi)^2 - (L2^2*L3*L4^2*mA*mB*vAx^2*sin(2*gamma))/2 + (L2^2*L3^2*L4*mA*mB*vAx^2*sin(2*gamma))/2 - IzzA*IzzB*L4*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma) - (L1*L2^3*L4^3*mA*mB*omegaA^2*sin(2*phi))/2 + (L2^4*L3*L4^2*mA*mB*omegaA^2*sin(2*phi))/2 + 6*L1*L2^2*L3*L4^2*T*mB*(sin(phi) - sin(phi)^3) - 3*L1*L2^2*L3^2*L4*T*mB*(sin(phi) - sin(phi)^3) + 6*L1^2*L2*L3*L4^2*T*mB*(sin(phi) - sin(phi)^3) - 3*L1^2*L2*L3^2*L4*T*mB*(sin(phi) - sin(phi)^3) - IzzA*IzzB*L1*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) - IzzA*IzzB*L2*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) + (L1*L2^2*L4^3*mA^2*omegaA*vAy*sin(2*phi))/2 - 2*L1^3*L3*L4^2*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) + L1^3*L3^2*L4*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) - 2*L2^3*L3*L4^2*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) + L2^3*L3^2*L4*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) + (L1*L2^2*L4^3*mA*mB*omegaA*vAy*sin(2*phi))/2 - (L2^3*L3*L4^2*mA*mB*omegaA*vAy*sin(2*phi))/2 - 2*L1*L2^2*L3*L4^2*mA*mB*phi_dot*vAx + L1*L2^2*L3^2*L4*mA*mB*phi_dot*vAx - 2*L1*L2*L3^2*L4^2*T*mB*cos(phi)^3*sin(gamma) + (L1*L2^3*L3*L4^2*mA*mB*omegaA^2*sin(2*phi))/2 + Ff3y*IzzA*L1*L4^3*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) + Ff3y*IzzA*L2*L4^3*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) - Ff1y*L1^2*L3*L4^3*mB*cos(phi)*sin(gamma)*sin(phi) - Ff1y*L2^2*L3*L4^3*mB*cos(phi)*sin(gamma)*sin(phi) - L2^3*L3^2*mA*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) - IzzB*L2^3*L4*mA*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - 2*L1*L2*L3*L4^3*T*mB*cos(phi)*sin(gamma) - 6*Ff1y*L1*L2^2*L3*L4^2*mB*cos(gamma)^2*cos(phi)^2 + 3*Ff1y*L1*L2^2*L3^2*L4*mB*cos(gamma)^2*cos(phi)^2 - 6*Ff1y*L1^2*L2*L3*L4^2*mB*cos(gamma)^2*cos(phi)^2 + 3*Ff1y*L1^2*L2*L3^2*L4*mB*cos(gamma)^2*cos(phi)^2 + IzzB*L1*L2^2*mA*vAx^2*cos(gamma)*cos(phi)*sin(phi) + IzzA*L1*L3^2*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) + IzzA*L2*L3^2*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) - IzzB*L1*L2^2*L4*mA*phi_dot*vAx*cos(gamma)^2 + 2*IzzA*L1*L3*L4^2*mB*phi_dot*vAx*cos(gamma)^2 - IzzA*L1*L3^2*L4*mB*phi_dot*vAx*cos(gamma)^2 + 2*IzzA*L2*L3*L4^2*mB*phi_dot*vAx*cos(gamma)^2 - IzzA*L2*L3^2*L4*mB*phi_dot*vAx*cos(gamma)^2 + 2*IzzB*L1*L2^2*L4*mA*omegaA*vAx*cos(phi)^2 + IzzB*L1^2*L2*L4*mA*omegaA*vAx*cos(phi)^2 + 3*IzzB*L1*L2^2*L4*T*cos(gamma)^2*cos(phi)^2*sin(phi) + 3*IzzB*L1^2*L2*L4*T*cos(gamma)^2*cos(phi)^2*sin(phi) - (IzzA*L1*L3*L4^2*mB*omegaA*vAy*sin(2*phi))/2 - (IzzA*L2*L3*L4^2*mB*omegaA*vAy*sin(2*phi))/2 + Ff3x*L1*L2^2*L4^3*mA*cos(gamma)^2*cos(phi)*sin(phi) + Ff1y*L1^2*L3^2*L4^2*mB*cos(phi)*sin(gamma)*sin(phi) + Ff1y*L2^2*L3^2*L4^2*mB*cos(phi)*sin(gamma)*sin(phi) + (IzzA*L1*L2*L3*L4^2*mB*omegaA^2*sin(2*phi))/2 - IzzB*L2^2*L4*mA*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma) + IzzA*L3*L4^2*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma) - IzzA*L3^2*L4*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma) + 2*L1*L2*L3^2*L4^2*T*mB*cos(phi)*sin(gamma) + 2*L1*L2*L3*L4^3*T*mB*cos(phi)^3*sin(gamma) - IzzB*L1*L2^2*mA*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) - IzzA*L1*L3^2*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) - IzzA*L2*L3^2*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) + Ff3y*L2^3*L4^3*mA*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) + L2^3*L3^2*mA*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) + 2*L2^3*L3*L4^2*mA*mB*phi_dot*vAx*cos(gamma)^2 - L2^3*L3^2*L4*mA*mB*phi_dot*vAx*cos(gamma)^2 + 2*L1*L2^2*L4^3*mA*mB*omegaA*vAx*cos(phi)^2 + L1^2*L2*L4^3*mA*mB*omegaA*vAx*cos(phi)^2 - 2*L2^3*L3*L4^2*mA*mB*omegaA*vAx*cos(phi)^2 + L2^3*L3^2*L4*mA*mB*omegaA*vAx*cos(phi)^2 + Ff3y*L1*L2^2*L4^3*mA*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) + 2*L2^3*L3*L4^2*mA*mB*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - L2^3*L3^2*L4*mA*mB*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - L2^3*L3*L4^3*mA*mB*omegaA^2*cos(gamma)*cos(phi)*sin(phi) - L2^3*L3*L4^3*mA*mB*omegaB^2*cos(gamma)*cos(phi)*sin(phi) - 2*Ff1y*L1*L2*L3*L4^3*mB*cos(phi)*sin(gamma)*sin(phi) + L1*L2^2*L3^2*mA*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) + L2^3*L3*L4*mA*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) + 2*L1*L2^2*L3*L4^2*mA*mB*phi_dot*vAx*cos(gamma)^2 - L1*L2^2*L3^2*L4*mA*mB*phi_dot*vAx*cos(gamma)^2 - 4*L1*L2^2*L3*L4^2*mA*mB*omegaA*vAx*cos(phi)^2 + 2*L1*L2^2*L3^2*L4*mA*mB*omegaA*vAx*cos(phi)^2 - 2*L1^2*L2*L3*L4^2*mA*mB*omegaA*vAx*cos(phi)^2 + L1^2*L2*L3^2*L4*mA*mB*omegaA*vAx*cos(phi)^2 - 6*L1*L2^2*L3*L4^2*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) + 3*L1*L2^2*L3^2*L4*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) - 6*L1^2*L2*L3*L4^2*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) + 3*L1^2*L2*L3^2*L4*T*mB*cos(gamma)^2*cos(phi)^2*sin(phi) - (L1*L2^2*L3*L4^2*mA*mB*omegaA*vAy*sin(2*phi))/2 - IzzA*L1*L3*L4*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) - IzzA*L2*L3*L4*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) - IzzA*L2^2*L3*L4^2*mB*omegaA^2*cos(gamma)^2*cos(phi)*sin(phi) + L2^2*L3*L4^2*mA*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma) - L2^2*L3^2*L4*mA*mB*vAx^2*cos(gamma)*cos(phi)^2*sin(gamma) - L2^4*L3*L4^2*mA*mB*omegaA^2*cos(gamma)^2*cos(phi)*sin(phi) + 2*Ff1y*L1*L2*L3^2*L4^2*mB*cos(phi)*sin(gamma)*sin(phi) - L1*L2^2*L3^2*mA*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) - 2*IzzB*L1*L2^2*L4*mA*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - IzzB*L1^2*L2*L4*mA*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - IzzA*L1*L3*L4^3*mB*omegaA^2*cos(gamma)*cos(phi)*sin(phi) - IzzA*L1*L3*L4^3*mB*omegaB^2*cos(gamma)*cos(phi)*sin(phi) - IzzA*L2*L3*L4^3*mB*omegaA^2*cos(gamma)*cos(phi)*sin(phi) - IzzA*L2*L3*L4^3*mB*omegaB^2*cos(gamma)*cos(phi)*sin(phi) + IzzA*L1*L3*L4*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) + IzzA*L2*L3*L4*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) - L2^3*L3*L4*mA*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) + IzzA*L1*L3*L4^2*mB*omegaA*vAy*cos(gamma)^2*cos(phi)*sin(phi) + IzzA*L2*L3*L4^2*mB*omegaA*vAy*cos(gamma)^2*cos(phi)*sin(phi) - L1*L2^2*L3*L4*mA*mB*vAx^2*cos(gamma)*cos(phi)*sin(phi) - 2*L2^3*L3*L4^3*mA*mB*omegaA*omegaB*cos(gamma)*cos(phi)*sin(phi) + L2^2*L3*L4^3*mA*mB*omegaA*vAx*cos(phi)*sin(gamma)*sin(phi) - IzzA*L1*L2*L3*L4^2*mB*omegaA^2*cos(gamma)^2*cos(phi)*sin(phi) + 4*L1*L2^2*L3*L4^2*mA*mB*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - 2*L1*L2^2*L3^2*L4*mA*mB*omegaA*vAx*cos(gamma)^2*cos(phi)^2 + 2*L1^2*L2*L3*L4^2*mA*mB*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - L1^2*L2*L3^2*L4*mA*mB*omegaA*vAx*cos(gamma)^2*cos(phi)^2 - L1*L2^2*L3*L4^3*mA*mB*omegaA^2*cos(gamma)*cos(phi)*sin(phi) - L1*L2^2*L3*L4^3*mA*mB*omegaB^2*cos(gamma)*cos(phi)*sin(phi) + L1*L2^2*L3*L4*mA*mB*vAx^2*cos(gamma)^3*cos(phi)*sin(phi) + L2^3*L3*L4^2*mA*mB*omegaA*vAy*cos(gamma)^2*cos(phi)*sin(phi) - L2^2*L3^2*L4^2*mA*mB*omegaA*vAx*cos(phi)*sin(gamma)*sin(phi) - 2*IzzA*L1*L3*L4^3*mB*omegaA*omegaB*cos(gamma)*cos(phi)*sin(phi) - 2*IzzA*L2*L3*L4^3*mB*omegaA*omegaB*cos(gamma)*cos(phi)*sin(phi) - L1*L2^3*L3*L4^2*mA*mB*omegaA^2*cos(gamma)^2*cos(phi)*sin(phi) - L2^3*L3*L4^2*mA*mB*omegaA*vAx*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) + L1*L2*L3*L4^3*mA*mB*omegaA*vAx*cos(phi)*sin(gamma)*sin(phi) - 2*L1*L2^2*L3*L4^3*mA*mB*omegaA*omegaB*cos(gamma)*cos(phi)*sin(phi) - IzzA*L1*L3*L4^2*mB*omegaA*vAx*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) - IzzA*L2*L3*L4^2*mB*omegaA*vAx*cos(gamma)*cos(phi)*sin(gamma)*sin(phi) - L1*L2*L3^2*L4^2*mA*mB*omegaA*vAx*cos(phi)*sin(gamma)*sin(phi) + L1*L2^2*L3*L4^2*mA*mB*omegaA*vAy*cos(gamma)^2*cos(phi)*sin(phi) - L1*L2^2*L3*L4^2*mA*mB*omegaA*vAx*cos(gamma)*cos(phi)*sin(gamma)*sin(phi))/(L4*(L1 + L2)*(IzzA*L4^2*cos(phi) + IzzB*L1^2*cos(phi)^3 + IzzB*L2^2*cos(phi)^3 - IzzA*L4^2*cos(phi)^3 + L1^2*L4^2*mA*cos(phi)^3 + L1^2*L3^2*mB*cos(phi)^3 + L1^2*L4^2*mB*cos(phi)^3 + L2^2*L3^2*mB*cos(phi)^3 + L2^2*L4^2*mB*cos(phi)^3 + 2*IzzB*L1*L2*cos(phi)^3 - IzzB*L1^2*cos(gamma)^2*cos(phi)^3 - IzzB*L2^2*cos(gamma)^2*cos(phi)^3 + L2^2*L4^2*mA*cos(phi) + 2*L1*L2*L4^2*mA*cos(phi)^3 + 2*L1*L2*L3^2*mB*cos(phi)^3 + 2*L1*L2*L4^2*mB*cos(phi)^3 - 2*L1^2*L3*L4*mB*cos(phi)^3 - 2*L2^2*L3*L4*mB*cos(phi)^3 - L1^2*L3^2*mB*cos(gamma)^2*cos(phi)^3 - L2^2*L3^2*mB*cos(gamma)^2*cos(phi)^3 - 2*IzzB*L1*L2*cos(gamma)^2*cos(phi)^3 - 4*L1*L2*L3*L4*mB*cos(phi)^3 - 2*L1*L2*L3^2*mB*cos(gamma)^2*cos(phi)^3 + 2*L1^2*L3*L4*mB*cos(gamma)^2*cos(phi)^3 + 2*L2^2*L3*L4*mB*cos(gamma)^2*cos(phi)^3 + L1*L3*L4^2*mB*cos(phi)^2*sin(gamma)*sin(phi) - L1*L3^2*L4*mB*cos(phi)^2*sin(gamma)*sin(phi) + L2*L3*L4^2*mB*cos(phi)^2*sin(gamma)*sin(phi) - L2*L3^2*L4*mB*cos(phi)^2*sin(gamma)*sin(phi) + 4*L1*L2*L3*L4*mB*cos(gamma)^2*cos(phi)^3));
lambda2 = []; % Not used in the simulation
lambda3 = []; % Not used in the simulation

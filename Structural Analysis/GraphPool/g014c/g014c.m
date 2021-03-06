classdef g014c < model
    
    methods
        function this = g014c()
            this.name = 'g014c';
            this.description = 'Fixed-wing UAV model, revized, according to uav-modeling, with no extra \dot{x} terms';
            
            %% Equation list
            % legend:
            % dot - differential relation
            % int - integral term
            % trig - trigonometric term
            % ni - general non-invertible term
            % inp - input variable
            % out - output variable % NOT SUPPORTED
            % msr - measured variable
            
            %% Kinematic Equations
            
            % Position derivatives
            kin = [...
                {'dot_north ni phi ni theta ni psi ni u ni v ni w'};...
                {'dot_east ni phi ni theta ni psi ni u ni v ni w'};...
                {'dot_down ni phi ni theta ni psi ni u ni v ni w'};...
                ];
            
            der = [...
                {'int dot_north dot north'};...
                {'int dot_east dot east'};...
                {'int dot_down dot down'};
                ];
            
            % Euler angle derivatives
            kin = [kin;...
                {'dot_phi ni phi ni theta p ni q ni r'};...
                {'dot_theta ni phi q ni r'};... % Is a "ni" in front of q reasonable?
                {'dot_psi ni phi ni theta ni q r'};... % Is a "ni" in front of r reasonable?
                ];
            
            der = [der;...
                {'int dot_phi dot phi'};...
                {'int dot_theta dot theta'};...
                {'int dot_psi dot psi'};...
                ];
            
            % Angular Velocity
            kin = [kin;...
                {'C_0 ni p ni q ni r ni J_6 ni J_7 ni J_8 ni J_3 ni J_4 ni J_5'};...
                {'C_1 ni p ni q ni r ni J_0 ni J_1 ni J_2 ni J_6 ni J_7 ni J_8'};...
                {'C_2 ni p ni q ni r ni J_0 ni J_1 ni J_2 ni J_3 ni J_4 ni J_5'};...
                {'dot_p ni Ji_0 ni Ji_1 ni Ji_2 ni T_x ni T_y ni T_z ni C_0 ni C_1 ni C_2'};...
                {'dot_q ni Ji_3 ni Ji_4 ni Ji_5 ni T_x ni T_y ni T_z ni C_0 ni C_1 ni C_2'};...
                {'dot_r ni Ji_6 ni Ji_7 ni Ji_8 ni T_x ni T_y ni T_z ni C_0 ni C_1 ni C_2'};...
                ];
            
            der = [der;...
                {'int dot_p dot p'};...
                {'int dot_q dot q'};...
                {'int dot_r dot r'};...
                ];
            
            % Linear Velocity
            kin = [kin;...
                {'V_i ni u ni v ni w'};...
                {'chi ni u ni v ni w ni phi ni theta ni psi'};... % ni needed here to keep the system semi-explicit DAE
                {'gamma ni u ni v ni w ni phi ni theta ni psi V_i'};...
                {'V_g V_i gamma'};... % Is a "ni" in front of V_i reasonable?
                {'dot_u ni v ni w ni r ni q F_x ni m'};...
                {'dot_v ni u ni w ni p r F_y ni m'};...
                {'dot_w ni u ni v ni p q F_z ni m'};...
                ];
            
            der = [der;...
                {'int dot_u dot u'};...
                {'int dot_v dot v'};...
                {'int dot_w dot w'};...
                ];
            
            % Air data
            kin = [kin;...
                {'u_r u u_w'};...
                {'v_r v v_w'};...
                {'w_r w w_w'};...
                {'w_w'};... %Assumption ww = 0;
                {'alpha w_r u_r'};...
                {'beta v_r V_a'};...
                {'V_a ni u_r ni v_r ni w_r'};...
                ];
            
            % Mass Distribution
            kin = [kin;...
                {'m m_nom m_i'};...
                {'m_nom'};... % Known nominal mass
                {'p_cm_x ni m p_mi_x m_i'};...
                {'p_cm_y ni m p_mi_y m_i'};...
                {'p_cm_z ni m p_mi_z m_i'};...
                {'m_i'};... % merr = 0;
                {'p_mi_x'};... % no error mass
                {'p_mi_y'};... % no error mass
                {'p_mi_z'};... % no error mass
                {'J_nom_0'};... known inertia component
                {'J_nom_1'};... known inertia component
                {'J_nom_2'};... known inertia component
                {'J_nom_3'};... known inertia component
                {'J_nom_4'};... known inertia component
                {'J_nom_5'};... known inertia component
                {'J_nom_6'};... known inertia component
                {'J_nom_7'};... known inertia component
                {'J_nom_8'};... known inertia component
                {'J_0 J_nom_0 ni p_mi_y  ni p_mi_z  ni m_i  ni m_nom'};...                
                {'J_1 J_nom_1 ni p_mi_x  ni p_mi_y  ni m_i  ni m_nom'};...
                {'J_2 J_nom_2 ni p_mi_x  ni p_mi_z  ni m_i  ni m_nom'};...
                {'J_3 J_nom_3 ni p_mi_y  ni p_mi_x  ni m_i  ni m_nom'};...
                {'J_4 J_nom_4 ni p_mi_x  ni p_mi_z  ni m_i  ni m_nom'};...
                {'J_5 J_nom_5 ni p_mi_y  ni p_mi_z  ni m_i  ni m_nom'};...
                {'J_6 J_nom_6 ni p_mi_z  ni p_mi_x  ni m_i  ni m_nom'};...
                {'J_7 J_nom_7 ni p_mi_z  ni p_mi_y  ni m_i  ni m_nom'};...
                {'J_8 J_nom_8 ni p_mi_x  ni p_mi_y  ni m_i  ni m_nom'};...
                {'detJ ni J_0 ni J_1 ni J_2 ni J_3 ni J_4 ni J_5 ni J_6 ni J_7 ni J_8'};...
                {'Ji_0 ni J_4 ni J_8 ni J_5 ni J_7 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_1 ni J_2 ni J_7 ni J_1 ni J_8 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_2 ni J_1 ni J_5 ni J_2 ni J_4 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_3 ni J_5 ni J_6 ni J_3 ni J_8 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_4 ni J_0 ni J_8 ni J_2 ni J_6 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_5 ni J_2 ni J_3 ni J_0 ni J_5 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_6 ni J_3 ni J_7 ni J_4 ni J_6 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_7 ni J_1 ni J_6 ni J_0 ni J_7 ni detJ'};... % is ni in front of detJ necessary?
                {'Ji_8 ni J_0 ni J_4 ni J_1 ni J_3 ni detJ'};... % is ni in front of detJ necessary?
                ];
            
            %% Dynamic Equations
            dyn = [];
            
            dyn = [dyn;...
                {'F_x F_g_x F_a_x F_t_x'};...
                {'F_y F_g_y F_a_y F_t_y'};...
                {'F_z F_g_z F_a_z F_t_z'};...
                {'T_x T_atot_x T_ttot_x'};...
                {'T_y T_atot_y T_ttot_y'};...
                {'T_z T_atot_z T_ttot_z'};...
                ];
            
            % Gravity
            dyn = [dyn;...
                {'F_g_x theta ni m ni g'};...
                {'F_g_y phi ni theta ni m ni g'};...
                {'F_g_z phi theta m g'};...
                ];
            
            % Aerodynamics
            dyn = [dyn;...
                {'F_a_x ni alpha ni beta F_D ni F_Y ni F_L'};... % is ni in front of alpha and beta too restrictive?
                {'F_a_y ni beta ni F_D F_Y'};... % is ni in front of alpha and beta too restrictive?
                {'F_a_z ni alpha ni beta ni F_D ni F_Y F_L'};... % is ni in front of alpha and beta too restrictive?
                {'T_atot_x T_a_x ni p_cm_y ni p_cm_z ni p_cl_y ni p_cl_z ni F_a_y ni F_a_z'};...
                {'T_atot_y T_a_y ni p_cm_x p_cm_z ni p_cl_x p_cl_z ni F_a_x ni F_a_z'};...
                {'T_atot_z T_a_z ni p_cm_x p_cm_y ni p_cl_x p_cl_y ni F_a_x ni F_a_y'};...
                {'q_bar rho V_a'};...
                {'fault F_D q_bar C_D'};...
                {'fault F_Y q_bar C_Y'};...
                {'fault F_L q_bar C_L'};...
                {'fault T_a_x q_bar C_l'};...
                {'fault T_a_y q_bar C_m'};...
                {'fault T_a_z q_bar C_n'};...
                {'fault C_D ni V_a ni alpha ni q inp delta_e'};...
                {'fault C_Y ni V_a ni beta ni p ni r inp delta_a inp delta_r'};...
                {'fault C_L ni V_a ni alpha ni ni q inp delta_e'};...
                {'fault C_l ni V_a ni beta ni p ni r inp delta_a inp delta_r'};...
                {'fault C_m ni V_a ni alpha ni q inp delta_e'};...
                {'fault C_n ni V_a ni beta ni p ni r inp delta_a inp delta_r'};...
                ];
            
            % Propeller
            dyn = [dyn;...
                {'fault F_t_y'};...
                {'fault F_t_z'};...
                {'T_ttot_x T_t_x ni p_cm_y ni p_cm_z ni p_prop_y ni p_prop_z ni F_t_x ni F_t_z'};...
                {'T_ttot_y T_t_y ni p_cm_x ni p_cm_z ni p_prop_x ni p_prop_z ni F_t_x F_t_z'};...
                {'T_ttot_z T_t_z ni p_cm_x ni p_cm_y ni p_prop_x ni p_prop_y ni F_t_x F_t_y'};...
                {'p_prop_x'};...
                {'p_prop_y'};...
                {'p_prop_z'};...
                {'fault T_t_y'};...
                {'fault T_t_z'};...
                {'fault F_t_x C_t rho n_prop'};... % Using simplified thruster
                {'n_prop w_prop'};...
                {'fault C_t ni Jar'};...
                {'Jar V_a n_prop'};...
                {'fault P_prop C_p rho n_prop'};...
                {'fault C_p ni Jar'};...
                {'fault dot_n_prop P_mot P_prop n_prop'};...
                {'T_t_x P_prop w_prop'};...
                ];
            
            der = [der;...
                {'int dot_n_prop dot n_prop'};...
                ];
            
            % Motor
            dyn = [dyn;...
                {'fault n_prop n_mot'};...
                {'fault n_mot E_i'};...
                {'fault E_i V_mot I_mot'};...
                {'P_mot E_i I_i'};...
                {'fault I_i I_mot E_i'};...
                {'P_elec V_mot I_mot'};...
                {'fault V_mot V_bat I_mot inp delta_t'};...
                ];
            
            %% Other models
            
            mod = [];
            
            mod = [mod;...
                {'north ni z ni lat ni lat_0'};... % Flat Eearth model
                {'east ni z ni lon ni lon_0'};...
                {'down z z_0'};... % NED altitude offset from geometric altitude
                {'h z'};... % geopotential altitude
                {'h_0 z_0'};... % initialization altitude
                {'T T_0 ni h ni h_0'};... % Temperature gradient
                {'P P_0 ni T_0 ni T'};... % Pressure gradient
                {'h ni T_0 ni P ni P_0 ni h_0'};... % Barometric altitude calcuation
                {'rho P T'};... % density gradient
                {'Pt P rho Va'};... % dynamic pressure
                {'g msr g_0'};... % Taking static gravity for now
                ];
            
            %% Sensory equations
            
            msr = [];
            
            msr = [msr;...
                {'fault msr a_m_x F_x ni m ni g theta'};... % Acceleration
                {'fault msr a_m_y F_y ni m ni g phi ni theta'};...
                {'fault msr a_m_z F_z ni m ni g phi theta'};...
                {'fault msr p_m p'};... % Angular velocity
                {'fault msr q_m q'};...
                {'fault msr r_m r'};...
                {'fault msr h_m_x h_x'};... % Magnetic field
                {'fault msr h_m_y h_y'};...
                {'fault msr h_m_z h_z'};...
                {'fault msr phi_m phi'};... % Euler angles
                {'fault msr theta_m theta'};...
                {'fault msr psi_m psi'};...
                {'fault msr lat_0_gps lat_0'};... % GPS measurements
                {'fault msr lon_0_gps lon_0'};...
                {'fault msr lat_gps lat'};...
                {'fault msr lon_gps lon'};...
                {'fault msr z_gps z'};...
                {'fault msr V_g_gps V_g'};...
                {'fault msr chi_gps chi'};...
                {'fault msr T_0_m T_0'};... % Initialization temperature
                {'fault msr z_0_m z_0'};... % Initialization altitude
                {'fault msr P_bar P'};... % Barometer reading
                {'fault msr T_m T'};... % Therometer reading
                {'fault P_t P rho V_a'};... % Pitot probe measurement
                {'fault msr P_t_m P_t'};... % Pitot reading
%                 {'fault msr alpha_m alpha'};.... % AoA reading, DISABLED TEMPORARILY
%                 {'fault msr beta_m beta'};... % AoS reading, DISABLED TEMPORARILY
%                 {'fault msr down_rf down'};... % Range finder reading, DISABLED TEMPORARILY
                {'fault msr V_mot_m V_mot'};... % Battery voltage measurement
                {'fault msr I_mot_m I_mot'};... % Battery current measurement
                {'fault msr n_prop_m n_prop'};... % Motor rps measurement
                ];
            
            
            %% Summing up
            this.constraints = [...
                {kin},{'k'};...
                {dyn},{'f'};...
                {der},{'d'};...
                {mod},{'m'};...
                {msr},{'s'};...
                ];
            
            %% Specifying node coordinates if available
            this.coordinates = [];
            
        end
        
    end
    
end
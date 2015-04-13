classdef QPInputConstantHeight
% A container for the input to the InstantaneousQPController describing a
% snapshot of the current plan at the current time and state. This is a "2D"
% input because it reasons about the linear inverted pendulum in 2D (with a
% fixed height assumption). We may eventually extend this to a QPInput3D
% class.
  properties(Constant)
  end

  properties
    be_silent = false; % Whether to ignore this message and produce no output
    timestamp % current time in seconds
    zmp_data % information describing the setup and state of our linear inverted pendulum model
    support_data  % information describing available supports which the controller MAY use
    body_motion_data  % information describing body trajectories which the controller should track
    body_wrench_data % information describing external wrenches to compensate for
    whole_body_data  % information about the desired whole-body posture
    param_set_name % the name of the current set of parameters. See atlasParams.getDefaults()
    joint_pd_override; % if present, override the q_des, Kp, Kd, and w_qdd for the given joints with new values (can be empty)
  end

  methods
    function obj = QPInputConstantHeight()
      obj.timestamp = 0;
      obj.zmp_data = struct('A',  [zeros(2),eye(2); zeros(2,4)],... % COM state map 
                        'B', [zeros(2); eye(2)],... % COM input map
                        'C', [eye(2),zeros(2)],... % ZMP state-output map
                        'D', -0.89/9.81*eye(2),... % ZMP input-output map
                        'x0', zeros(4,1),... % nominal state
                        'y0', zeros(2,1),... % nominal output
                        'u0', zeros(2,1),... % nominal input
                        'R', zeros(2),... % input LQR cost
                        'Qy', 0.8*eye(2),... % output LQR cost
                        'S', zeros(4),... % cost-to-go terms: x'Sx + x's1 + s2
                        's1', zeros(4,1),...
                        's1dot', zeros(4,1),... 
                        's2', 0,... 
                        's2dot', 0);

      % support_logic_map lets us specify the way the various forms of contact detection are combined. 
      % We do this by enumerating all possible binary inputs from the force sensor and the kinematic
      % contact detector. Then we have the following table:
      %
      % force  kin  output
      % 0      0    case1
      % 0      1    case2
      % 1      0    case3
      % 1      1    case4
      % 
      % The support_logic_map for each body is the vector [case1; case2; case3; case4];
      % For example, to force a body to be in support regardless of sensors, we would say:
      % support_logic_map = ones(4,1);
      % To allow support only if the force sensor is TRUE, we would say:
      % support_logic_map = [0;0;1;1];
      %
      obj.support_data = struct('body_id', {}, 'contact_pts', {}, 'support_logic_map', {}, 'mu', {}, 'contact_surfaces', {});
      
      obj.body_motion_data = struct('body_id', {},...
                                    'ts', {},...
                                    'coefs', {},...
                                    'toe_off_allowed', {},...
                                    'in_floating_base_nullspace', {},...
                                    'control_pose_when_in_contact', {},...
                                    'use_spatial_velocity',{},...
                                    'quat_task_to_world',{},...
                                    'translation_task_to_world',{},...
                                    'xyz_kp_multiplier',{},...
                                    'xyz_kd_multiplier',{},...
                                    'expmap_kp_multiplier',{},...
                                    'expmap_kd_multiplier',{},...
                                    'weight_multiplier',{});
      
      obj.body_wrench_data = struct('body_id', {},...
                                    'wrench', {});
      obj.whole_body_data = struct('q_des', [],...
                               'constrained_dofs', []);
      obj.joint_pd_override = struct('position_ind', {},...
                                     'qi_des', {},...
                                     'qdi_des', {},...
                                     'kp', {},...
                                     'kd', {},...
                                     'weight', {});
      obj.param_set_name = 'walking';
    end

    function msg = to_lcm(obj)
      error('deprecated, use encodeQPInputLCMMex instead');
    end
  end
end

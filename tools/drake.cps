{
  "Meta-Comment": "Common Package Specification for Drake",
  "Meta-Schema": "https://mwoehlke.github.io/cps/",
  "X-Purpose": "Used to generate drake-config.cmake via cps2cmake",
  "X-See-Also": "https://github.com/mwoehlke/pycps",
  "Cps-Version": "0.8.0",
  "Name": "drake",
  "Website": "http://drake.mit.edu/",
  "Requires": {
    "Eigen3": {
      "Version": "3.3.3",
      "Hints": ["@prefix@/lib/cmake/eigen3"],
      "X-CMake-Find-Args": ["CONFIG"]
    },
    "lcm": {
      "Version": "1.3.95",
      "Hints": ["@prefix@/lib/cmake/lcm"],
      "X-CMake-Find-Args": ["CONFIG"]
    },
    "bot2-core-lcmtypes": {
      "Hints": ["@prefix@/lib/cmake/bot2-core-lcmtypes"],
      "X-CMake-Find-Args": ["CONFIG"]
    },
    "robotlocomotion-lcmtypes": {
      "Hints": ["@prefix@/lib/cmake/robotlocomotion-lcmtypes"],
      "X-CMake-Find-Args": ["CONFIG"]
    },
    "spdlog": {
      "Version": "1.0.0",
      "Hints": ["@prefix@/lib/cmake/spdlog"],
      "X-CMake-Find-Args": ["CONFIG"]
    }
  },
  "Components": {
    "drake": {
      "Type": "dylib",
      "Location": "@prefix@/lib/libdrake.so",
      "Includes": [
        "@prefix@/include"
      ],
      "Compile-Features": ["c++14"],
      "Requires": [
        "Eigen3:Eigen",
        "lcm:lcm",
        "bot2-core-lcmtypes:lcmtypes_bot2-core-cpp",
        "robotlocomotion-lcmtypes:robotlocomotion-lcmtypes-cpp",
        "spdlog:spdlog"
      ]
    },
    "drake-lcmtypes-cpp": {
      "Type": "interface",
      "Includes": ["@prefix@/include/lcmtypes"],
      "Requires": ["lcm:lcm-coretypes"]
    },
    "acrobot-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_acrobot.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "automotive-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_automotive.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "body_acceleration-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_body_acceleration.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "body_motion_data-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_body_motion_data.jar",
      "Requires": ["lcm:lcm-java"]
    },
        "body_wrench_data-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_body_wrench_data.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "constrained_values-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_constrained_values.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "contact_info_for_viz-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_contact_info_for_viz.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "contact_information-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_contact_information.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "contact_results_for_viz-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_contact_results_for_viz.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "desired_body_motion-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_desired_body_motion.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "desired_centroidal_momentum_dot-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_desired_centroidal_momentum_dot.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "desired_dof_motions-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_desired_dof_motions.jar",
      "Requires": ["lcm:lcm-java"]
    },
   "drake_signal-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_drake_signal.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "iiwa-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_iiwa.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "inverse_dynamics_debug_info-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_inverse_dynamics_debug_info.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "joint_pd_override-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_joint_pd_override.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "manipulator_plan_move_end_effector-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_manipulator_plan_move_end_effector.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "piecewise_polynomial-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_piecewise_polynomial.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "plan_eval_debug_info-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_plan_eval_debug_info.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "polynomial-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_polynomial.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "polynomial_matrix-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_polynomial_matrix.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "qp_controller_input-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_qp_controller_input.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "qp_input-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_qp_input.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "resolved_contact-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_resolved_contact.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "schunk-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_schunk.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "support_data-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_support_data.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "viewer-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_viewer.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "whole_body_data-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_whole_body_data.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "zmp_data-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_zmp_data.jar",
      "Requires": ["lcm:lcm-java"]
    },
    "zmp_com_observer_state-lcmtypes-java": {
      "Type": "jar",
      "Location": "@prefix@/share/java/lcmtypes_zmp_com_observer_state.jar",
      "Requires": ["lcm:lcm-java"]
    }
  }
}

#include "drake/multibody/benchmarks/kuka_iiwa_robot/test/MG_kuka_iiwa_robot.h"

#include "drake/common/extract_double.h"
#include "drake/multibody/benchmarks/kuka_iiwa_robot/test/MG_kuka_iiwa_robot_auto_generated.h"

namespace drake {
namespace multibody {
namespace benchmarks {
namespace kuka_iiwa_robot {

using Eigen::Map;
using Eigen::Matrix;

template <typename T>
std::tuple<Matrix3d, Vector3d, Vector3d, Vector3d, Vector3d, Vector3d>
MGKukaIIwaRobot<T>::CalcEndEffectorKinematics(
    const Eigen::Ref<const VectorX<T>>& q,
    const Eigen::Ref<const VectorX<T>>& qDt,
    const Eigen::Ref<const VectorX<T>>& qDDt) const {

  static_assert(std::is_convertible<T, double>::value,
                "This class only supports T = double.");

  // Form a continuous vector of joint angles and their time-derivatives.
  const Eigen::Index size = q.size() + qDt.size() + qDDt.size();
  VectorX<double> joint_angles_and_1st_2nd_derivatives(size);
  joint_angles_and_1st_2nd_derivatives << q, qDt, qDDt;

  // Calculate forward kinematics of end-effector with MotionGenesis.
  using MotionGenesis::MGKukaIIwaRobotAutoGenerated;
  MGKukaIIwaRobotAutoGenerated MG_kuka_auto_generated;
  MG_kuka_auto_generated.SetVariablesFromArray(
      joint_angles_and_1st_2nd_derivatives.data());
  MG_kuka_auto_generated.CalculateOutput();

  // Convert MotionGenesis standard C++ matrix to an Eigen matrix.
  // Note: Standard C++ stores two-dimensional matrices in row-major form.
  // By default, Eigen stores two-dimensional matrices in column-major form.
  // After an Eigen matrix is constructed from the C++ matrix (interpreting the
  // C++ matrix in row-order), column-major R_NG is populated via operator=.
  const double *matrix33 = MG_kuka_auto_generated.R_NG[0];
  const Matrix3d R_NG = Matrix<double, 3, 3, Eigen::RowMajor>(matrix33);

  const Vector3d p_NoGo_N(MG_kuka_auto_generated.p_NoGo_N);
  const Vector3d w_NG_N(MG_kuka_auto_generated.w_NG_N);
  const Vector3d v_NGo_N(MG_kuka_auto_generated.v_NGo_N);
  const Vector3d alpha_NG_N(MG_kuka_auto_generated.alpha_NG_N);
  const Vector3d a_NGo_N(MG_kuka_auto_generated.a_NGo_N);

  return std::make_tuple(R_NG, p_NoGo_N, w_NG_N, v_NGo_N, alpha_NG_N, a_NGo_N);
}

// Explicitly instantiates on the most common scalar types.
template class MGKukaIIwaRobot<double>;

}  // namespace kuka_iiwa_robot
}  // namespace benchmarks
}  // namespace multibody
}  // namespace drake

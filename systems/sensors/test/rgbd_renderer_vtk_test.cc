#include "drake/systems/sensors/rgbd_renderer_vtk.h"

#include "drake/systems/sensors/test/rgbd_renderer_test_util.h"

namespace drake {
namespace systems {
namespace sensors {
namespace test {

using RgbdRendererVTKTest = RgbdRendererTest<RgbdRendererVTK>;
using Eigen::Isometry3d;


TEST_F(RgbdRendererVTKTest, TerrainTest) {
  Init(X_WC_, true);
  int a;
  std::cin>>a;
  const auto& kTerrain = renderer_->color_palette().get_terrain_color();
  // At two different distances.
  for (auto depth : std::array<float, 2>({{2.f, 4.9999f}})) {
    X_WC_.translation().z() = depth;
    renderer_->UpdateViewpoint(X_WC_);
    Render();
    VerifyUniformColor(kTerrain, 255u);
    VerifyUniformLabel(Label::kFlatTerrain);
    VerifyUniformDepth(depth);
  }

  // Closer than kZNear.
  X_WC_.translation().z() = kZNear - 1e-5;
  renderer_->UpdateViewpoint(X_WC_);
  Render();
  VerifyUniformColor(kTerrain, 255u);
  VerifyUniformLabel(Label::kFlatTerrain);
  VerifyUniformDepth(InvalidDepth::kTooClose);

  // Farther than kZFar.
  X_WC_.translation().z() = kZFar + 1e-3;
  renderer_->UpdateViewpoint(X_WC_);
  Render();
  VerifyUniformColor(kTerrain, 255u);
  VerifyUniformLabel(Label::kFlatTerrain);
  // Verifies depth.
  for (int y = 0; y < kHeight; ++y) {
    for (int x = 0; x < kWidth; ++x) {
      ASSERT_EQ(InvalidDepth::kTooFar, depth_.at(x, y)[0]);
    }
  }
}


// TODO(kunimatsu-tri) Move DepthImageToPointCloudConversionTest here from
// rgbd_camera_test.

}  // namespace test
}  // namespace sensors
}  // namespace systems
}  // namespace drake

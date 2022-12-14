#pragma once
//#include <torch/extension.h> //by stone
#include <torch/all.h>
#ifdef USE_PYTHON
#include <torch/python.h>
#endif

#ifdef _WIN32
#if defined(torchvision_EXPORTS)
#define VISION_API __declspec(dllexport)
#else
#define VISION_API __declspec(dllimport)
#endif
#else
#define VISION_API
#endif

VISION_API std::tuple<at::Tensor, at::Tensor> ROIPool_forward_cpu(
    const at::Tensor& input,
    const at::Tensor& rois,
    const float spatial_scale,
    const int pooled_height,
    const int pooled_width);

VISION_API at::Tensor ROIPool_backward_cpu(
    const at::Tensor& grad,
    const at::Tensor& rois,
    const at::Tensor& argmax,
    const float spatial_scale,
    const int pooled_height,
    const int pooled_width,
    const int batch_size,
    const int channels,
    const int height,
    const int width);

VISION_API at::Tensor ROIAlign_forward_cpu(
    const at::Tensor& input,
    const at::Tensor& rois,
    const double spatial_scale,
    const int64_t pooled_height,
    const int64_t pooled_width,
    const int64_t sampling_ratio,
    const bool aligned);

VISION_API at::Tensor ROIAlign_backward_cpu(
    const at::Tensor& grad,
    const at::Tensor& rois,
    const double spatial_scale,
    const int64_t pooled_height,
    const int64_t pooled_width,
    const int64_t batch_size,
    const int64_t channels,
    const int64_t height,
    const int64_t width,
    const int64_t sampling_ratio,
    const bool aligned);

VISION_API std::tuple<at::Tensor, at::Tensor> PSROIPool_forward_cpu(
    const at::Tensor& input,
    const at::Tensor& rois,
    const float spatial_scale,
    const int pooled_height,
    const int pooled_width);

VISION_API at::Tensor PSROIPool_backward_cpu(
    const at::Tensor& grad,
    const at::Tensor& rois,
    const at::Tensor& mapping_channel,
    const float spatial_scale,
    const int pooled_height,
    const int pooled_width,
    const int batch_size,
    const int channels,
    const int height,
    const int width);

VISION_API std::tuple<at::Tensor, at::Tensor> PSROIAlign_forward_cpu(
    const at::Tensor& input,
    const at::Tensor& rois,
    const float spatial_scale,
    const int pooled_height,
    const int pooled_width,
    const int sampling_ratio);

VISION_API at::Tensor PSROIAlign_backward_cpu(
    const at::Tensor& grad,
    const at::Tensor& rois,
    const at::Tensor& mapping_channel,
    const float spatial_scale,
    const int pooled_height,
    const int pooled_width,
    const int sampling_ratio,
    const int batch_size,
    const int channels,
    const int height,
    const int width);

VISION_API at::Tensor nms_cpu(
    const at::Tensor& dets,
    const at::Tensor& scores,
    const double iou_threshold);

VISION_API at::Tensor DeformConv2d_forward_cpu(
    const at::Tensor& input,
    const at::Tensor& weight,
    const at::Tensor& offset,
    const at::Tensor& bias,
    std::pair<int, int> stride,
    std::pair<int, int> pad,
    std::pair<int, int> dilation,
    int groups,
    int deformable_groups);

VISION_API std::tuple<at::Tensor, at::Tensor, at::Tensor, at::Tensor>
DeformConv2d_backward_cpu(
    const at::Tensor& grad_out,
    const at::Tensor& input,
    const at::Tensor& weight,
    const at::Tensor& offset,
    const at::Tensor& bias,
    std::pair<int, int> stride,
    std::pair<int, int> pad,
    std::pair<int, int> dilation,
    int groups,
    int deformable_groups);

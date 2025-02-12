// Copyright (c) Meta Platforms, Inc. and affiliates.

// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

#pragma once

#include <cuda_runtime_api.h>
#include <cuda.h>

namespace kineto_stress_test {

inline void checkCudaStatus(cudaError_t status, int lineNumber = -1) {
  if (status != cudaSuccess) {
    printf(
        "cuda API failed with status %d: %s at line %d\n",
        status,
        cudaGetErrorString(status),
        lineNumber);
    exit(-1);
  }
}

struct tensor_pair {
  // Number of elements in the float arrays
  uint32_t n_elements;

  // If true, we pre-generate host buffers and use copy host to dev
  bool b_copy_h2d;

  // If true we download the output buffer to simulate output download
  bool b_copy_d2h;

  // GPU buffers
  float* d_A;
  float* d_B;
  float* d_C;

  // Host buffers
  float* h_A;
  float* h_B;
};

struct tensor_cache_args {
    uint32_t sz_cache_KB;
    uint32_t sz_min_tensor_KB;
    uint32_t sz_max_tensor_KB;
    uint32_t sz_GPU_memory_KB;
    float prob_h2d;
    float prob_d2h;
};

// Generates all the buffer pairs, using a minimum and a maximum size.
// prob_h2d is the probability that we will generate a copy from host to
// device, in which case we need to pre-generate the buffers on the host.
void generate_tensor_cache(tensor_cache_args cache_args);

// For some experiments we may need to add additional pairs to stress the
// GPU memory limits
void add_pairs_to_tensor_cache(tensor_cache_args cache_args,
    uint32_t num_added_pairs);

// Size of the memory pool in kilobytes
extern uint32_t sz_memory_pool_KB;

// Number of tensor pairs in the memory pool
extern uint32_t num_tensor_pairs;

// Re-initializes the random values in the device buffers
void re_initialize_buffer_values();

// Frees the host and device tensors
void free_tensor_cache();

struct stress_test_args {
    uint32_t num_workers;
    bool tracing_enabled;
    uint32_t num_operations;
    uint32_t num_cuda_streams;
    float prob_cuda_malloc;
    uint32_t min_iters_kernel;
    uint32_t max_iters_kernel;
    uint32_t min_idle_us;
    uint32_t max_idle_us;
    bool simulate_host_time;
    bool use_uvm_buffers;
    float* uvm_a;
    float* uvm_b;
    uint64_t uvm_len;
    float uvm_kernel_prob;
};

void run_stress_test(
    uint32_t thread_id,
    uint32_t num_workers,
    bool tracing_enabled,
    stress_test_args test_args);

} // namespace kineto_stress_test

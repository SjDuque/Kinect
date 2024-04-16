# freenect2.pyx
# distutils: language = c++
# distutils: sources = ../src/cxx/kinect_v2_controller.cpp

from libcpp.vector cimport vector
import numpy as np
cimport numpy as np

cdef extern from "kinect_v2_controller.hpp":
    cdef struct FrameData:
        unsigned char* rgb_data
        size_t rgb_size
        float* ir_data
        size_t ir_size
        float* depth_data
        size_t depth_size
        

    cdef cppclass KinectV2Controller:
        KinectV2Controller(bint display)
        void start()
        void stop()
        FrameData wait_for_next_frame()
        bint is_running()

cdef class Freenect2:
    cdef KinectV2Controller *thisptr      # hold a C++ instance which we're wrapping
    cdef np.ndarray rgb_np, ir_np, depth_np

    def __cinit__(self, display=False):
        self.thisptr = new KinectV2Controller(display)
        self.rgb_np = np.empty((1080, 1920, 4), dtype=np.uint8)
        self.ir_np = np.empty((424, 512), dtype=np.float32)
        self.depth_np = np.empty((424, 512), dtype=np.float32)


    def __dealloc__(self):
        del self.thisptr

    def start(self):
        self.thisptr.start()

    def stop(self):
        self.thisptr.stop()

    def wait_for_next_frame(self):
        cdef FrameData result = self.thisptr.wait_for_next_frame()
        
        if result.rgb_data is NULL or result.ir_data is NULL or result.depth_data is NULL:
            raise ValueError("Received NULL data from Kinect device")
            
        cdef unsigned char[:] rgb_view = <unsigned char[:result.rgb_size]>result.rgb_data
        cdef float[:] ir_view = <float[:result.ir_size]>result.ir_data
        cdef float[:] depth_view = <float[:result.depth_size]>result.depth_data
        np.copyto(self.rgb_np, np.asarray(rgb_view, dtype=np.uint8).reshape(1080, 1920, 4))
        np.copyto(self.ir_np, np.asarray(ir_view, dtype=np.float32).reshape(424, 512))
        np.copyto(self.depth_np, np.asarray(depth_view, dtype=np.float32).reshape(424, 512))
        return (self.rgb_np, self.ir_np, self.depth_np)
        
    def is_running(self):
                return self.thisptr.is_running()
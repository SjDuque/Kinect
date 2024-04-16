# freenect2.pyx
# distutils: language = c++
# distutils: sources = kinect_v2_controller.cpp

from libcpp.vector cimport vector
import numpy as np
cimport numpy as np

cdef extern from "kinect_v2_controller.hpp":
    cdef struct FrameData:
        vector[unsigned char] rgb
        vector[float] depth
        vector[float] ir

    cdef cppclass KinectV2Controller:
        KinectV2Controller(bint display)
        void start()
        void stop()
        FrameData wait_for_next_frame()

cdef class PyKinectV2Controller:
    cdef KinectV2Controller *thisptr      # hold a C++ instance which we're wrapping

    def __cinit__(self, display=False):
        self.thisptr = new KinectV2Controller(display)

    def __dealloc__(self):
        del self.thisptr

    def start(self):
        self.thisptr.start()

    def stop(self):
        self.thisptr.stop()

    def wait_for_next_frame(self):
        cdef FrameData result = self.thisptr.wait_for_next_frame()
        return (result.rgb, result.ir, result.depth)
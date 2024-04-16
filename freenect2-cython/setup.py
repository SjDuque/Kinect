from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy
import os

# Get the absolute path to the directory containing setup.py
# dir_path = os.path.dirname(os.path.realpath(__file__))
# print("kinectv2controller: ", os.path.join(dir_path, "../src/cxx/kinect_v2_controller.cpp"))

ext = Extension("freenect2",
                sources=["freenect2.pyx", "../src/cxx/kinect_v2_controller.cpp"],  # Use an absolute path here
                include_dirs=[numpy.get_include(), "/opt/homebrew/include", "../include/cxx"],  # Use an absolute path here
                language='c++',
                extra_compile_args=["-std=c++11"],
                extra_link_args=["-L/opt/homebrew/lib", "-lfreenect2", "-lopencv_core", "-lopencv_imgproc", "-lopencv_highgui", "-lopencv_videoio"]
)

setup(
    name='freenect2',
    ext_modules=cythonize(ext),
)
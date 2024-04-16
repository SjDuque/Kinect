from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy

ext = Extension("freenect2",
                sources=["freenect2.pyx", "kinect_v2_controller.cpp"],
                include_dirs=[numpy.get_include(), "/opt/homebrew/include"],
                language='c++',
                extra_compile_args=["-std=c++11"],
                extra_link_args=["-L/opt/homebrew/lib", "-lfreenect2", "-lopencv_core", "-lopencv_imgproc", "-lopencv_highgui", "-lopencv_videoio"]
)

setup(
    name='freenect2',
    ext_modules=cythonize(ext),
)

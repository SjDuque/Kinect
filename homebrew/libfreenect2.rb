class Libfreenect2 < Formula
    desc "Open source drivers for the Kinect for Windows v2 device"
    homepage "https://github.com/OpenKinect/libfreenect2"
    head "https://github.com/OpenKinect/libfreenect2.git", branch: "master"
    url "https://github.com/OpenKinect/libfreenect2.git"
  
    license any_of: ["Apache-2.0", "GPL-2.0-only"]
  
    depends_on "cmake" => :build
    depends_on "pkg-config" => :build
    depends_on "libusb"
    depends_on "glfw"  # Necessary for OpenGL support
  
    depends_on "jpeg-turbo" => :optional
  
    def install
      system "mkdir", "-p", "build"
      cd "build" do
        system "cmake", "..", *std_cmake_args,
               "-DENABLE_OPENGL=ON",
               "-DENABLE_OPENCL=ON",
               "-DENABLE_CUDA=OFF",
               "-DBUILD_EXAMPLES=OFF",
               "-DBUILD_OPENNI2_DRIVER=OFF",
               "-DENABLE_CXX11=ON"
        
        system "make"
        system "make", "install"
      end
    end
    
  
    test do
      (testpath/"test.cpp").write <<~EOS
        #include <iostream>
        #include <cstdlib>
        #include <signal.h>
        #include <opencv2/opencv.hpp>
        #include <libfreenect2/libfreenect2.hpp>
        #include <libfreenect2/frame_listener_impl.h>
        #include <libfreenect2/registration.h>
        #include <libfreenect2/packet_pipeline.h>
        #include <libfreenect2/logger.h>
  
        bool protonect_shutdown = false;
  
        void sigint_handler(int s)
        {
            protonect_shutdown = true;
        }
  
        int main(int argc, char *argv[])
        {
            libfreenect2::Freenect2 freenect2;
            libfreenect2::Freenect2Device *dev = nullptr;
            libfreenect2::PacketPipeline *pipeline = nullptr;
  
            if(freenect2.enumerateDevices() == 0)
            {
                std::cout << "No device connected!" << std::endl;
                return -1;
            }
  
            std::string serial = freenect2.getDefaultDeviceSerialNumber();
            pipeline = new libfreenect2::CpuPacketPipeline();  // Choose your pipeline here: CpuPacketPipeline (most compatible), OpenCLPacketPipeline, OpenGLPacketPipeline (least compatible, not working on macOS)
  
            dev = freenect2.openDevice(serial, pipeline);
  
            if(dev == nullptr)
            {
                std::cout << "Failure opening device!" << std::endl;
                return -1;
            }
  
            signal(SIGINT, sigint_handler);
            libfreenect2::SyncMultiFrameListener listener(libfreenect2::Frame::Color | libfreenect2::Frame::Ir | libfreenect2::Frame::Depth);
            libfreenect2::FrameMap frames;
  
            dev->setColorFrameListener(&listener);
            dev->setIrAndDepthFrameListener(&listener);
  
            dev->start();
  
            cv::namedWindow("RGB", cv::WINDOW_AUTOSIZE);
            cv::namedWindow("IR", cv::WINDOW_AUTOSIZE);
            cv::namedWindow("Depth", cv::WINDOW_AUTOSIZE);
  
            while(!protonect_shutdown)
            {
                if (!listener.waitForNewFrame(frames, 10*1000)) // 10 seconds
                {
                    std::cout << "Timeout!" << std::endl;
                    return -1;
                }
  
                libfreenect2::Frame *rgb = frames[libfreenect2::Frame::Color];
                libfreenect2::Frame *ir = frames[libfreenect2::Frame::Ir];
                libfreenect2::Frame *depth = frames[libfreenect2::Frame::Depth];
  
                cv::Mat rgbMat(rgb->height, rgb->width, CV_8UC4, rgb->data);
                cv::Mat irMat(ir->height, ir->width, CV_32FC1, ir->data);
                cv::Mat depthMat(depth->height, depth->width, CV_32FC1, depth->data);
  
                cv::imshow("RGB", rgbMat);
                cv::imshow("IR", irMat / 65535.0f);  // Normalize the IR image
                cv::imshow("Depth", depthMat / 4500.0f);  // Normalize the depth to be visible
  
                int key = cv::waitKey(1);
                if(key == 'q' || key == 'Q' || key == 27)
                    break;
  
                listener.release(frames);
            }
  
            dev->stop();
            dev->close();
  
            cv::destroyAllWindows();
            return 0;
        }
      EOS
            # Get OpenCV formula to fetch installation paths
      opencv = Formula["opencv"]
      system ENV.cxx, "test.cpp", "-o", "test",
        "-std=c++11",  # Ensuring C++11 compatibility
        "-I#{opencv.opt_include}/opencv4",
        "-L#{opencv.opt_lib}",
        "-lopencv_core", "-lopencv_highgui", "-lopencv_imgproc",
        "-L#{lib}", "-lfreenect2"
      system "./test"
    end
  end
  
// File: kinect_v2_controller.hpp

#ifndef KINECT_V2_CONTROLLER_HPP
#define KINECT_V2_CONTROLLER_HPP

#include <vector>
#include <libfreenect2/libfreenect2.hpp>
#include <libfreenect2/frame_listener_impl.h>
#include <libfreenect2/registration.h>
#include <libfreenect2/packet_pipeline.h>

struct FrameData {
    std::vector<unsigned char> rgb;
    std::vector<float> ir;
    std::vector<float> depth;
};

class KinectV2Controller {
public:
    KinectV2Controller(bool display=false) 
    : listener(libfreenect2::Frame::Color | libfreenect2::Frame::Ir | libfreenect2::Frame::Depth) {
        pipeline = new libfreenect2::OpenCLPacketPipeline(); // Choose your pipeline here
        if (freenect2.enumerateDevices() == 0 || !(dev = freenect2.openDevice(freenect2.getDefaultDeviceSerialNumber(), pipeline))) {
            throw std::runtime_error("No Kinect device found or failed to open!");
        }
        dev->setColorFrameListener(&listener);
        dev->setIrAndDepthFrameListener(&listener);
        // set display flag
        this->display = display;
    }
    ~KinectV2Controller();

    void start();
    FrameData wait_for_next_frame();
    void stop();

    static bool protonect_shutdown;

private:
    libfreenect2::Freenect2 freenect2;
    libfreenect2::Freenect2Device *dev;
    libfreenect2::PacketPipeline *pipeline;
    libfreenect2::SyncMultiFrameListener listener;
    bool display;

    static void sigint_handler(int s);
};

#endif // KINECT_V2_CONTROLLER_HPP
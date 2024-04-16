// kinect_v2_controller.cpp
#include <iostream>
#include <cstdlib>
#include <signal.h>
#include <vector>
#include <opencv2/opencv.hpp>
#include <libfreenect2/libfreenect2.hpp>
#include <libfreenect2/frame_listener_impl.h>
#include <libfreenect2/registration.h>
#include <libfreenect2/packet_pipeline.h>

#include "kinect_v2_controller.hpp"

bool KinectV2Controller::protonect_shutdown = false;

KinectV2Controller::~KinectV2Controller() {
    if (dev) {
        dev->stop();
        dev->close();
    }
    delete pipeline;
}

void KinectV2Controller::start() {
    signal(SIGINT, KinectV2Controller::sigint_handler);
    dev->start();
    if (display) {
        cv::namedWindow("RGB", cv::WINDOW_AUTOSIZE);
        cv::namedWindow("IR", cv::WINDOW_AUTOSIZE);
        cv::namedWindow("Depth", cv::WINDOW_AUTOSIZE);
    }
}

FrameData KinectV2Controller::wait_for_next_frame() {
    libfreenect2::FrameMap frames;
    if (!listener.waitForNewFrame(frames, 10 * 1000)) { // 10 seconds
        std::cout << "Timeout!" << std::endl;
        return {};  // Return an empty vector if there's a timeout
    }

    auto rgb = frames.at(libfreenect2::Frame::Color);
    auto ir = frames.at(libfreenect2::Frame::Ir);
    auto depth = frames.at(libfreenect2::Frame::Depth);
    
    cv::Mat rgbMat(rgb->height, rgb->width, CV_8UC4, rgb->data);
    cv::Mat irMat(ir->height, ir->width, CV_32FC1, ir->data);
    irMat = irMat / 65535.0f;
    cv::Mat depthMat(depth->height, depth->width, CV_32FC1, depth->data);

    if (display) {
        cv::imshow("RGB", rgbMat);
        cv::imshow("IR", irMat); // Normalize the IR image
        cv::imshow("Depth", depthMat / 100.0f); // Normalize the depth to be visible
        int key = cv::waitKey(1);
        if (key == 'q' || key == 'Q' || key == 27) {
            protonect_shutdown = true;
        }
    }
    
    std::vector<unsigned char> rgb_data(rgbMat.data, rgbMat.data + rgbMat.total() * rgbMat.elemSize());
    std::vector<float> ir_data((float*)irMat.data, (float*)irMat.data + irMat.total());
    std::vector<float> depth_data((float*)depthMat.data, (float*)depthMat.data + depthMat.total());

    listener.release(frames);
    return {rgb_data, ir_data, depth_data};
}

void KinectV2Controller::stop() {
    dev->stop();
    cv::destroyAllWindows();
}

void KinectV2Controller::sigint_handler(int s) {
    protonect_shutdown = true;
}

int main(int argc, char *argv[]) {
    try {
        KinectV2Controller kinect(true);
        kinect.start();
        while (!KinectV2Controller::protonect_shutdown) {
            auto frames = kinect.wait_for_next_frame();
            // Optional: Process frames here
        }
        kinect.stop();
    } catch (std::exception& e) {
        std::cerr << "Exception: " << e.what() << std::endl;
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
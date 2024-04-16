from freenect2 import PyKinectV2Controller

def test_kinect_controller():
    # Create an instance of PyKinectV2Controller
    kinect = PyKinectV2Controller(display=True)

    # Start the controller
    kinect.start()
    
    while True:
        # Get the frames
        frame = kinect.wait_for_next_frame()
        print('Frame type:', type(frame))
        print(type(frame[0]))
        print("Frame found")

    # Stop the controller
    controller.stop()


if __name__ == "__main__":
    test_kinect_controller()
from freenect2 import Freenect2
import cv2
import numpy as np

def test_freenect2():
    # Create an instance of Freenect2
    kinect = Freenect2(display=False)

    # Start the controller
    kinect.start()
    
    frame_num = 0;
    
    while True:
        print("Frame#:", frame_num)
        frame_num += 1
        # Get the frames
        rgb, ir, depth = kinect.wait_for_next_frame()
        
        # Display the frames
        cv2.imshow("RGB", rgb)
        cv2.imshow("IR", ir)
        cv2.imshow("Depth", depth)

        # Break the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Destroy all windows
    cv2.destroyAllWindows()

    # Stop the controller
    kinect.stop()


if __name__ == "__main__":
    test_freenect2()
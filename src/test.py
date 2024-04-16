from freenect2 import PyKinectV2Controller
import cv2
import numpy as np

def test_kinect_controller():
    # Create an instance of PyKinectV2Controller
    kinect = PyKinectV2Controller(display=False)

    # Start the controller
    kinect.start()
    
    frame_num = 0;
    
    while True:
        print("Frame#:", frame_num)
        frame_num += 1
        # Get the frames
        rgb, ir, depth = kinect.wait_for_next_frame()

        # Check if the frames are empty
        print (type(rgb))
        # print(result.keys())
        # print (result)
        print (type(rgb))
        # ir = result.ir
        # depth = result.depth
        # print (type(ir))
        # print (ir)
        # print (type(depth))
        # print (depth)
        # if not rgb or not ir or not depth:
        #     print("Empty frame")
        #     continue
        # else:
        #     print("Got frame")
        
        # print(len(rgb))
        # print(rgb)
            
        # print("RGB Type:", type(rgb))
        # print("")
        # # Convert the frames to numpy arrays
        # rgb = np.fromiter(rgb, dtype=np.uint8).reshape(1080, 1920, 4)
        # ir = np.array(ir).reshape(424, 512)
        # depth = np.array(depth).reshape(424, 512)

        # # Display the frames
        
        cv2.imshow("RGB", rgb)
        # cv2.imshow("IR", ir)
        # cv2.imshow("Depth", depth)

        # Break the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Destroy all windows
    cv2.destroyAllWindows()

    # Stop the controller
    kinect.stop()


if __name__ == "__main__":
    test_kinect_controller()
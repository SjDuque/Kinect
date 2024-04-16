add_rules("mode.debug", "mode.release")

target("kinect-v2-opencv")
    set_kind("binary")
    add_files("src/cxx/*.cpp")

    -- Include directories
    add_includedirs("/opt/homebrew/include", "include/cxx")

    -- Link against libraries
    add_links("freenect2", "opencv_core", "opencv_imgproc", "opencv_highgui", "opencv_videoio")

    -- Library search directories
    add_linkdirs("/opt/homebrew/lib")

    -- Runtime library paths
    add_rpathdirs("/opt/homebrew/lib")

    -- C++ standard
    set_languages("cxx11")

    -- Post-build action
    after_build(function (target)
        print("Build completed for: " .. target:name())
    end)

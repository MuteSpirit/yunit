include_directories(. "${PROJECT_SOURCE_DIR}/lua")
add_library(lfs SHARED lfs.c lfs.def)
target_link_libraries(lfs lua5.1)
add_dependencies(lfs lua51lib)

if(WIN32)
    install(TARGETS lfs
            RUNTIME DESTINATION 5.1
            LIBRARY DESTINATION 5.1/lib
            ARCHIVE DESTINATION 5.1/lib)
    install(FILES lfs.h DESTINATION 5.1/include)
else(WIN32)
    install(TARGETS lfs DESTINATION lib/lua/5.1)
    install(FILES lfs.h DESTINATION include/lua5.1)
endif(WIN32)
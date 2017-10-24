set(PREFIX ${CMAKE_CURRENT_LIST_DIR})
set(chaos_INCLUDE_DIRS ${PREFIX}/include)
FILE(GLOB boost_libs ${PREFIX}/lib/libboost*.a)
set(chaos_LIBRARIES ${PREFIX}/lib/libchaos_metadata_service_client.so ${PREFIX}/lib/libchaos_common.so ${PREFIX}/lib/libchaos_cutoolkit.so )

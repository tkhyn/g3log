if(IOS_PLATFORM)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Binaries)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Binaries)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/Binaries)
 endif(IOS_PLATFORM)


if(G3_IOS_LIB)
	set(TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/iOS.cmake")

	set(SIM_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/build.i386" CACHE INTERNAL "")
	set(SIM_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "")

	set(SIM64_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/build.x86_64" CACHE INTERNAL "")
	set(SIM64_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "")

	set(ARM_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/build.arm" CACHE INTERNAL "")
	set(ARM_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "")

	file(MAKE_DIRECTORY ${SIM_BINARY_DIR})
	execute_process(WORKING_DIRECTORY ${SIM_BINARY_DIR}
	  COMMAND ${CMAKE_COMMAND}
    	-GXcode
	    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
	    -DIOS_PLATFORM=SIMULATOR
	    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
		-DADD_FATAL_EXAMPLE=OFF
		-DADD_G3LOG_BENCH_PERFORMANCE=OFF
		-DADD_G3LOG_UNIT_TEST=OFF
	    -DG3_SHARED_LIB=OFF
	    -DCHANGE_G3LOG_DEBUG_TO_DBUG=ON
	    -DUSE_G3_DYNAMIC_MAX_MESSAGE_SIZE=${USE_G3_DYNAMIC_MAX_MESSAGE_SIZE}
	    "${SIM_SOURCE_DIR}"
    )

	file(MAKE_DIRECTORY ${SIM64_BINARY_DIR})
	execute_process(WORKING_DIRECTORY ${SIM64_BINARY_DIR}
	  COMMAND ${CMAKE_COMMAND}
	    -GXcode
	    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
	    -DIOS_PLATFORM=SIMULATOR64
	    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
		-DADD_FATAL_EXAMPLE=OFF
	    -DG3_SHARED_LIB=OFF
		-DADD_G3LOG_BENCH_PERFORMANCE=OFF
		-DADD_G3LOG_UNIT_TEST=OFF
	    -DCHANGE_G3LOG_DEBUG_TO_DBUG=ON
	    -DUSE_G3_DYNAMIC_MAX_MESSAGE_SIZE=${USE_G3_DYNAMIC_MAX_MESSAGE_SIZE}
	    "${SIM64_SOURCE_DIR}"
	)

	file(MAKE_DIRECTORY ${ARM_BINARY_DIR})
	execute_process(WORKING_DIRECTORY ${ARM_BINARY_DIR}
	  COMMAND ${CMAKE_COMMAND}
	    -GXcode
	    -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
	    -DIOS_PLATFORM=OS
	    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
		-DADD_FATAL_EXAMPLE=OFF
	    -DG3_SHARED_LIB=OFF
		-DADD_G3LOG_BENCH_PERFORMANCE=OFF
		-DADD_G3LOG_UNIT_TEST=OFF
	    -DCHANGE_G3LOG_DEBUG_TO_DBUG=ON
	    -DUSE_G3_DYNAMIC_MAX_MESSAGE_SIZE=${USE_G3_DYNAMIC_MAX_MESSAGE_SIZE}
	    "${ARM_SOURCE_DIR}"
    )

	## Simulator i386 version
	add_custom_target(sim
	  COMMAND ${CMAKE_COMMAND}
	    --build ${SIM_BINARY_DIR}
	    --config ${CMAKE_BUILD_TYPE}
	  COMMENT "Building for i386 (simulator)"
	  VERBATIM
	)

	## Simulator x86_64 version
	add_custom_target(sim64
	  COMMAND ${CMAKE_COMMAND}
	    --build ${SIM64_BINARY_DIR}
	    --config ${CMAKE_BUILD_TYPE}
	    COMMENT "Building for x86_64 (simulator)"
		VERBATIM
	)

	## ARM version
	add_custom_target(arm
	  COMMAND ${CMAKE_COMMAND}
	    --build ${ARM_BINARY_DIR}
	    --config ${CMAKE_BUILD_TYPE}
	  COMMENT "Building for armv7, armv7s, arm64"
	  VERBATIM
	)

	set(LIB_G3 libg3logger.a)
	add_custom_command(
	  OUTPUT ${LIB_G3}
	  COMMAND lipo -create
	    -output "${CMAKE_CURRENT_BINARY_DIR}/${LIB_G3}"
	    ${SIM_BINARY_DIR}/Binaries/${CMAKE_BUILD_TYPE}/${LIB_G3}
	    ${SIM64_BINARY_DIR}/Binaries/${CMAKE_BUILD_TYPE}/${LIB_G3}
	    ${ARM_BINARY_DIR}/Binaries/${CMAKE_BUILD_TYPE}/${LIB_G3}
	  DEPENDS
	    sim
	    sim64
	    arm
	    "${SIM_BINARY_DIR}/Binaries/${CMAKE_BUILD_TYPE}/${LIB_G3}"
	    "${SIM64_BINARY_DIR}/Binaries/${CMAKE_BUILD_TYPE}/${LIB_G3}"
	    "${ARM_BINARY_DIR}/Binaries/${CMAKE_BUILD_TYPE}/${LIB_G3}"
	 VERBATIM
	)
	add_custom_target(g3logger ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${LIB_G3})
endif(G3_IOS_LIB)


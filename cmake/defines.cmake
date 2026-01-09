include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/find_cpm.cmake)

CPMAddPackage(
		NAME PrometheusCore
		GIT_TAG v1.0.3
		GITHUB_REPOSITORY "Life4gal/core"
		OPTIONS 
		"PROMETHEUS_CORE_TEST OFF"
		"PROMETHEUS_CORE_INSTALL ${PROMETHEUS_CLP_INSTALL}"
)

# ===================================================================================================
# PLATFORM

# CORE ==> PLATFORM

# ===================================================================================================
# ARCHITECTURE

# CORE ==> ARCHITECTURE

# ===================================================================================================
# COMPILER

# CORE ==> COMPILER

# ===================================================================================================
# COMPILE FLAGS

# CORE ==> COMPILE FLAGS

# ===================================================================================================
# GIT

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/git.cmake)

# ===================================================================================================
# OUTPUT INFO

message(STATUS "")
message(STATUS "================================================================")
message(STATUS "  ${PROJECT_NAME} - v${PROMETHEUS_CLP_VERSION}")
message(STATUS "================================================================")
# PLATFORM + ARCHITECTURE + COMPILER + COMPILE FLAGS
message(STATUS "  Platform: ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "  CMake Version: ${CMAKE_VERSION}")
message(STATUS "  Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  Compile Flags: ${PROMETHEUS_COMPILE_FLAGS}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Build Test: ${PROMETHEUS_CLP_TEST}")
# GIT
if(PROJECT_IS_TOP_LEVEL)
	message(STATUS "  Git: ")
	message(STATUS "      Branch: ${PROMETHEUS_CLP_GIT_BRANCH_NAME}")
	message(STATUS "      Commit: ${PROMETHEUS_CLP_GIT_COMMIT_HASH}${PROMETHEUS_CLP_GIT_DIRTY_FLAG}")
	message(STATUS "      Date: ${PROMETHEUS_CLP_GIT_COMMIT_DATE}")
	message(STATUS "      Tag: ${PROMETHEUS_CLP_GIT_TAG}")
	message(STATUS "      Status: ${PROMETHEUS_CLP_GIT_DIRTY_STATUS}")
	message(STATUS "================================================================")
	message(STATUS "")
else()
endif(PROJECT_IS_TOP_LEVEL)


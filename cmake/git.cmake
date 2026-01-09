find_package(Git QUIET)
if(NOT GIT_FOUND)
	message(WARNING "Git not found - version information will not be available")
	set(GIT_AVAILABLE FALSE)
else()
	execute_process(
		COMMAND ${GIT_EXECUTABLE} rev-parse --is-inside-work-tree
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE IS_GIT_REPO
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
		RESULT_VARIABLE GIT_REPO_CHECK_RESULT
	)
	
	if(NOT GIT_REPO_CHECK_RESULT EQUAL "0")
		message(WARNING "Not a Git repository - version information will not be available")
		set(GIT_AVAILABLE FALSE)
	else()
		set(GIT_AVAILABLE TRUE)
	endif()
endif()

if(NOT GIT_AVAILABLE)
	set(PROMETHEUS_CLP_GIT_BRANCH_NAME "unknown")
	set(PROMETHEUS_CLP_GIT_COMMIT_HASH "unknown")
	set(PROMETHEUS_CLP_GIT_COMMIT_DATE "unknown")
	set(PROMETHEUS_CLP_GIT_DIRTY_FLAG "unknown")
	set(PROMETHEUS_CLP_GIT_TAG "unknown")
	set(PROMETHEUS_CLP_GIT_COMMIT_INFO "unknown")
else()
	# ============================================
	# 1. Get branch name
	# ============================================
	execute_process(
		COMMAND ${GIT_EXECUTABLE} symbolic-ref --short HEAD
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE PROMETHEUS_CLP_GIT_BRANCH_NAME
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
		RESULT_VARIABLE BRANCH_RESULT
	)
	
	if(NOT BRANCH_RESULT EQUAL "0")
		execute_process(
			COMMAND ${GIT_EXECUTABLE} describe --contains --all HEAD
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			OUTPUT_VARIABLE PROMETHEUS_CLP_GIT_BRANCH_NAME
			OUTPUT_STRIP_TRAILING_WHITESPACE
			ERROR_QUIET
		)
	endif()
	
	if(NOT PROMETHEUS_CLP_GIT_BRANCH_NAME)
		set(PROMETHEUS_CLP_GIT_BRANCH_NAME "detached")
	endif()
	
	# ============================================
	# 2. Commit Hash
	# ============================================
	execute_process(
		COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE PROMETHEUS_CLP_GIT_COMMIT_HASH
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
		RESULT_VARIABLE HASH_RESULT
	)

	if(HASH_RESULT EQUAL "0")
		set(HAS_HASH_INFO 1)
	else()
		set(HAS_HASH_INFO 0)
	endif()
	
	# ============================================
	# 3. Commit Date
	# ============================================
	if(HAS_HASH_INFO)
		execute_process(
			COMMAND ${GIT_EXECUTABLE} log -1 --format=%cd --date=iso-strict
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			OUTPUT_VARIABLE PROMETHEUS_CLP_GIT_COMMIT_DATE
			OUTPUT_STRIP_TRAILING_WHITESPACE
			ERROR_QUIET
		)
	else()
		set(PROMETHEUS_CLP_GIT_COMMIT_DATE "1970-01-01T00:00:00+00:00")
	endif()

	
	# ============================================
	# 4. Dirty flag
	# ============================================
	if(HAS_HASH_INFO)
		execute_process(
			COMMAND ${GIT_EXECUTABLE} diff-index --quiet HEAD --
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			RESULT_VARIABLE PROMETHEUS_CLP_GIT_DIRTY
			ERROR_QUIET
		)
	
		if(PROMETHEUS_CLP_GIT_DIRTY EQUAL "0")
			set(PROMETHEUS_CLP_GIT_DIRTY_FLAG "")
			set(PROMETHEUS_CLP_GIT_DIRTY_STATUS "clean")
		else()
			set(PROMETHEUS_CLP_GIT_DIRTY_FLAG "-dirty")
			set(PROMETHEUS_CLP_GIT_DIRTY_STATUS "dirty")
		endif()
	else()
		set(PROMETHEUS_CLP_GIT_DIRTY_FLAG "")
		set(PROMETHEUS_CLP_GIT_DIRTY_STATUS "unknown")
	endif()

	# ============================================
	# 5. TAG
	# ============================================
	if(HAS_HASH_INFO)
		execute_process(
			COMMAND ${GIT_EXECUTABLE} describe --tags --exact-match
			WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
			OUTPUT_VARIABLE PROMETHEUS_CLP_GIT_TAG
			OUTPUT_STRIP_TRAILING_WHITESPACE
			ERROR_QUIET
		)
	
		if(NOT PROMETHEUS_CLP_GIT_TAG)
			set(PROMETHEUS_CLP_GIT_TAG "none")
		endif()
	else()
		set(PROMETHEUS_CLP_GIT_TAG "none")
	endif()
	
	# ============================================
	# 6. Remote URL
	# ============================================
	execute_process(
		COMMAND ${GIT_EXECUTABLE} config --get remote.origin.url
		WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
		OUTPUT_VARIABLE PROMETHEUS_CLP_GIT_REMOTE_URL
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
	)
	
	# ============================================
	# 7. Commit Info
	# ============================================
	if(NOT HAS_HASH_INFO)
		set(PROMETHEUS_CLP_GIT_COMMIT_INFO "empty repository")
		set(PROMETHEUS_CLP_GIT_COMMIT_INFO_SHORT "empty")
		set(PROMETHEUS_CLP_GIT_COMMIT_INFO_FULL "empty repository")
	else()
		string(REPLACE "T" " " DATE_WITHOUT_T "${PROMETHEUS_CLP_GIT_COMMIT_DATE}")
		string(REGEX REPLACE "\\+.*$" "" DATE_SHORT "${DATE_WITHOUT_T}")
		
		set(
			PROMETHEUS_CLP_GIT_COMMIT_INFO_SHORT 
			"${PROMETHEUS_CLP_GIT_BRANCH_NAME}/${PROMETHEUS_CLP_GIT_COMMIT_HASH}${PROMETHEUS_CLP_GIT_DIRTY_FLAG}"
		)
		
		set(
			PROMETHEUS_CLP_GIT_COMMIT_INFO 
			"${PROMETHEUS_CLP_GIT_BRANCH_NAME}/${PROMETHEUS_CLP_GIT_COMMIT_HASH}${PROMETHEUS_CLP_GIT_DIRTY_FLAG} (${DATE_SHORT})"
		)
		
		set(
			PROMETHEUS_CLP_GIT_COMMIT_INFO_FULL 
			"branch:${PROMETHEUS_CLP_GIT_BRANCH_NAME} hash:${PROMETHEUS_CLP_GIT_COMMIT_HASH}${PROMETHEUS_CLP_GIT_DIRTY_FLAG} date:${PROMETHEUS_CLP_GIT_COMMIT_DATE} tag:${PROMETHEUS_CLP_GIT_TAG}"
		)
	endif()
endif()

set(
	PROMETHEUS_CLP_GIT_BRANCH_NAME 
	"${PROMETHEUS_CLP_GIT_BRANCH_NAME}" 
	CACHE STRING "${PROJECT_NAME} git branch name"
)
set(
	PROMETHEUS_CLP_GIT_COMMIT_HASH 
	"${PROMETHEUS_CLP_GIT_COMMIT_HASH}" 
	CACHE STRING "${PROJECT_NAME} git commit hash"
)
set(
	PROMETHEUS_CLP_GIT_COMMIT_DATE 
	"${PROMETHEUS_CLP_GIT_COMMIT_DATE}" 
	CACHE STRING "${PROJECT_NAME} git commit date"
)
set(
	PROMETHEUS_CLP_GIT_DIRTY_FLAG 
	"${PROMETHEUS_CLP_GIT_DIRTY_FLAG}" 
	CACHE STRING "${PROJECT_NAME} git dirty flag"
)
set(
	PROMETHEUS_CLP_GIT_DIRTY_STATUS 
	"${PROMETHEUS_CLP_GIT_DIRTY_STATUS}" 
	CACHE STRING "${PROJECT_NAME} git dirty status"
)
set(
	PROMETHEUS_CLP_GIT_TAG 
	"${PROMETHEUS_CLP_GIT_TAG}" 
	CACHE STRING "${PROJECT_NAME} git tag"
)
set(
	PROMETHEUS_CLP_GIT_REMOTE_URL 
	"${PROMETHEUS_CLP_GIT_REMOTE_URL}" 
	CACHE STRING "${PROJECT_NAME} git remote url"
)
set(
	PROMETHEUS_CLP_GIT_COMMIT_INFO 
	"${PROMETHEUS_CLP_GIT_COMMIT_INFO}" 
	CACHE STRING "${PROJECT_NAME} git commit info"
)
set(
	PROMETHEUS_CLP_GIT_COMMIT_INFO_SHORT 
	"${PROMETHEUS_CLP_GIT_COMMIT_INFO_SHORT}" 
	CACHE STRING "${PROJECT_NAME} git commit info (short)"
)
set(
	PROMETHEUS_CLP_GIT_COMMIT_INFO_FULL 
	"${PROMETHEUS_CLP_GIT_COMMIT_INFO_FULL}" 
	CACHE STRING "${PROJECT_NAME} git commit info (full)"
)

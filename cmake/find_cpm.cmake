# Set CPM Local Path
set(CPM_LOCAL_PATH "${PROJECT_SOURCE_DIR}/cmake/CPM.cmake")
set(CPM_GITHUB_URL "https://github.com/cpm-cmake/CPM.cmake")
set(CPM_REPO_URL "${CPM_GITHUB_URL}.git")

# ============================================
# Detect whether CPM has been imported
# ============================================
if(DEFINED CURRENT_CPM_VERSION)
    message(STATUS "[PROMETHEUS] [CPM] CPM already included (v${CURRENT_CPM_VERSION})")
    # If already loaded, return directly to avoid duplicate processing
    return()
endif()

# Check if other projects have already downloaded CPM
if(EXISTS "${CPM_LOCAL_PATH}")
    # Attempt to read the file contents to verify if it is a CPM file.
    file(READ "${CPM_LOCAL_PATH}" CPM_FILE_CONTENT LIMIT 200)
    if(CPM_FILE_CONTENT MATCHES ".*CPM\\.cmake.*")
        message(STATUS "[PROMETHEUS] [CPM] Found existing CPM file at: ${CPM_LOCAL_PATH}")
        # First include existing files, then check for updates.
        set(CPM_USE_LOCAL_PACKAGES ON)
        include("${CPM_LOCAL_PATH}")
        
        set(CPM_INCLUDED_BY_PROMETHEUS TRUE CACHE INTERNAL "CPM included by Prometheus")
    else()
        message(WARNING "[PROMETHEUS] [CPM] File exists but doesn't appear to be CPM.cmake")
        file(REMOVE "${CPM_LOCAL_PATH}")
    endif()
endif()

# ============================================
# Ensure the cmake directory exists
# ============================================
get_filename_component(CPM_DIR "${CPM_LOCAL_PATH}" DIRECTORY)
if(NOT EXISTS "${CPM_DIR}")
    file(MAKE_DIRECTORY "${CPM_DIR}")
    message(STATUS "[PROMETHEUS] [CPM] Created directory: ${CPM_DIR}")
endif()

# ============================================
# Attempt to obtain the latest version (if necessary)
# ============================================
if(NOT DEFINED CPM_LATEST_VERSION)
    message(STATUS "[PROMETHEUS] [CPM] Fetching latest version information...")
    
    # Check network connection (optional)
    option(CPM_CHECK_NETWORK "Check network connectivity for CPM updates" ON)
    
    if(CPM_CHECK_NETWORK)
        find_program(GIT_EXE NAMES git)
        
        if(GIT_EXE)
            execute_process(
                COMMAND
                ${GIT_EXE} ls-remote --tags --sort=-v:refname "${CPM_REPO_URL}"
                OUTPUT_VARIABLE TAG_LIST
                ERROR_VARIABLE ERROR_MESSAGE
                RESULT_VARIABLE RESULT
                TIMEOUT 10
            )
            
            if(RESULT EQUAL 0 AND TAG_LIST)
                # Retrieve the latest version tag
                string(REGEX MATCH "refs/tags/(v[0-9]+\\.[0-9]+\\.[0-9]+[^ \n]*)" LATEST_TAG "${TAG_LIST}")
                if(CMAKE_MATCH_1)
                    set(CPM_LATEST_VERSION "${CMAKE_MATCH_1}")
                    message(STATUS "[PROMETHEUS] [CPM] Latest version detected: ${CPM_LATEST_VERSION}")
                else()
                    message(STATUS "[PROMETHEUS] [CPM] Could not parse version from tags, using fallback")
                endif()
            else()
                message(STATUS "[PROMETHEUS] [CPM] Cannot fetch latest version: ${ERROR_MESSAGE}")
            endif()
        else()
            message(STATUS "[PROMETHEUS] [CPM] Git not found, using fallback version")
        endif()
    else()
        message(STATUS "[PROMETHEUS] [CPM] Network check disabled, using fallback version")
    endif()
    
    # If the latest version is not available, use the default version.
    if(NOT DEFINED CPM_LATEST_VERSION)
        # Check if an environment variable specifies the version
        if(DEFINED ENV{CPM_VERSION})
            set(CPM_LATEST_VERSION "$ENV{CPM_VERSION}")
            message(STATUS "[PROMETHEUS] [CPM] Using version from environment: ${CPM_LATEST_VERSION}")
        else()
            # Default Fallback Version
            set(CPM_LATEST_VERSION "v0.40.2")
            message(STATUS "[PROMETHEUS] [CPM] Using fallback version: ${CPM_LATEST_VERSION}")
        endif()
    endif()
    
    # Cache Version Information
    set(
        CPM_LATEST_VERSION
        ${CPM_LATEST_VERSION}
        CACHE
        STRING
        "Latest CPM.cmake version"
    )
    message(STATUS "[PROMETHEUS] [CPM] Using CPM version: ${CPM_LATEST_VERSION}")
endif()

# ============================================
# Set Download URL
# ============================================
set(CPM_GITHUB_DOWNLOAD_URL "${CPM_GITHUB_URL}/releases/download/${CPM_LATEST_VERSION}/CPM.cmake")

# ============================================
# Download the file (if it does not exist)
# ============================================
if(NOT EXISTS "${CPM_LOCAL_PATH}")
    message(STATUS "[PROMETHEUS] [CPM] File not found, downloading from ${CPM_LATEST_VERSION}...")
    
    message(STATUS "[PROMETHEUS] [CPM] Downloading: ${CPM_GITHUB_DOWNLOAD_URL}")
    
    # Use TLS authentication (can be disabled)
    option(CPM_VERIFY_SSL "Verify SSL certificates when downloading CPM" ON)
    if(NOT CPM_VERIFY_SSL)
        set(TLS_VERIFY "TLS_VERIFY OFF")
    else()
        set(TLS_VERIFY "")
    endif()
    
    file(DOWNLOAD
        "${CPM_GITHUB_DOWNLOAD_URL}"
        "${CPM_LOCAL_PATH}"
        STATUS DOWNLOAD_STATUS
        TIMEOUT 60
        INACTIVITY_TIMEOUT 30
        ${TLS_VERIFY}
        LOG DOWNLOAD_LOG
    )
    
    list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
    list(GET DOWNLOAD_STATUS 1 STATUS_MESSAGE)
    
    if(STATUS_CODE EQUAL 0)
        message(STATUS "[PROMETHEUS] [CPM] Successfully downloaded to: ${CPM_LOCAL_PATH}")
    else()
        # Try using curl/wget as an alternative solution.
        message(STATUS "[PROMETHEUS] [CPM] CMake download failed, trying alternative methods...")
        
        # Clean up failed files
        if(EXISTS "${CPM_LOCAL_PATH}")
            file(REMOVE "${CPM_LOCAL_PATH}")
        endif()
        
        # Try using curl
        find_program(CURL_EXE NAMES curl)
        if(CURL_EXE)
            message(STATUS "[PROMETHEUS] [CPM] Trying curl...")
            execute_process(
                COMMAND ${CURL_EXE} -L -o "${CPM_LOCAL_PATH}" "${CPM_GITHUB_DOWNLOAD_URL}"
                RESULT_VARIABLE CURL_RESULT
                ERROR_VARIABLE CURL_ERROR
            )
            
            if(CURL_RESULT EQUAL 0)
                message(STATUS "[PROMETHEUS] [CPM] Successfully downloaded using curl")
                set(STATUS_CODE 0)
            endif()
        endif()
        
        # If curl fails, try wget
        if(NOT STATUS_CODE EQUAL 0)
            find_program(WGET_EXE NAMES wget)
            if(WGET_EXE)
                message(STATUS "[PROMETHEUS] [CPM] Trying wget...")
                execute_process(
                    COMMAND ${WGET_EXE} -O "${CPM_LOCAL_PATH}" "${CPM_GITHUB_DOWNLOAD_URL}"
                    RESULT_VARIABLE WGET_RESULT
                    ERROR_VARIABLE WGET_ERROR
                )
                
                if(WGET_RESULT EQUAL 0)
                    message(STATUS "[PROMETHEUS] [CPM] Successfully downloaded using wget")
                    set(STATUS_CODE 0)
                endif()
            endif()
        endif()
        
        # If all methods fail
        if(NOT STATUS_CODE EQUAL 0)
            message(
                FATAL_ERROR 
                "[PROMETHEUS] [CPM] All download attempts failed\n"
                "CMake error: ${STATUS_MESSAGE}\n"
                "URL: ${CPM_GITHUB_DOWNLOAD_URL}\n"
                "You can manually download CPM.cmake to: ${CPM_LOCAL_PATH}"
            )
        endif()
    endif()
endif()

# ============================================
# Include CPM (if not already included)
# ============================================
if(NOT DEFINED CURRENT_CPM_VERSION)
    set(CPM_USE_LOCAL_PACKAGES ON)
    include("${CPM_LOCAL_PATH}")
    
    set(CPM_INCLUDED_BY_PROMETHEUS TRUE CACHE INTERNAL "CPM included by Prometheus")
    
    if(DEFINED CPM_VERSION)
        message(STATUS "[PROMETHEUS] [CPM] Loaded CPM v${CPM_VERSION}")
    else()
        message(STATUS "[PROMETHEUS] [CPM] Loaded CPM from: ${CPM_LOCAL_PATH}")
    endif()
endif()

# ============================================
# Check for version updates (if version information exists and is not imported from a parent project)
# ============================================
if(DEFINED CPM_INCLUDED_BY_PROMETHEUS AND DEFINED CURRENT_CPM_VERSION AND DEFINED CPM_LATEST_VERSION)
    message(STATUS "[PROMETHEUS] [CPM] Current version: v${CURRENT_CPM_VERSION}")
    message(STATUS "[PROMETHEUS] [CPM] Latest version: ${CPM_LATEST_VERSION}")
    
    if(NOT "v${CURRENT_CPM_VERSION}" STREQUAL "${CPM_LATEST_VERSION}")
        message(STATUS "[PROMETHEUS] [CPM] Update available (v${CURRENT_CPM_VERSION} -> ${CPM_LATEST_VERSION})")
        
        # Configure Update Behavior
        option(CPM_AUTO_UPDATE "Automatically update CPM.cmake when new version is available" OFF)
        option(CPM_UPDATE_NOTIFY "Notify when CPM update is available" ON)
        
        if(CPM_AUTO_UPDATE)
            message(STATUS "[PROMETHEUS] [CPM] Auto-update enabled, downloading update...")
            
            set(TEMP_FILE "${CPM_LOCAL_PATH}.update")
            file(DOWNLOAD
                "${CPM_GITHUB_DOWNLOAD_URL}"
                "${TEMP_FILE}"
                STATUS DOWNLOAD_STATUS
                TIMEOUT 60
                INACTIVITY_TIMEOUT 30
                ${TLS_VERIFY}
            )
            
            list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
            list(GET DOWNLOAD_STATUS 1 STATUS_MESSAGE)
            
            if(STATUS_CODE EQUAL 0)
                # Verify the validity of downloaded files
                file(READ "${TEMP_FILE}" FIRST_LINE LIMIT 100)
                if(FIRST_LINE MATCHES ".*CPM.*")
                    # Back up old files
                    string(TIMESTAMP TIMESTAMP "%Y%m%d-%H%M%S")
                    set(BACKUP_FILE "${CPM_LOCAL_PATH}.backup.${TIMESTAMP}")
                    
                    # Rename the old file, then move the new file
                    configure_file("${CPM_LOCAL_PATH}" "${BACKUP_FILE}" COPYONLY)
                    file(RENAME "${TEMP_FILE}" "${CPM_LOCAL_PATH}")
                    
                    message(STATUS "[PROMETHEUS] [CPM] Updated successfully!")
                    message(STATUS "[PROMETHEUS] [CPM] Old version backed up to: ${BACKUP_FILE}")
                    
                    # Important Notice: Reconfiguration is required
                    message(
                        WARNING 
                        "[PROMETHEUS] [CPM] CPM version has been updated from v${CURRENT_CPM_VERSION} to ${CPM_LATEST_VERSION}.\n"
                        "Please reconfigure your CMake project to use the new version."
                    )
                else()
                    file(REMOVE "${TEMP_FILE}")
                    message(WARNING "[PROMETHEUS] [CPM] Downloaded file appears invalid, keeping current version")
                endif()
            else()
                file(REMOVE "${TEMP_FILE}")
                message(
                    WARNING 
                    "[PROMETHEUS] [CPM] Update download failed (${STATUS_CODE}): ${STATUS_MESSAGE}\n"
                    "Keeping current version v${CURRENT_CPM_VERSION}"
                )
            endif()
        elseif(CPM_UPDATE_NOTIFY)
            message(STATUS "[PROMETHEUS] [CPM] Update available but auto-update is disabled.")
            message(STATUS "[PROMETHEUS] [CPM] To update manually, run: cmake -DCPM_AUTO_UPDATE=ON ${CMAKE_BINARY_DIR}")
            message(STATUS "[PROMETHEUS] [CPM] Or delete: ${CPM_LOCAL_PATH} and reconfigure")
        endif()
    else()
        message(STATUS "[PROMETHEUS] [CPM] CPM is up to date (v${CURRENT_CPM_VERSION})")
    endif()
endif()

# ============================================
# Verify whether CPM has loaded successfully
# ============================================
if(NOT DEFINED CPM_VERSION AND NOT DEFINED CURRENT_CPM_VERSION)
    message(WARNING "[PROMETHEUS] [CPM] CPM may not have loaded correctly")
elseif(DEFINED CPM_INCLUDED_BY_PROMETHEUS)
    message(STATUS "[PROMETHEUS] [CPM] CPM ready for use")
endif()

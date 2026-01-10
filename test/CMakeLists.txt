project(
	PrometheusCLPTest
	LANGUAGES CXX
)

add_executable(
	${PROJECT_NAME}-optional

	${CMAKE_CURRENT_SOURCE_DIR}/main-optional.cpp
) 
add_executable(
	${PROJECT_NAME}-expected

	${CMAKE_CURRENT_SOURCE_DIR}/main-expected.cpp
) 

target_link_libraries(
	${PROJECT_NAME}-optional
	PRIVATE 
	PrometheusCLP
)
target_link_libraries(
	${PROJECT_NAME}-expected
	PRIVATE 
	PrometheusCLP
)

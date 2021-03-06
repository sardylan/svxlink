# Find the popt library
find_package(Popt REQUIRED)
set(LIBS ${LIBS} ${POPT_LIBRARIES})
include_directories(${POPT_INCLUDE_DIRS})
add_definitions(${POPT_DEFINITIONS})

# Find the GCrypt library
find_package(GCrypt REQUIRED)
set(LIBS ${LIBS} ${GCRYPT_LIBRARIES})
include_directories(${GCRYPT_INCLUDE_DIRS})
add_definitions(${GCRYPT_DEFINITIONS})

# Add project libraries
set(LIBS ${LIBS} asynccpp asyncaudio asynccore svxmisc)

# Build the executable
add_executable(svxreflector
  svxreflector.cpp Reflector.cpp ReflectorClient.cpp
)
target_link_libraries(svxreflector ${LIBS})
set_target_properties(svxreflector PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY}
)
add_dependencies(svxreflector version-svxreflector)

# Install targets
install(TARGETS svxreflector DESTINATION ${BIN_INSTALL_DIR})
install_if_not_exists(svxreflector.conf ${SVX_SYSCONF_INSTALL_DIR})

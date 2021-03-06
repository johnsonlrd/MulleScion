cmake_minimum_required (VERSION 3.0)

project (MulleScion)


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/mulle-configuration/cmake)
message(STATUS "CMAKE_MODULE_PATH is ${CMAKE_MODULE_PATH}")
message(STATUS "CMAKE_BUILD_TYPE is ${CMAKE_BUILD_TYPE}")

set( MULLE_LANGUAGE "ObjC")

if( "${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
  include( Debug)
else()
  include( Release)
endif()

include( CMakeSourcesAndHeaders.txt )

set( GOOGLE_TOOLBOX_SOURCES
"google-toolbox-for-mac/Foundation/GTMNSString+HTML.m"
)


set( HEADERS
${MULLE_SCION_HEADERS}
${MULLE_SCION_FOUNDATION_HEADERS}
${MULLE_SCION_PARSER_HEADERS}
${MULLE_SCION_PRINTER_HEADERS}
)

# move to mulle-configuration ?
set( CMAKE_FIND_FRAMEWORK "LAST")

find_library( FOUNDATION_LIBRARY NAMES Foundation)
message( STATUS "FOUNDATION_LIBRARY is ${FOUNDATION_LIBRARY}")
FIND_PACKAGE( ZLIB REQUIRED)

message( STATUS "FOUNDATION_LIBRARY is ${FOUNDATION_LIBRARY}")
message( STATUS "ZLIB_LIBRARIES is ${ZLIB_LIBRARIES}")

add_definitions( -DPROJECT_VERSION=1858.2)


add_library( MulleScion STATIC
${MULLE_SCION_SOURCES}
${MULLE_SCION_FOUNDATION_SOURCES}
${MULLE_SCION_PARSER_SOURCES}
${MULLE_SCION_PRINTER_SOURCES}
${GOOGLE_TOOLBOX_SOURCES}
${HOEDOWN_SOURCES}
)


add_executable( mulle-scion
${MONGOOSE_SOURCES}
${TOOL_SOURCES}
)


add_dependencies( mulle-scion MulleScion)

set( TARGET_ALL_LOAD_LIBRARIES
$<TARGET_FILE:MulleScion>
${OBJC_DEPENDENCY_LIBRARIES}
)

if( FORCE_LOAD)
   set( TMP)
   foreach( library ${TARGET_ALL_LOAD_LIBRARIES})
      list( APPEND TMP "${FORCE_LOAD} ${library}")
   endforeach( library)
   set( TARGET_ALL_LOAD_LIBRARIES ${TMP})
endif()


target_link_libraries( mulle-scion
${BEGIN_ALL_LOAD}
${TARGET_ALL_LOAD_LIBRARIES}
${END_ALL_LOAD}
${ZLIB_LIBRARIES}
${C_DEPENDENCY_LIBRARIES}
${FOUNDATION_LIBRARY}
${OS_SPECIFIC_LIBS}
)


# INSTALL( TARGETS MulleScion DESTINATION "lib")
# INSTALL( FILES ${HEADERS} DESTINATION "include/MulleScion")

INSTALL( TARGETS mulle-scion DESTINATION "bin")
INSTALL( FILES ${SCIONS} ${PLISTS} DESTINATION "share/mulle-scion/dox")


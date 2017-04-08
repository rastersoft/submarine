### CMakeLists automatically created with AutoVala
### Do not edit

set (DATADIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
set (PKGDATADIR "${DATADIR}/rastersubmarine")
set (GETTEXT_PACKAGE "rastersubmarine")
set (RELEASE_NAME "rastersubmarine")
set (CMAKE_C_FLAGS "")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (VERSION "0.1.7")
set (TESTSRCDIR "${CMAKE_SOURCE_DIR}")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/Config.vala.base ${CMAKE_BINARY_DIR}/src/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
set (VERSION "0.1.7")
add_definitions (${DEPS_CFLAGS})
include_directories ( ${CMAKE_BINARY_DIR}/src/lib )
link_libraries ( ${DEPS_LIBRARIES} -lSubmarine )
link_directories ( ${DEPS_LIBRARY_DIRS} ${CMAKE_BINARY_DIR}/src/lib )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.28" MINIMUM)
include (ValaPrecompile)

set (VALA_PACKAGES ${VALA_PACKAGES} gee-0.8)
set (VALA_PACKAGES ${VALA_PACKAGES} gio-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} glib-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gobject-2.0)

set (APP_SOURCES ${APP_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/Config.vala)
set (APP_SOURCES ${APP_SOURCES} report.vala)
set (APP_SOURCES ${APP_SOURCES} submarine.vala)

set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_BINARY_DIR}/src/lib/Submarine.vapi)


if ((${CMAKE_BUILD_TYPE} STREQUAL "Debug") OR (${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo"))
	set(COMPILE_OPTIONS ${COMPILE_OPTIONS} "-g")
endif()

vala_precompile(VALA_C submarine
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
CUSTOM_VAPIS
	${CUSTOM_VAPIS_LIST}
)

add_executable(submarine ${VALA_C})


install(TARGETS
	submarine
RUNTIME DESTINATION
	${CMAKE_INSTALL_BINDIR}
)
if(HAVE_VALADOC)
	valadoc(submarine
		${CMAKE_BINARY_DIR}/valadoc/submarine
		${APP_SOURCES}
	PACKAGES
		${VALA_PACKAGES}
	CUSTOM_VAPIS
		${CUSTOM_VAPIS_LIST}
	)
	install(DIRECTORY
		${CMAKE_BINARY_DIR}/valadoc
	DESTINATION
		${CMAKE_INSTALL_DATAROOTDIR}/doc/rastersubmarine
	)
endif()

install(CODE "MESSAGE (\"
************************************************
* Run 'sudo ldconfig' to complete installation *
************************************************

\") " )
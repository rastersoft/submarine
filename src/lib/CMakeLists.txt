### CMakeLists automatically created with AutoVala
### Do not edit

set (DATADIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
set (PKGDATADIR "${DATADIR}/rastersubmarine")
set (GETTEXT_PACKAGE "rastersubmarine")
set (RELEASE_NAME "rastersubmarine")
set (CMAKE_C_FLAGS "")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (VERSION "1.0.0")
set (TESTSRCDIR "${CMAKE_SOURCE_DIR}")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/lib/Config.vala.base ${CMAKE_BINARY_DIR}/src/lib/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/Submarine.pc ${CMAKE_CURRENT_BINARY_DIR}/Submarine.pc)
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/Submarine.deps ${CMAKE_CURRENT_BINARY_DIR}/Submarine.deps)
set (VERSION "1.0.0")
add_definitions (${DEPS_CFLAGS})
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.28" MINIMUM)
include (ValaPrecompile)

set (VALA_PACKAGES ${VALA_PACKAGES} posix)
set (VALA_PACKAGES ${VALA_PACKAGES} gee-0.8)
set (VALA_PACKAGES ${VALA_PACKAGES} gio-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} glib-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gobject-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} libarchive)
set (VALA_PACKAGES ${VALA_PACKAGES} libsoup-2.4)
set (VALA_PACKAGES ${VALA_PACKAGES} libxml-2.0)

set (APP_SOURCES ${APP_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/Config.vala)
set (APP_SOURCES ${APP_SOURCES} XMLRPC.vala)
set (APP_SOURCES ${APP_SOURCES} bierdopje.vala)
set (APP_SOURCES ${APP_SOURCES} cachedata.vala)
set (APP_SOURCES ${APP_SOURCES} divxsubs.vala)
set (APP_SOURCES ${APP_SOURCES} language_codes.vala)
set (APP_SOURCES ${APP_SOURCES} nameparser.vala)
set (APP_SOURCES ${APP_SOURCES} open_subtitles.vala)
set (APP_SOURCES ${APP_SOURCES} podnapisi.vala)
set (APP_SOURCES ${APP_SOURCES} server.vala)
set (APP_SOURCES ${APP_SOURCES} session.vala)
set (APP_SOURCES ${APP_SOURCES} subdb.vala)
set (APP_SOURCES ${APP_SOURCES} subtitle.vala)
set (APP_SOURCES ${APP_SOURCES} subtituloses.vala)


if ((${CMAKE_BUILD_TYPE} STREQUAL "Debug") OR (${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo"))
	set(COMPILE_OPTIONS ${COMPILE_OPTIONS} "-g")
endif()

set (COMPILE_OPTIONS ${COMPILE_OPTIONS} --library=Submarine --gir Submarine-1.0.gir )

vala_precompile(VALA_C Submarine
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
OPTIONS
	${COMPILE_OPTIONS}
GENERATE_VAPI
	Submarine
GENERATE_HEADER
	Submarine
)

add_library(Submarine SHARED ${VALA_C})

target_link_libraries( Submarine archive )
set_target_properties( Submarine PROPERTIES
VERSION
	1.0.0
SOVERSION
	1 )


install(TARGETS
	Submarine
LIBRARY DESTINATION
	${CMAKE_INSTALL_LIBDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.h
DESTINATION
	${CMAKE_INSTALL_INCLUDEDIR}/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.vapi
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.deps
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine-1.0.gir
DESTINATION
	${CMAKE_INSTALL_DATAROOTDIR}/gir-1.0/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.pc
DESTINATION
	${CMAKE_INSTALL_LIBDIR}/pkgconfig/
)
if(HAVE_VALADOC)
	valadoc(Submarine
		${CMAKE_BINARY_DIR}/valadoc/Submarine
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

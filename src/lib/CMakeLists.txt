### CMakeLists automatically created with AutoVala
### Do not edit

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/submarine")
set (GETTEXT_PACKAGE "submarine")
set (RELEASE_NAME "submarine")
set (CMAKE_C_FLAGS "")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (VERSION "1.0.0")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/lib/Config.vala.cmake ${CMAKE_BINARY_DIR}/src/lib/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
configure_file (${CMAKE_CURRENT_SOURCE_DIR}/Submarine.pc ${CMAKE_CURRENT_BINARY_DIR}/Submarine.pc)
set (VERSION "1.0.0")
add_definitions (${DEPS_CFLAGS})
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.22" MINIMUM)
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

set_target_properties( Submarine PROPERTIES
VERSION
	1.0.0
SOVERSION
	1 )

install(TARGETS
	Submarine
LIBRARY DESTINATION
	lib/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.h
DESTINATION
	include/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.vapi
DESTINATION
	share/vala/vapi/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine-1.0.gir
DESTINATION
	share/gir-1.0/
)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/Submarine.pc
DESTINATION
	lib/pkgconfig/
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
		share/doc/submarine
	)
endif()

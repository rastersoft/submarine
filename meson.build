project('rastersubmarine',['c','vala'])

add_global_arguments('-DGETTEXT_PACKAGE="rastersubmarine"',language: 'c')

gee_0_8_dep = dependency('gee-0.8')
gio_2_0_dep = dependency('gio-2.0')
glib_2_0_dep = dependency('glib-2.0')
gobject_2_0_dep = dependency('gobject-2.0')
libarchive_dep = dependency('libarchive')
libsoup_2_4_dep = dependency('libsoup-2.4')
libxml_2_0_dep = dependency('libxml-2.0')

meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_data.sh'),join_paths(get_option('prefix'),get_option('datadir'),'rastersubmarine'),join_paths(meson.current_source_dir(),'data/local','','*'))

meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_data.sh'),join_paths(get_option('prefix'),get_option('datadir'),'doc'),join_paths(meson.current_source_dir(),'doc','','*'))

cfg_Submarine = configuration_data()
cfg_Submarine.set('DATADIR', join_paths(get_option('prefix'),get_option('datadir')))
cfg_Submarine.set('PKGDATADIR', join_paths(get_option('prefix'),get_option('datadir'),'rastersubmarine'))
cfg_Submarine.set('GETTEXT_PACKAGE', 'rastersubmarine')
cfg_Submarine.set('RELEASE_NAME', 'rastersubmarine')
cfg_Submarine.set('PREFIX', get_option('prefix'))
cfg_Submarine.set('VERSION', '1.0.0')
cfg_Submarine.set('TESTSRCDIR', meson.current_source_dir())

cfgfile_1 = configure_file(input: 'src/lib/Config.vala.base',output: 'Config_1.vala',configuration: cfg_Submarine)

Submarine_deps = [gee_0_8_dep]
Submarine_deps += [gio_2_0_dep]
Submarine_deps += [glib_2_0_dep]
Submarine_deps += [gobject_2_0_dep]
Submarine_deps += [libarchive_dep]
Submarine_deps += [libsoup_2_4_dep]
Submarine_deps += [libxml_2_0_dep]
Submarine_sources = [cfgfile_1]
Submarine_sources += ['src/lib/XMLRPC.vala']
Submarine_sources += ['src/lib/bierdopje.vala']
Submarine_sources += ['src/lib/cachedata.vala']
Submarine_sources += ['src/lib/divxsubs.vala']
Submarine_sources += ['src/lib/language_codes.vala']
Submarine_sources += ['src/lib/nameparser.vala']
Submarine_sources += ['src/lib/open_subtitles.vala']
Submarine_sources += ['src/lib/podnapisi.vala']
Submarine_sources += ['src/lib/server.vala']
Submarine_sources += ['src/lib/session.vala']
Submarine_sources += ['src/lib/subdb.vala']
Submarine_sources += ['src/lib/subtitle.vala']
Submarine_sources += ['src/lib/subtituloses.vala']
Submarine_vala_args = ['--pkg','posix']
Submarine_link_args = ['-larchive']
Submarine_vala_args += ['--gir=Submarine-1.0.gir']


Submarine_library = shared_library('Submarine',Submarine_sources,dependencies: Submarine_deps,vala_args: Submarine_vala_args,link_args: Submarine_link_args,version: '1.0.0',soversion: '1',install: true)

Submarine_requires = []
Submarine_requires += ['gee-0.8']
Submarine_requires += ['gio-2.0']
Submarine_requires += ['glib-2.0']
Submarine_requires += ['gobject-2.0']
Submarine_requires += ['libarchive']
Submarine_requires += ['libsoup-2.4']
Submarine_requires += ['libxml-2.0']
pkg_mod = import('pkgconfig')
pkg_mod.generate(libraries : Submarine_library,
	version : '1.0.0',
	name : 'Submarine',
	filebase : 'Submarine',
	description : 'Submarine',
	requires : Submarine_requires)

install_data(join_paths(meson.current_source_dir(),'src/lib/Submarine.deps'),install_dir: join_paths(get_option('prefix'),'share','vala','vapi'))
meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_library.sh'),'Submarine','Submarine-1.0.gir')

cfg_submarine = configuration_data()
cfg_submarine.set('DATADIR', join_paths(get_option('prefix'),get_option('datadir')))
cfg_submarine.set('PKGDATADIR', join_paths(get_option('prefix'),get_option('datadir'),'rastersubmarine'))
cfg_submarine.set('GETTEXT_PACKAGE', 'rastersubmarine')
cfg_submarine.set('RELEASE_NAME', 'rastersubmarine')
cfg_submarine.set('PREFIX', get_option('prefix'))
cfg_submarine.set('VERSION', '0.1.7')
cfg_submarine.set('TESTSRCDIR', meson.current_source_dir())

cfgfile_2 = configure_file(input: 'src/Config.vala.base',output: 'Config_2.vala',configuration: cfg_submarine)

submarine_deps = [gee_0_8_dep]
submarine_deps += [gio_2_0_dep]
submarine_deps += [glib_2_0_dep]
submarine_deps += [gobject_2_0_dep]
submarine_sources = [cfgfile_2]
submarine_sources += ['src/report.vala']
submarine_sources += ['src/submarine.vala']
submarine_dependencies = [Submarine_library]

executable('submarine',submarine_sources,dependencies: submarine_deps,link_with: submarine_dependencies,install: true)


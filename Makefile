USE_PKGBUILD=1
include /usr/local/share/luggage/luggage.make

PACKAGE_VERSION:=$(shell date +%Y%m%d%H%M%S)
TITLE=osxscriptrunner
REVERSE_DOMAIN=cz.osxadmin.pkg
PAYLOAD=\
	prepare_stage \
	install_files

prepare_stage:
	@sudo mkdir -p "${WORK_D}/Library/Scripts/runner/"
	@sudo mkdir -p "${WORK_D}/Library/LaunchAgents/"
	@sudo mkdir -p "${WORK_D}/Library/LaunchDaemons/"

install_files:
	@sudo ${CP} ./osxscriptrunner.bash "${WORK_D}/Library/Scripts/runner/"
	@sudo chown root:admin "${WORK_D}/Library/Scripts/runner/osxscriptrunner.bash"
	@sudo chmod +x "${WORK_D}/Library/Scripts/runner/osxscriptrunner.bash"
	@sudo ${CP} ./cz.osxadmin.loginrunner.plist "${WORK_D}/Library/LaunchAgents/"
	@sudo chown root:admin "${WORK_D}/Library/LaunchAgents/cz.osxadmin.loginrunner.plist"
	@sudo ${CP} ./cz.osxadmin.startuprunner.plist "${WORK_D}/Library/LaunchDaemons/"
	@sudo chown root:admin "${WORK_D}/Library/LaunchDaemons/cz.osxadmin.startuprunner.plist"
	
	
#
# package OS updates for Mac OS X 10.12.1
#

osVersion = 10.12.4
buildVersion = 16E195
installApp = Install\ macOS\ Sierra.app
update = InstallOSX_${osVersion}_update.tar.gz.gpg

all: ${update}

%.tgz : %.pkg
	rm -rf $<.expanded
	pkgutil --expand $< $<.expanded
	sudo rm -rf ttmp
	mkdir ttmp
	sudo tar -xpjf $<.expanded/$</Payload -C ttmp
	sudo tar -cvzf $@ -C ttmp .

# notes:
# sudo ./createOSXinstallPkg --source Install\ macOS\ Sierra.app
# this command assumes the presents of Resources directory
# Get more info about createOSXinstallPkg from:
#     http://managingosx.wordpress.com/2012/07/25/son-of-installlion-pkg/
#     git clone https://code.google.com/p/munki.installlionpkg/

#${installApp}: ${installApp}.tar
#	tar xvf ${installApp}.tar
#	touch ${installApp}

InstallOSX_${osVersion}.pkg: ${installApp}
	sudo ./createOSXinstallPkg --source ${installApp} --output=$@

${update}: InstallOSX_${osVersion}.pkg install.in
	sed -e s/__packageFileName__/InstallOSX_${osVersion}.pkg/ -e s/__osVersion__/${osVersion}/ -e s/__buildVersion__/${buildVersion}/ < install.in > install
	chmod a+xr install
	tar cvzf $(@:.gpg=) install InstallOSX_${osVersion}.pkg
	rm install
	gpg --default-key 'Helius (20080611) <support@helius.com>' --sign $(@:.gpg=)	
	rm $(@:.gpg=)
	@echo "======== Success ========" $@


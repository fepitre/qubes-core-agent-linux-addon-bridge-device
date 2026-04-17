UNITDIR ?= /usr/lib/systemd/system

all:
	@true

install-common:
	install -d $(DESTDIR)/usr/lib/qubes
	install -m 0755 network/publish-bridge $(DESTDIR)/usr/lib/qubes/
	install -m 0755 network/harden-bridge  $(DESTDIR)/usr/lib/qubes/

install-networkmanager:
	install -d $(DESTDIR)/etc/NetworkManager/dispatcher.d/no-wait.d/
	ln -sf /usr/lib/qubes/publish-bridge \
		$(DESTDIR)/etc/NetworkManager/dispatcher.d/no-wait.d/qubes-bridge

install-systemd:
	install -d $(DESTDIR)$(UNITDIR)
	install -m 0644 systemd/qubes-publish-bridges.service \
		$(DESTDIR)$(UNITDIR)/qubes-publish-bridges.service

install-vm: install-common install-networkmanager install-systemd
install-rh: install-vm
install-deb: install-vm
install: install-vm

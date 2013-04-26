Name:		connman
Version:	1.12
Release:	1.1
License:	GPL-2.0
Summary:	Connection Manager
Url:		http://connman.net/
Group:		System/Daemons
Source:		http://www.kernel.org/pub/linux/network/connman/connman-%{version}.tar.xz
#Source2:        connman-rpmlintrc

BuildRequires:  gcc-c++ libtool autoconf
BuildRequires:  pkgconfig(dbus-1)
BuildRequires:  pkgconfig(glib-2.0)
BuildRequires:  pkgconfig(xtables)
BuildRequires:  pkgconfig(gnutls)
BuildRequires:  readline-devel
#BuildRequires:	gtk-doc		# unusual yet
#BuildRequires:  libiptc-devel
##BuildRequires:  dhcp
BuildRequires:  openvpn
##BuildRequires:  systemd
##BuildRequires:	wpa_supplicant
##Requires:       bluez
##Requires:       dhcp >= 3.0.2
##Requires:       iptables
##Requires:       wpa_supplicant

%if 0%{?suse_version} >= 1210
%{?systemd_requires}
%else
Requires:       systemd
%endif

%description
Connection Manager provides a daemon for managing Internet connections
within embedded devices running the Linux operating system.

%package devel
Summary:	Development files for Connection Manager
Group:	Development/Libraries/C and C++
Requires:       %{name} >= %{version}

%description devel
connman-devel contains development files for use with connman.

##############################
#Plugins
##############################
%package plugin-hh2serial-gps
Summary:        HH2Serial GPS plugin for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description plugin-hh2serial-gps
Provides HH2Serial GPS device support for Connman (Connection Manager).

%package plugin-openconnect
Summary:        OpenConnect plugin for connman (Connection Manager)
Group:          System/Daemons
BuildRequires:  pkgconfig(openconnect)
Requires:       %{name} >= %{version}
Requires:       dbus-1 >= 1.0
Requires:       openconnect

%description plugin-openconnect
Provides OpenConnect support for Connman (Connection Manager).
OpenConnect is an open client for Cisco(TM) AnyConnect(TM) VPN.

%package plugin-vpnc
Summary:        VPNC plugin for connman (Connection Manager)
Group:          System/Daemons
BuildRequires:  vpnc
Requires:       %{name} >= %{version}
##Requires:       vpnc

%description plugin-vpnc
Provides VPNC support for Connman (Connection Manager).

%package plugin-openvpn
Summary:        OpenVPN plugin for connman (Connection Manager)
Group:          System/Daemons
##BuildRequires:  openvpn
Requires:       %{name} >= %{version}
Requires:       openvpn

%description plugin-openvpn
Provides OpenVPN support for Connman (Connection Manager).

%package plugin-pptp
Summary:        PPTP plugin for connman (Connection Manager)
Group:          System/Daemons
##BuildRequires:  vpnc
Requires:       %{name} >= %{version}
##Requires:       vpnc

%description plugin-pptp
Provides PPTP support for Connman (Connection Manager).

%package plugin-tist
Summary:        TIST plugin for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description plugin-tist
Provides TI Shared Transport support for Connman (Connection Manager).

%package plugin-l2tp
Summary:        L2TP plugin for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description plugin-l2tp
Provides L2TP (Layer 2 Tunneling Protocol) support for Connman (Connection Manager).

%package plugin-iospm
Summary:        Intel OSPM plugin for connman (Connection Manager)
Group:          System/Daemons
BuildRequires:  ppp-devel
Requires:       %{name} >= %{version}
Requires:       ppp

%description plugin-iospm
Provides Intel OSPM support for Connman (Connection Manager).

%package test
Summary:        Test and example scripts for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description test
Provides test and example scripts for Connman (Connection Manager).

%package nmcompat
Summary:        NetworkManager compatibility for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description nmcompat
Provides NetworkManager compatibility for Connman (Connection Manager).

%package plugin-polkit
Summary:        PolicyKit plugin for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}
Requires:       dbus-1 >= 1.0
Requires:       polkit

%description plugin-polkit
Provides PolicyKit support for Connman (Connection Manager).

%package client
Summary:        Client script for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description client
Provides client interface for Connman (Connection Manager).

%package session_policy
Summary:        Session policy for connman (Connection Manager)
Group:          System/Daemons
Requires:       %{name} >= %{version}

%description session_policy
Provides client interface for Connman (Connection Manager).


%prep
%setup -q


%build
# Using i586 repository, so explicitly forward it to CC.
# Necesary, because i386 will fail due to:
# undefined reference to `__sync_add_and_fetch_4'
# Restrict to Fedora right for now.
%if 0%{?fedora}
%ifarch i386 i486 i586
CFLAGS='-O2 -g -march=i586 -mtune=i686'
export CFLAGS
CXXFLAGS='-O2 -g -march=i586 -mtune=i686'
export CXXFLAGS
FFLAGS='-O2 -g -march=i586 -mtune=i686'
export FFLAGS
%endif
%endif
autoreconf
%configure \
        --with-systemdunitdir=%{_unitdir} \
	--disable-static \
	--enable-shared \
	--disable-debug \
	--disable-gtk-doc \
	--enable-pie \
	--enable-threads \
	--enable-hh2serial-gps \
	--enable-openconnect \
	--enable-openvpn \
	--enable-vpnc \
	--enable-l2tp \
	--enable-pptp \
	--disable-iwmx \
	--enable-iospm \
	--enable-tist \
	--enable-session-policy-local \
	--enable-test \
	--enable-nmcompat \
	--enable-polkit \
	--enable-loopback \
	--enable-ethernet \
	--enable-wifi \
	--enable-bluetooth \
	--enable-ofono \
	--enable-dundee \
	--enable-pacrunner \
	--enable-wispr \
	--enable-tools \
	--enable-client \
	--enable-datafiles
#	--enable-selinux
make %{?_smp_mflags}


%install
make install DESTDIR="%buildroot"
rm %{buildroot}%{_libdir}/%{name}/plugins/*.la
rm %{buildroot}%{_libdir}/%{name}/plugins-vpn/*.la
rm %{buildroot}%{_libdir}/%{name}/scripts/*.la
install -Dp -m 0755 client/connmanctl %{buildroot}%{_bindir}/connmanctl


%clean
rm -rf %{buildroot}


%if 0%{?suse_version} >= 1210
%pre
%service_add_pre connman.service
%endif


%post
/sbin/ldconfig
%if 0%{?suse_version} >= 1210
%service_add_post connman.service
%endif


%if 0%{?suse_version} >= 1210
%preun
%service_del_preun connman.service
%endif


%postun
/sbin/ldconfig
%if 0%{?suse_version} >= 1210
%service_del_postun connman.service
%endif

%post devel -p /sbin/ldconfig
%postun devel -p /sbin/ldconfig

%post plugin-hh2serial-gps -p /sbin/ldconfig
%postun plugin-hh2serial-gps -p /sbin/ldconfig

%post plugin-openconnect -p /sbin/ldconfig
%postun plugin-openconnect -p /sbin/ldconfig

%post plugin-vpnc -p /sbin/ldconfig
%postun plugin-vpnc -p /sbin/ldconfig

%post plugin-iospm -p /sbin/ldconfig
%postun plugin-iospm -p /sbin/ldconfig

%post plugin-l2tp -p /sbin/ldconfig
%postun plugin-l2tp -p /sbin/ldconfig

%post plugin-openvpn -p /sbin/ldconfig
%postun plugin-openvpn -p /sbin/ldconfig

%post plugin-pptp -p /sbin/ldconfig
%postun plugin-pptp -p /sbin/ldconfig

%post plugin-tist -p /sbin/ldconfig
%postun plugin-tist -p /sbin/ldconfig

%post session_policy -p /sbin/ldconfig
%postun session_policy -p /sbin/ldconfig

# enable service automaticly 
# Currently disabled as per http://en.opensuse.org/openSUSE:Systemd_packaging_guidelines
# enable connman.service

%files
%defattr(-,root,root,-)
%doc AUTHORS COPYING ChangeLog INSTALL NEWS README TODO
%{_sbindir}/connmand
%{_sbindir}/connman-vpnd
%{_bindir}/connmanctl
%dir %{_libdir}/%{name}
%dir %{_libdir}/%{name}/scripts
%dir %{_libdir}/%{name}/plugins
%dir %{_libdir}/%{name}/plugins-vpn
%config %{_sysconfdir}/dbus-1/system.d/connman.conf
%config %{_sysconfdir}/dbus-1/system.d/connman-vpn-dbus.conf
%{_unitdir}/connman.service
%{_unitdir}/connman-vpn.service
%{_datadir}/dbus-1/system-services/net.connman.vpn.service

%files devel
%defattr(-,root,root,-)
%doc doc/*
%dir %{_includedir}/%{name}
%{_includedir}/%{name}/*.h
%{_libdir}/pkgconfig/*.pc

%files plugin-hh2serial-gps
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins/hh2serial-gps.so

%files plugin-openconnect
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins-vpn/openconnect.so
%{_libdir}/%{name}/scripts/openconnect-script

%files plugin-vpnc
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins-vpn/vpnc.so

%files plugin-iospm
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins/iospm.so

%files plugin-l2tp
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins-vpn/l2tp.so
%{_libdir}/%{name}/scripts/libppp-plugin.so*

%files plugin-openvpn
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins-vpn/openvpn.so
%{_libdir}/%{name}/scripts/openvpn-script

%files plugin-pptp
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins-vpn/pptp.so

%files plugin-tist
%defattr(-,root,root,-)
%{_libdir}/%{name}/plugins/tist.so

%files test
%defattr(-,root,root,-)
%{_libdir}/%{name}/test

%files nmcompat
%defattr(-,root,root,-)
%config %{_sysconfdir}/dbus-1/system.d/connman-nmcompat.conf

%files plugin-polkit
%defattr(-,root,root,-)
%{_datadir}/polkit-1/actions/net.connman.policy
%{_datadir}/polkit-1/actions/net.connman.vpn.policy

%files session_policy
%defattr(-,root,root,-)
%{_libdir}/connman/plugins/session_policy_local.so

%changelog
* Sat Jan 19 2013 ti.eugene@gmail.com
- 1.10
* Sun Nov 25 2012 simon@simotek.net
- Meet Packaging Guidelines for systemd packages in openSUSE
- Remove some tabs from the spec file
* Fri Nov 23 2012 sleep_walker@suse.cz
- fix dependency name
* Fri Nov 23 2012 sleep_walker@suse.cz
- remove *_version conditions as it is handled in meta prjconf
* Fri Nov 23 2012 sleep_walker@suse.cz
- update to 1.9
- reorder configure to follow ./configure --help order
- add wpa_supplicant to Buildrequires
- enable session_policy plugin
* Tue Sep 25 2012 sleep_walker@suse.cz
- update dependencies to work on SUSE distros II.
* Tue Sep 25 2012 sleep_walker@suse.cz
- update dependencies to work on SUSE distros
* Sun Sep 23 2012 sleep_walker@suse.cz
- move files across packages, move requires and buildrequires
* Sat Sep 22 2012 sleep_walker@suse.cz
- fix deps for oS12.2+
* Sat Sep 22 2012 sleep_walker@suse.cz
- update to 1.7, add more subpackages

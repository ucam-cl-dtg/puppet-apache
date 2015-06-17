# debian.pp - debian specific defines for apache
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# 
# After http://reductivelabs.com/trac/puppet/wiki/Recipes/DebianApache2Recipe
# where Tim Stoop <tim.stoop@gmail.com> graciously posted this recipe
# modifications for multiple distros with support from <admin@immerda.ch>

class apache::debian inherits apache::base { 
	debug("Configuring apache for Debian")
	#TODO: refactor all debian specifics from ::base here
	Package["apache"] { name => apache2 }
	Service["apache"] {
		name => "apache2",
		pattern => "/usr/sbin/apache2",
		hasrestart => true,
	}

	Exec["reload-apache"] { command => "/bin/systemctl reload apache2", }
	Exec["force-reload-apache"] { command => "/bin/systemctl force-reload apache2", }

	# remove the default site in debian
	file { ["/etc/apache2/sites-enabled/000-default",
                "/etc/apache2/sites-enabled/000-default.conf"]: ensure => absent }

	# activate inclusion of unified directory structure
	file_line { 
		"include_mods_load":
			line => "IncludeOptional mods-enabled/*.load",
			notify => Exec["reload-apache"],
			ensure => present, path => "/etc/apache2/apache2.conf";
		"include_mods_conf":
			line => "IncludeOptional mods-enabled/*.conf",
			notify => Exec["reload-apache"],
			require => File_line["include_mods_load"],
			ensure => present, path => "/etc/apache2/apache2.conf";
		"include_conf":
			line => "Include conf.d/",
			notify => Exec["reload-apache"],
			require => File_line["include_mods_conf"],
			ensure => present, path => "/etc/apache2/apache2.conf";
		"include_sites":
			line => "IncludeOptional sites-enabled/*.conf",
			notify => Exec["reload-apache"],
			require => File_line["include_conf"],
			ensure => present, path => "/etc/apache2/apache2.conf";
	}
}

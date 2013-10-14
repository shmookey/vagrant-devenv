
$base_packages = [
	"vim",
	"screen",
	"sudo",
	"git",
	"netcat",
]

Exec {
    path => [
        "/bin",
        "/usr/bin",
        "/usr/local/bin",
    ],
}

file { "/etc/apt/sources.list":
    ensure => link,
    target => "/vagrant/etc/sources.list",
}->exec { "apt-get update": }

Package { require => Exec["apt-get update"] }

package { $base_packages: ensure => installed }


file { "/home/vagrant/.bashrc":
    ensure => link,
    target => "/vagrant/etc/bashrc",
    owner => "vagrant",
}
file { "/home/vagrant/.vimrc":
    ensure => link,
    target => "/vagrant/etc/vimrc",
    owner => "vagrant",
}

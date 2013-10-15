
#
# Requires username to be set externally.
#
# Must be run twice to set user password because doing so requires the
# presence of the ruby-shadow gem before the manifest is loaded, but since
# this manifest installs it, the password will fail to be set on the first
# run.
#

include user_config

Exec {
    path => [
        "/bin",
        "/usr/bin",
        "/usr/local/bin",
    ],
}

class preinit {
    File { owner => "root", require => undef }
    Exec { user => "root", refreshonly => true, require => undef }
    file { "/etc/apt/sources.list":
        ensure => link,
        target => "/vagrant/etc/sources.list",
    }
    exec { "apt-get update": subscribe => File["/etc/apt/sources.list"] }

    file { "/etc/hostname":
        ensure => present,
        content => $hostname,
    }
    exec { "hostname $hostname": subscribe => File["/etc/hostname"] }

    file { "/etc/motd":
        ensure => link,
        target => "/vagrant/etc/motd",
    }
}

class packages {
    require preinit
    $base_packages = [
        "vim",
        "screen",
        "sudo",
        "git",
        "netcat",
        "ruby-shadow",
    ]

    package { $base_packages: ensure => installed }
}

class user_config {
    require packages
    
    $HOME = "/home/${username}"
    $home_structure = [
        "$HOME/bin",
        "$HOME/src",
        "$HOME/etc",
        "$HOME/downloads",
    ]

    File { owner => $username, require => User[$username] }
    Exec { environment => ["HOME=${HOME}"], require => User[$username] }

    user { $username: 
        ensure => present,
        home => $HOME,
        managehome => true,
        shell => "/bin/bash",
        groups => ["sudo"],
        # Password is 'vagrant'
        password => '$6$juvF8QM9$kldJpLH2FULZ.fJmDl6NgR8wYtNnn9aIEfOMpNDNzGfvgsgNCEsryVifNyeGTQnqqX3XZt1YSU1tfn/mUtf.z0',
    }

    file { $home_structure: ensure => directory, require => User[$username] }

    file { "$HOME/.ssh": ensure => directory }
    file { "$HOME/.ssh/authorized_keys":
        ensure => present,
        source => "/vagrant/ssh/authorized_keys",
        mode => "600",
    }

    #
    # Shell configs
    #
    
    file { "$HOME/.bashrc":
        ensure => link,
        target => "/vagrant/etc/bashrc",
        owner => "vagrant",
    }
    file { "$HOME/.vimrc":
        ensure => link,
        target => "/vagrant/etc/vimrc",
        owner => "vagrant",
    }
    
    #
    # Git config
    #
    
    $git_author_options = [
        "git config --global user.name 'Luke Williams'",
        "git config --global user.email 'shmookey@shmookey.net'",
    ]
    exec { $git_author_options:
        creates => "$HOME/.gitconfig"
    }
}


include packages
include user_config


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

class packages {
    $base_packages = [
        "vim",
        "screen",
        "sudo",
        "git",
        "netcat",
    ]

    Package { require => Exec["apt-get update"] }
    package { $base_packages: ensure => installed }
}

class user_config {
    
    $user_name = "vagrant"
    $HOME = "/home/${user_name}"

    File { owner => $user_name }
    Exec { environment => ["HOME=${HOME}"] }

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
    
    $author_options = [
        "git config --global user.name 'Luke Williams'",
        "git config --global user.email 'shmookey@shmookey.net'",
    ]
    
    exec { $author_options:
        require => Package["git"],
    }

}

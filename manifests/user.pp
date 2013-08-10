#------------------------------------------------------------------------------
# Define: users::user
#
#    This define is part of the users module.
#
#    Marc Villacorta <marc.villacorta@gmail.com>
#    2011-08-24
#
#------------------------------------------------------------------------------
define users::user (

    $ensure = present,
    $linux  = undef,
    $git    = undef,
    $samba  = undef,

) {

    #----------------------
    # Validate parameters:
    #----------------------

    validate_re($ensure, '^present$|^absent$')

    #-------------
    # Linux user:
    #-------------

    if $linux {

        user { $title:
            ensure     => $ensure,
            uid        => $linux['uid'],
            gid        => $linux['gid'],
            groups     => $linux['groups'],
            comment    => $linux['comment'],
            home       => $linux['home'],
            shell      => $linux['shell'],
            managehome => $linux['home'],
            password   => mkpasswd($linux['pass'], $title),
            require    => Group[$title],
        }

        group { $title:
            ensure => $ensure,
            gid    => $linux['gid'],
        }

        if $linux['keys'] {
            $keys = concat_titles($linux['keys'], append, "/${title}")
            create_resources(ssh::key, $keys)
        }

        if $linux['profiles'] { each($linux['profiles']) |$i| {

            if $i == $title {

                file { "${linux['home']}/.bash_profile":
                    ensure  => $ensure,
                    content => template("${module_name}/bash_profile-${title}.erb"),
                    owner   => $title,
                    group   => $title,
                    mode    => '0644',
                }

                file { "${linux['home']}/.bashrc":
                    ensure  => $ensure,
                    content => template("${module_name}/bashrc-${title}.erb"),
                    owner   => $title,
                    group   => $title,
                    mode    => '0644',
                }
            }

            else {

                file { "${linux['home']}/.bash_${i}":
                    ensure  => $ensure,
                    content => template("${module_name}/bash-${i}.erb"),
                    owner   => $title,
                    group   => $title,
                    mode    => '0644',
                }
            }
        }}
    }

    #-------------
    # Samba user:
    #-------------

    if $linux and $samba {
        samba::user { $title:
            pass    => $samba['password'],
            require => User[$title],
        }
    }

    #-----------
    # Git user:
    #-----------

    if $linux and $git {
        git::user { $title:
            ensure   => $ensure,
            home     => $git['home'],
            fullname => $git['fullname'],
            email    => $git['email'],
            editor   => $git['editor'],
            difftool => $git['difftool'],
            require  => User[$title],
        }
    }
}

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

        if $linux['home'] { $managehome = true }
        if $linux['pass'] == '!!' { $hash = '!!' }
        else { $hash = mkpasswd($linux['pass'], $title) }

        user { $title:
            ensure     => $ensure,
            uid        => $linux['uid'],
            gid        => $linux['gid'],
            groups     => $linux['groups'],
            comment    => $linux['comment'],
            home       => $linux['home'],
            shell      => $linux['shell'],
            managehome => $managehome,
            password   => $hash,
            require    => Group[$title],
        }

        group { $title:
            ensure => $ensure,
            gid    => $linux['gid'],
        }

        if $linux['key'] {
            ssh::key { $title:
                key   => $linux['key'],
                users => $linux['grant'],
            }
        }
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

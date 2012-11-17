#------------------------------------------------------------------------------
# Define: user::real
#
#    This define is part of the user module.
#
#    Marc Villacorta <marc.villacorta@gmail.com>
#    2011-08-24
#
#------------------------------------------------------------------------------
define user::real (

    $linux  = undef,
    $git    = undef,
    $samba  = undef,

) {

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
            ensure  => $ensure,
            gid     => $linux['gid'],
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

    if $samba {
        samba::user { $title:
            pass => $samba['password'],
        }
    }

    #-----------
    # Git user:
    #-----------

    if $git {
        git::user { $title:
            ensure   => $ensure,
            home     => $git['home'],
            fullname => $git['fullname'],
            email    => $git['email'],
            editor   => $git['editor'],
            difftool => $git['difftool'],
        }
    }
}

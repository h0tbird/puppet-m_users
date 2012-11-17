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

    $ensure = present,
    $uid    = undef,
    $gid    = undef,
    $name   = undef,
    $groups = undef,
    $pass   = undef,
    $home   = undef,
    $shell  = undef,
    $git    = undef,
    $samba  = undef,
    $grant  = undef,
    $key    = undef,

) {

    if $home { $managehome = true }
    if $pass == '!!' { $hash = $pass }
    else { $hash = mkpasswd($pass, $title) }

    user { $title:
        ensure     => $ensure,
        uid        => $uid,
        gid        => $gid,
        groups     => $groups,
        comment    => $name,
        password   => $hash,
        managehome => $managehome,
        home       => $home,
        shell      => $shell,
        require    => Group[$title],
    }
 
    group { $title:
        ensure  => $ensure,
        gid     => $gid,
    }

    # Linux user:
    if $key { ssh::key { $title: users => $grant } }

    # Samba user:
    if $samba { samba::user { $title: pass => $samba['password'] } }

    # Git user:
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

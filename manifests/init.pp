class users {

  hiera('SystemUsers').each |$user, $data| {

    if $data['linux']['home'] { $managehome = true }

    user { $user:
      ensure     => present,
      uid        => $data['linux']['uid'],
      gid        => $data['linux']['gid'],
      groups     => $data['linux']['groups'],
      comment    => $data['linux']['comment'],
      home       => $data['linux']['home'],
      shell      => $data['linux']['shell'],
      managehome => $managehome,
      password   => mkpasswd($data['linux']['pass'], $user),
      require    => Group[$user],
    }

    group { $user:
      ensure => present,
      gid    => $data['linux']['gid'],
    }

    if $data['linux']['keys'] {
      $keys = concat_titles($data['linux']['keys'], append, "/${user}")
      create_resources(ssh::key, $keys)
    }

    $data['linux']['profiles'].each |$profile| {

      if $profile == $user {

        file {

          "${data['linux']['home']}/.bash_profile":
            ensure  => present,
            content => template("${module_name}/bash_profile-${user}.erb"),
            owner   => $user,
            group   => $user,
            mode    => '0644';

          "${data['linux']['home']}/.bashrc":
            ensure  => present,
            content => template("${module_name}/bashrc-${user}.erb"),
            owner   => $user,
            group   => $user,
            mode    => '0644';
        }

      } else {

        file { "${data['linux']['home']}/.bash_${profile}":
          ensure  => present,
          content => template("${module_name}/bash-${profile}.erb"),
          owner   => $user,
          group   => $user,
          mode    => '0644',
        }
      }
    }
  }
}

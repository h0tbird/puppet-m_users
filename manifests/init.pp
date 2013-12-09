class users ( $users = undef ) {

    if $users {
        create_resources(users::user, $users)
    }
}

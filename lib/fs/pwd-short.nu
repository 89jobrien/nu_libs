# Print working directory but abbreviates the home dir as ~
export def pwd-short [] {
  $env.PWD | str replace $nu.home-dir '~'
}

# Print working directory but abbreviates the home dir as ~
export def main [] {
  $env.PWD | str replace $nu.home-dir '~'
}

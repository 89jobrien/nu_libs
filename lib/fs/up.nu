use std repeat;

# Go up a number of directories
export def --env main [
    limit = 1: int # The number of directories to go up (default is 1)
  ] {
    cd ("." | repeat ($limit + 1) | str join)
}

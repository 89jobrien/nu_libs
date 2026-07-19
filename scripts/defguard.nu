#!/usr/bin/env nu
# Manage a local defguard docker-compose 2.0 test stack.
# Usage:
#   nu scripts/defguard.nu up [dir]      # download setup.sh and run it in dir (default: defguard-test)
#   nu scripts/defguard.nu down [dir]    # docker compose down -v in dir
#   nu scripts/defguard.nu status [dir]  # docker compose ps in dir
#   nu scripts/defguard.nu clean [dir]   # down -v, then remove dir

def dg-dir [dir: string] {
    if ($dir | path exists) {
        $dir
    } else {
        mkdir $dir
        $dir
    }
}

export def "main up" [dir: string = "defguard-test"] {
    let target = (dg-dir $dir)
    cd $target
    bash -c "bash <(curl -sSL https://raw.githubusercontent.com/defguard/deployment/main/docker-compose2.0/setup.sh)"
}

export def "main down" [dir: string = "defguard-test"] {
    cd $dir
    docker compose down -v
}

export def "main status" [dir: string = "defguard-test"] {
    cd $dir
    docker compose ps
}

export def "main clean" [dir: string = "defguard-test"] {
    if ($dir | path exists) {
        cd $dir
        docker compose down -v
        cd ..
        rm -rf $dir
    } else {
        print $"($dir) does not exist"
    }
}

def main [] {
    print "Usage: defguard.nu <up|down|status|clean> [dir]"
}

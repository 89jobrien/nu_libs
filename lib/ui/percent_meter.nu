# Print a fake 0-100% progress meter over ~5s (demo/placeholder, not tied to real work).
export def loading [] {
    print -n $"Loading (char newline)"
    0..100 | each { |tick|
        sleep 50ms
        # I believe '1000D' means move the cursor to the left 1000 columns
        print -n $"(ansi -e '1000D')($tick)%"
    }
    #show_cursor
}

# Show the terminal cursor via ANSI escape.
export def show_cursor [] {
    print $"(ansi -e '?25h')"
}

# Hide the terminal cursor via ANSI escape.
export def hide_cursor [] {
    print $"(ansi -e '?25l')"
}

# Demo: hide the cursor, run the fake loading meter, show the cursor again.
export def demo_percent_meter [] {
    hide_cursor
    loading
    show_cursor
}
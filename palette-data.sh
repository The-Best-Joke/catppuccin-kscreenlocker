# Catppuccin palette values, one section per flavor.
# Source: https://github.com/catppuccin/catppuccin (official style guide).
# Sourced by install.sh; do not run directly.

FLAVORS=(latte frappe macchiato mocha)
ACCENTS=(rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender)

declare -A LATTE=(
    [base]="#eff1f5" [mantle]="#e6e9ef" [crust]="#dce0e8"
    [surface0]="#ccd0da" [surface1]="#bcc0cc" [overlay0]="#9ca0b0"
    [subtext0]="#6c6f85" [text]="#4c4f69"
    [rosewater]="#dc8a78" [flamingo]="#dd7878" [pink]="#ea76cb"
    [mauve]="#8839ef"    [red]="#d20f39"      [maroon]="#e64553"
    [peach]="#fe640b"    [yellow]="#df8e1d"   [green]="#40a02b"
    [teal]="#179299"     [sky]="#04a5e5"      [sapphire]="#209fb5"
    [blue]="#1e66f5"     [lavender]="#7287fd"
)

declare -A FRAPPE=(
    [base]="#303446" [mantle]="#292c3c" [crust]="#232634"
    [surface0]="#414559" [surface1]="#51576d" [overlay0]="#737994"
    [subtext0]="#a5adce" [text]="#c6d0f5"
    [rosewater]="#f2d5cf" [flamingo]="#eebebe" [pink]="#f4b8e4"
    [mauve]="#ca9ee6"    [red]="#e78284"      [maroon]="#ea999c"
    [peach]="#ef9f76"    [yellow]="#e5c890"   [green]="#a6d189"
    [teal]="#81c8be"     [sky]="#99d1db"      [sapphire]="#85c1dc"
    [blue]="#8caaee"     [lavender]="#babbf1"
)

declare -A MACCHIATO=(
    [base]="#24273a" [mantle]="#1e2030" [crust]="#181926"
    [surface0]="#363a4f" [surface1]="#494d64" [overlay0]="#6e738d"
    [subtext0]="#a5adcb" [text]="#cad3f5"
    [rosewater]="#f4dbd6" [flamingo]="#f0c6c6" [pink]="#f5bde6"
    [mauve]="#c6a0f6"    [red]="#ed8796"      [maroon]="#ee99a0"
    [peach]="#f5a97f"    [yellow]="#eed49f"   [green]="#a6da95"
    [teal]="#8bd5ca"     [sky]="#91d7e3"      [sapphire]="#7dc4e4"
    [blue]="#8aadf4"     [lavender]="#b7bdf8"
)

declare -A MOCHA=(
    [base]="#1e1e2e" [mantle]="#181825" [crust]="#11111b"
    [surface0]="#313244" [surface1]="#45475a" [overlay0]="#6c7086"
    [subtext0]="#a6adc8" [text]="#cdd6f4"
    [rosewater]="#f5e0dc" [flamingo]="#f2cdcd" [pink]="#f5c2e7"
    [mauve]="#cba6f7"    [red]="#f38ba8"      [maroon]="#eba0ac"
    [peach]="#fab387"    [yellow]="#f9e2af"   [green]="#a6e3a1"
    [teal]="#94e2d5"     [sky]="#89dceb"      [sapphire]="#74c7ec"
    [blue]="#89b4fa"     [lavender]="#b4befe"
)

# Return the hex value for $flavor.$key. Used by install.sh.
palette_get() {
    local flavor="$1" key="$2"
    local upper
    upper="$(printf '%s' "$flavor" | tr '[:lower:]' '[:upper:]')"
    local -n table="$upper"
    printf '%s' "${table[$key]}"
}

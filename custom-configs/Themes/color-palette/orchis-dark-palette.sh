# Orchis-Dark global palette
# Source of truth. Edit this file, then run custom-configs/Themes/builders/theme-builder.
#
# Every color below is consumed indirectly by the theme builders via indirect
# ${!var} expansion in theme-build-lib, so ShellCheck cannot see the usage here.
# shellcheck disable=SC2034

# Core surfaces from Orchis-Dark
BG="#212121"
BG_ALT="#242424"
SURFACE="#2C2C2C"
SURFACE_2="#333333"
SURFACE_3="#3C3C3C"

# Text: slightly softer than GTK pure white for WM/panel use
FG="#E6E6E6"
FG_STRONG="#FFFFFF"
FG_DIM="#BDBDBD"
FG_MUTED="#8A8A8A"
FG_DISABLED="#666666"

# Lines / borders
BORDER="#454545"
BORDER_SOFT="#3A3A3A"
SHADOW="#000000"

# Orchis-Dark main accent
ACCENT="#3281EA"
ACCENT_HOVER="#478EEC"
ACCENT_ACTIVE="#5B9AEE"
ACCENT_DIM="#2C5DA0"

# Semantic colors
SUCCESS="#81C995"
WARNING="#FBC02D"
ERROR="#F44336"
URGENT="$ERROR"

# Terminal / classic palette
BLACK="#212121"
BLACK_BRIGHT="#5E5C64"
RED="#ED333B"
RED_BRIGHT="#F66151"
GREEN="#33D17A"
GREEN_BRIGHT="#8FF0A4"
YELLOW="#F5C211"
YELLOW_BRIGHT="#F9F06B"
ORANGE="#FF7800"
BLUE="$ACCENT"
BLUE_BRIGHT="#62A0EA"
MAGENTA="#9141AC"
MAGENTA_BRIGHT="#DC8ADD"
CYAN="#4FC3F7"
CYAN_BRIGHT="#99C1F1"
WHITE="#E6E6E6"
WHITE_BRIGHT="#FFFFFF"

LIME="#73D216"

# Generic compatibility aliases
PRIMARY="$ACCENT"
SECONDARY="$LIME"
ALERT="$ERROR"

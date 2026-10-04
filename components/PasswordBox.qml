import QtQuick 2.15
import SddmComponents 2.0 as Sddm

// Local override to ensure the warning icon is resolved from the theme
Sddm.PasswordBox {
    // Prefer the theme-local resource so the system module doesn't log a missing image
    // Resolve relative to this components/ directory
    image: Qt.resolvedUrl("resources/warning_red.png")
}

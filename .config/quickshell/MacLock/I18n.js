.pragma library

// English only (akiidjk fork): the lock screen has no translations any more.
// tr() stays so the existing I18n.tr("…") calls keep working; it returns the text unchanged.

function tr(text) { return text; }

// Day and month names are always English.
function locale() { return Qt.locale("en_US"); }

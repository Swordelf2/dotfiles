// Config docs:
//
//   https://glide-browser.app/config
//
// API reference:
//
//   https://glide-browser.app/api
//
// Default config files can be found here:
//
//   https://github.com/glide-browser/glide/tree/main/src/glide/browser/base/content/plugins
//
// Most default keymappings are defined here:
//
//   https://github.com/glide-browser/glide/blob/main/src/glide/browser/base/content/plugins/keymaps.mts
//
// Try typing `glide.` and see what you can do!

glide.prefs.set("toolkit.scrollbox.verticalScrollDistance", 12);

// Dark website appearance
glide.prefs.set("layout.css.prefers-color-scheme.content-override", 0);

glide.o.hint_size = "18px"

glide.keymaps.set("normal", "H", "tab_prev");
glide.keymaps.set("normal", "L", "tab_next");
glide.keymaps.set("normal", "<C-o>", "back");
glide.keymaps.set("normal", "<C-i>", "forward");
glide.keymaps.del("normal", "f");
glide.keymaps.set("normal", "s", "hint");

glide.keymaps.set("insert", "<C-n>", "keys <Down>");
glide.keymaps.set("command", "<C-n>", "keys <Down>");
glide.keymaps.set("insert", "<C-p>", "keys <Up>");
glide.keymaps.set("command", "<C-p>", "keys <Up>");

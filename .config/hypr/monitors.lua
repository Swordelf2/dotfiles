-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
	output = "DP-2",
	mode = "1920x1080@60Hz",
	position = "0x0",
	scale = "1.0",
})

hl.monitor({
	output = "DP-1",
	mode = "2560x1440@143.97Hz",
	position = "1920x0",
	scale = "1.3333333",
})

-- Nvidia-related env vars.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

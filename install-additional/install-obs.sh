paru -S obs-studio
paru -S obs-v4l2sink
paru -S v4l2loopback-dkms
paru -S wf-recorder
paru -S wl-screenrec-git
paru -S wlrobs-hg
sudo modprobe v4l2loopback exclusive_caps=1 video_nr=10 card_label="OBS Video Source"

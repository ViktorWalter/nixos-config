#!/bin/bash
sudo cat /sys/kernel/debug/dri/0/amdgpu_pm_info | grep 'GPU Load' | cut -f 3 -d" "

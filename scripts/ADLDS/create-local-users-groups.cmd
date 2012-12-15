net localgroup rootgrp /add /comment:"Group for GID:0"

net user root /add /comment:"User for UID:0 GID:0"
net localgroup rootgrp root /add


net localgroup rootgrp root /add


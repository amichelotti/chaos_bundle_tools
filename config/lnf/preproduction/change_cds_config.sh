pscp -h preproduction.list chaos_cds.cfg /usr/local/chaos/chaos-distrib/etc/
pssh -h cdslist.list systemctl restart chaos-cds

# Esimerkkitapaus siitä, mitä käy jos antaa vahingossa `puppet agent --test` komennon ilman sudoa

Yritin yhdistää Puppetmasteria ja slave konetta, mutta törmäsin ongelmiin SSL sertifikaattien kanssa. Sain sertifikaattipyynnön läpi masterille, ja hyväksyin sen, mutta tämän jälkeen en saanut slave konetta hakemaan moduuleita masterilta. 

Yritys Puppetmaster 
```
Loin aluksi seuraavanlaiset hosts tiedostot masterille ja slaville:

127.0.0.1       localhost
127.0.1.1       slave1
192.168.1.44    master1.zyxel.setup master1 puppetmaster puppet
192.168.1.45    slave1.zyxel.setup slave1 puppetclient

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

Kokeilin .zyxel.setup päätettä .localin sijaan siksi koska huomasin että sertifikaatit olivat nimeytyneet tällaisilla päätteillä.

Käynnistin sitten avahi daemonin uudelleen "sudo service avahi daemon restart"

Kokeilin pingata ja zyxel.setup päätteet vastasivat pingiin kuin myös muut listaamani nimet.

Sitten asensin puppetmasterin "sudo apt-get install puppetmaster"

sitten 

master1$ sudo service puppetmaster stop
master1$ sudo rm -r /var/lib/puppet/ssl


master1$ sudoedit /etc/puppet/puppet.conf

[master]
dns_alt_names = puppet, master1.local, master1.zyxel.setup

Lisäsin kohdan certname=master1 joka voisi selvittää ongelman mikä minulla oli aiemmin. https://shapeshed.com/connecting-clients-to-a-puppet-master/
Certificate is automatically generated when you start PuppetMaster
```

Annoin komennon `sudo puppet cert list --all` ja ruutu näytti `signed cert for ca`


`master$ sudo service puppetmaster start`


Asensin puppetin slaville. sudo apt-get install puppet
```
Add master DNS name under [agent] heading. Puppet will connect to server.

[agent]
server = master1.zyxel.setup
```

Sitten
```
master1$ sudo puppet cert --list
master1$ sudo puppet cert --sign slave1.zyxel.setup
```

Onnistuin hyväksymään slave koneen certin


`master$ sudo service puppetmaster start`


Käynnistin orjan puppetin uudelleen, ja enabloin agentin komennolla sudo puppet enable
```
puppet agent --test --debug

slave1@slave1:/etc/puppet$ sudo puppet agent --enable
slave1@slave1:/etc/puppet$ sudo service puppet restart
slave1@slave1:/etc/puppet$ sudo puppet agent --test --verbose --debug --noop
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Using settings: adding file resource 'confdir': 'File[/etc/puppet]{:path=>"/etc/puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Puppet::Type::User::ProviderUser_role_add: file roleadd does not exist
Debug: Puppet::Type::User::ProviderPw: file pw does not exist
Debug: Failed to load library 'ldap' for feature 'ldap'
Debug: Puppet::Type::User::ProviderLdap: feature ldap is missing
Debug: Puppet::Type::User::ProviderDirectoryservice: file /usr/bin/dsimport does not exist
Debug: /User[puppet]: Provider useradd does not support features libuser; not managing attribute forcelocal
Debug: Puppet::Type::Group::ProviderPw: file pw does not exist
Debug: Failed to load library 'ldap' for feature 'ldap'
Debug: Puppet::Type::Group::ProviderLdap: feature ldap is missing
Debug: Puppet::Type::Group::ProviderDirectoryservice: file /usr/bin/dscl does not exist
Debug: /Group[puppet]: Provider groupadd does not support features libuser; not managing attribute forcelocal
Debug: Using settings: adding file resource 'vardir': 'File[/var/lib/puppet]{:path=>"/var/lib/puppet", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/var/log/puppet]{:path=>"/var/log/puppet", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/var/lib/puppet/state]{:path=>"/var/lib/puppet/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/run/puppet]{:path=>"/run/puppet", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/var/lib/puppet/lib]{:path=>"/var/lib/puppet/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/var/lib/puppet/preview]{:path=>"/var/lib/puppet/preview", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/var/lib/puppet/ssl/certs]{:path=>"/var/lib/puppet/ssl/certs", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/var/lib/puppet/ssl]{:path=>"/var/lib/puppet/ssl", :mode=>"771", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/var/lib/puppet/ssl/public_keys]{:path=>"/var/lib/puppet/ssl/public_keys", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/var/lib/puppet/ssl/certificate_requests]{:path=>"/var/lib/puppet/ssl/certificate_requests", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/var/lib/puppet/ssl/private_keys]{:path=>"/var/lib/puppet/ssl/private_keys", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/var/lib/puppet/ssl/private]{:path=>"/var/lib/puppet/ssl/private", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostcert': 'File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostprivkey': 'File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem", :mode=>"640", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostpubkey': 'File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'localcacert': 'File[/var/lib/puppet/ssl/certs/ca.pem]{:path=>"/var/lib/puppet/ssl/certs/ca.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientyamldir': 'File[/var/lib/puppet/client_yaml]{:path=>"/var/lib/puppet/client_yaml", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'client_datadir': 'File[/var/lib/puppet/client_data]{:path=>"/var/lib/puppet/client_data", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientbucketdir': 'File[/var/lib/puppet/clientbucket]{:path=>"/var/lib/puppet/clientbucket", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'lastrunfile': 'File[/var/lib/puppet/state/last_run_summary.yaml]{:path=>"/var/lib/puppet/state/last_run_summary.yaml", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'graphdir': 'File[/var/lib/puppet/state/graphs]{:path=>"/var/lib/puppet/state/graphs", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/var/lib/puppet/facts.d]{:path=>"/var/lib/puppet/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: /File[/var/lib/puppet/state]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/lib]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/preview]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/certs]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/public_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certificate_requests]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/private_keys]
Debug: /File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/public_keys]
Debug: /File[/var/lib/puppet/ssl/certs/ca.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/client_yaml]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/client_data]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/clientbucket]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/state/last_run_summary.yaml]: Autorequiring File[/var/lib/puppet/state]
Debug: /File[/var/lib/puppet/state/graphs]: Autorequiring File[/var/lib/puppet/state]
Debug: /File[/var/lib/puppet/facts.d]: Autorequiring File[/var/lib/puppet]
Debug: Finishing transaction 20453660
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Runtime environment: puppet_version=3.8.5, ruby_version=2.3.1, run_mode=agent, default_encoding=UTF-8
Debug: Using settings: adding file resource 'confdir': 'File[/etc/puppet]{:path=>"/etc/puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'vardir': 'File[/var/lib/puppet]{:path=>"/var/lib/puppet", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/var/log/puppet]{:path=>"/var/log/puppet", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/var/lib/puppet/state]{:path=>"/var/lib/puppet/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/run/puppet]{:path=>"/run/puppet", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/var/lib/puppet/lib]{:path=>"/var/lib/puppet/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/var/lib/puppet/preview]{:path=>"/var/lib/puppet/preview", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/var/lib/puppet/ssl/certs]{:path=>"/var/lib/puppet/ssl/certs", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/var/lib/puppet/ssl]{:path=>"/var/lib/puppet/ssl", :mode=>"771", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/var/lib/puppet/ssl/public_keys]{:path=>"/var/lib/puppet/ssl/public_keys", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/var/lib/puppet/ssl/certificate_requests]{:path=>"/var/lib/puppet/ssl/certificate_requests", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/var/lib/puppet/ssl/private_keys]{:path=>"/var/lib/puppet/ssl/private_keys", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/var/lib/puppet/ssl/private]{:path=>"/var/lib/puppet/ssl/private", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostcert': 'File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostprivkey': 'File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem", :mode=>"640", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostpubkey': 'File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'localcacert': 'File[/var/lib/puppet/ssl/certs/ca.pem]{:path=>"/var/lib/puppet/ssl/certs/ca.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/var/lib/puppet/facts.d]{:path=>"/var/lib/puppet/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: /File[/var/lib/puppet/state]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/lib]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/preview]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/certs]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/public_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certificate_requests]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/private_keys]
Debug: /File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/public_keys]
Debug: /File[/var/lib/puppet/ssl/certs/ca.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/facts.d]: Autorequiring File[/var/lib/puppet]
Debug: Finishing transaction 20404360
Debug: Using cached certificate for ca
Debug: Using cached certificate for slave1.zyxel.setup
Notice: Run of Puppet configuration client already in progress; skipping  (/var/lib/puppet/state/agent_catalog_run.lock exists)


slave1@slave1:/etc/puppet$ puppet agent --test --debug
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Using settings: adding file resource 'confdir': 'File[/home/slave1/.puppet]{:path=>"/home/slave1/.puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'vardir': 'File[/home/slave1/.puppet/var]{:path=>"/home/slave1/.puppet/var", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/home/slave1/.puppet/var/log]{:path=>"/home/slave1/.puppet/var/log", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/home/slave1/.puppet/var/state]{:path=>"/home/slave1/.puppet/var/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/home/slave1/.puppet/var/run]{:path=>"/home/slave1/.puppet/var/run", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/home/slave1/.puppet/var/lib]{:path=>"/home/slave1/.puppet/var/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/home/slave1/.puppet/var/preview]{:path=>"/home/slave1/.puppet/var/preview", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/home/slave1/.puppet/ssl/certs]{:path=>"/home/slave1/.puppet/ssl/certs", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/home/slave1/.puppet/ssl]{:path=>"/home/slave1/.puppet/ssl", :mode=>"771", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/home/slave1/.puppet/ssl/public_keys]{:path=>"/home/slave1/.puppet/ssl/public_keys", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/home/slave1/.puppet/ssl/certificate_requests]{:path=>"/home/slave1/.puppet/ssl/certificate_requests", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/home/slave1/.puppet/ssl/private_keys]{:path=>"/home/slave1/.puppet/ssl/private_keys", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/home/slave1/.puppet/ssl/private]{:path=>"/home/slave1/.puppet/ssl/private", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientyamldir': 'File[/home/slave1/.puppet/var/client_yaml]{:path=>"/home/slave1/.puppet/var/client_yaml", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'client_datadir': 'File[/home/slave1/.puppet/var/client_data]{:path=>"/home/slave1/.puppet/var/client_data", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientbucketdir': 'File[/home/slave1/.puppet/var/clientbucket]{:path=>"/home/slave1/.puppet/var/clientbucket", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'graphdir': 'File[/home/slave1/.puppet/var/state/graphs]{:path=>"/home/slave1/.puppet/var/state/graphs", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/home/slave1/.puppet/var/facts.d]{:path=>"/home/slave1/.puppet/var/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: /File[/home/slave1/.puppet/var]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/var/log]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/state]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/run]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/lib]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/preview]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/ssl/certs]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/ssl/public_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/certificate_requests]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/var/client_yaml]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/client_data]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/clientbucket]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/state/graphs]: Autorequiring File[/home/slave1/.puppet/var/state]
Debug: /File[/home/slave1/.puppet/var/facts.d]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet]/ensure: created
Debug: /File[/home/slave1/.puppet/var]/ensure: created
Debug: /File[/home/slave1/.puppet/var/state]/ensure: created
Debug: /File[/home/slave1/.puppet/var/lib]/ensure: created
Debug: /File[/home/slave1/.puppet/var/client_yaml]/ensure: created
Debug: /File[/home/slave1/.puppet/ssl]/ensure: created
Debug: /File[/home/slave1/.puppet/ssl/private_keys]/ensure: created
Debug: /File[/home/slave1/.puppet/var/facts.d]/ensure: created
Debug: /File[/home/slave1/.puppet/ssl/public_keys]/ensure: created
Debug: /File[/home/slave1/.puppet/ssl/certificate_requests]/ensure: created
Debug: /File[/home/slave1/.puppet/var/preview]/ensure: created
Debug: /File[/home/slave1/.puppet/var/clientbucket]/ensure: created
Debug: /File[/home/slave1/.puppet/var/log]/ensure: created
Debug: /File[/home/slave1/.puppet/var/state/graphs]/ensure: created
Debug: /File[/home/slave1/.puppet/ssl/certs]/ensure: created
Debug: /File[/home/slave1/.puppet/var/run]/ensure: created
Debug: /File[/home/slave1/.puppet/ssl/private]/ensure: created
Debug: /File[/home/slave1/.puppet/var/client_data]/ensure: created
Debug: Finishing transaction 22470260
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Runtime environment: puppet_version=3.8.5, ruby_version=2.3.1, run_mode=agent, default_encoding=UTF-8
Debug: Using settings: adding file resource 'confdir': 'File[/home/slave1/.puppet]{:path=>"/home/slave1/.puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'vardir': 'File[/home/slave1/.puppet/var]{:path=>"/home/slave1/.puppet/var", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/home/slave1/.puppet/var/log]{:path=>"/home/slave1/.puppet/var/log", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/home/slave1/.puppet/var/state]{:path=>"/home/slave1/.puppet/var/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/home/slave1/.puppet/var/run]{:path=>"/home/slave1/.puppet/var/run", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/home/slave1/.puppet/var/lib]{:path=>"/home/slave1/.puppet/var/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/home/slave1/.puppet/var/preview]{:path=>"/home/slave1/.puppet/var/preview", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/home/slave1/.puppet/ssl/certs]{:path=>"/home/slave1/.puppet/ssl/certs", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/home/slave1/.puppet/ssl]{:path=>"/home/slave1/.puppet/ssl", :mode=>"771", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/home/slave1/.puppet/ssl/public_keys]{:path=>"/home/slave1/.puppet/ssl/public_keys", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/home/slave1/.puppet/ssl/certificate_requests]{:path=>"/home/slave1/.puppet/ssl/certificate_requests", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/home/slave1/.puppet/ssl/private_keys]{:path=>"/home/slave1/.puppet/ssl/private_keys", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/home/slave1/.puppet/ssl/private]{:path=>"/home/slave1/.puppet/ssl/private", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/home/slave1/.puppet/var/facts.d]{:path=>"/home/slave1/.puppet/var/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: /File[/home/slave1/.puppet/var]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/var/log]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/state]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/run]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/lib]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/preview]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/ssl/certs]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/ssl/public_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/certificate_requests]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/var/facts.d]: Autorequiring File[/home/slave1/.puppet/var]
Debug: Finishing transaction 23722220
Info: Creating a new SSL key for slave1.zyxel.setup
Debug: Creating new connection for https://puppet:8140
Info: Caching certificate for ca
Debug: Creating new connection for https://puppet:8140
Info: Caching certificate for slave1.zyxel.setup
Error: Could not request certificate: The certificate retrieved from the master does not match the agent's private key.
Certificate fingerprint: 4F:BD:D1:6D:BE:63:E9:5C:06:39:E4:11:05:23:9E:E2:7F:47:3F:8E:0F:0C:3A:20:19:84:9B:B8:B6:BC:AC:F7
To fix this, remove the certificate from both the master and the agent and then start a puppet run, which will automatically regenerate a certficate.
On the master:
  puppet cert clean slave1.zyxel.setup
On the agent:
  1a. On most platforms: find /home/slave1/.puppet/ssl -name slave1.zyxel.setup.pem -delete
  1b. On Windows: del "/home/slave1/.puppet/ssl/slave1.zyxel.setup.pem" /f
  2. puppet agent -t

Exiting; failed to retrieve certificate and waitforcert is disabled



slave1@slave1:/etc/puppet$ sudo puppet agent --test --verbose --debug --noop
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Using settings: adding file resource 'confdir': 'File[/etc/puppet]{:path=>"/etc/puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Puppet::Type::User::ProviderUser_role_add: file roleadd does not exist
Debug: Puppet::Type::User::ProviderPw: file pw does not exist
Debug: Failed to load library 'ldap' for feature 'ldap'
Debug: Puppet::Type::User::ProviderLdap: feature ldap is missing
Debug: Puppet::Type::User::ProviderDirectoryservice: file /usr/bin/dsimport does not exist
Debug: /User[puppet]: Provider useradd does not support features libuser; not managing attribute forcelocal
Debug: Puppet::Type::Group::ProviderPw: file pw does not exist
Debug: Failed to load library 'ldap' for feature 'ldap'
Debug: Puppet::Type::Group::ProviderLdap: feature ldap is missing
Debug: Puppet::Type::Group::ProviderDirectoryservice: file /usr/bin/dscl does not exist
Debug: /Group[puppet]: Provider groupadd does not support features libuser; not managing attribute forcelocal
Debug: Using settings: adding file resource 'vardir': 'File[/var/lib/puppet]{:path=>"/var/lib/puppet", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/var/log/puppet]{:path=>"/var/log/puppet", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/var/lib/puppet/state]{:path=>"/var/lib/puppet/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/run/puppet]{:path=>"/run/puppet", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/var/lib/puppet/lib]{:path=>"/var/lib/puppet/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/var/lib/puppet/preview]{:path=>"/var/lib/puppet/preview", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/var/lib/puppet/ssl/certs]{:path=>"/var/lib/puppet/ssl/certs", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/var/lib/puppet/ssl]{:path=>"/var/lib/puppet/ssl", :mode=>"771", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/var/lib/puppet/ssl/public_keys]{:path=>"/var/lib/puppet/ssl/public_keys", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/var/lib/puppet/ssl/certificate_requests]{:path=>"/var/lib/puppet/ssl/certificate_requests", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/var/lib/puppet/ssl/private_keys]{:path=>"/var/lib/puppet/ssl/private_keys", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/var/lib/puppet/ssl/private]{:path=>"/var/lib/puppet/ssl/private", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostcert': 'File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostprivkey': 'File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem", :mode=>"640", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostpubkey': 'File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'localcacert': 'File[/var/lib/puppet/ssl/certs/ca.pem]{:path=>"/var/lib/puppet/ssl/certs/ca.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientyamldir': 'File[/var/lib/puppet/client_yaml]{:path=>"/var/lib/puppet/client_yaml", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'client_datadir': 'File[/var/lib/puppet/client_data]{:path=>"/var/lib/puppet/client_data", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientbucketdir': 'File[/var/lib/puppet/clientbucket]{:path=>"/var/lib/puppet/clientbucket", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'lastrunfile': 'File[/var/lib/puppet/state/last_run_summary.yaml]{:path=>"/var/lib/puppet/state/last_run_summary.yaml", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'graphdir': 'File[/var/lib/puppet/state/graphs]{:path=>"/var/lib/puppet/state/graphs", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/var/lib/puppet/facts.d]{:path=>"/var/lib/puppet/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: /File[/var/lib/puppet/state]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/lib]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/preview]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/certs]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/public_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certificate_requests]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/private_keys]
Debug: /File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/public_keys]
Debug: /File[/var/lib/puppet/ssl/certs/ca.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/client_yaml]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/client_data]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/clientbucket]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/state/last_run_summary.yaml]: Autorequiring File[/var/lib/puppet/state]
Debug: /File[/var/lib/puppet/state/graphs]: Autorequiring File[/var/lib/puppet/state]
Debug: /File[/var/lib/puppet/facts.d]: Autorequiring File[/var/lib/puppet]
Debug: Finishing transaction 20905160
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Runtime environment: puppet_version=3.8.5, ruby_version=2.3.1, run_mode=agent, default_encoding=UTF-8
Debug: Using settings: adding file resource 'confdir': 'File[/etc/puppet]{:path=>"/etc/puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'vardir': 'File[/var/lib/puppet]{:path=>"/var/lib/puppet", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/var/log/puppet]{:path=>"/var/log/puppet", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/var/lib/puppet/state]{:path=>"/var/lib/puppet/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/run/puppet]{:path=>"/run/puppet", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/var/lib/puppet/lib]{:path=>"/var/lib/puppet/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/var/lib/puppet/preview]{:path=>"/var/lib/puppet/preview", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/var/lib/puppet/ssl/certs]{:path=>"/var/lib/puppet/ssl/certs", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/var/lib/puppet/ssl]{:path=>"/var/lib/puppet/ssl", :mode=>"771", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/var/lib/puppet/ssl/public_keys]{:path=>"/var/lib/puppet/ssl/public_keys", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/var/lib/puppet/ssl/certificate_requests]{:path=>"/var/lib/puppet/ssl/certificate_requests", :mode=>"755", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/var/lib/puppet/ssl/private_keys]{:path=>"/var/lib/puppet/ssl/private_keys", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/var/lib/puppet/ssl/private]{:path=>"/var/lib/puppet/ssl/private", :mode=>"750", :owner=>"puppet", :group=>"puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostcert': 'File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostprivkey': 'File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem", :mode=>"640", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostpubkey': 'File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]{:path=>"/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'localcacert': 'File[/var/lib/puppet/ssl/certs/ca.pem]{:path=>"/var/lib/puppet/ssl/certs/ca.pem", :mode=>"644", :owner=>"puppet", :group=>"puppet", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/var/lib/puppet/facts.d]{:path=>"/var/lib/puppet/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: /File[/var/lib/puppet/state]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/lib]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/preview]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/certs]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl]: Autorequiring File[/var/lib/puppet]
Debug: /File[/var/lib/puppet/ssl/public_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certificate_requests]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private_keys]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/private]: Autorequiring File[/var/lib/puppet/ssl]
Debug: /File[/var/lib/puppet/ssl/certs/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/ssl/private_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/private_keys]
Debug: /File[/var/lib/puppet/ssl/public_keys/slave1.zyxel.setup.pem]: Autorequiring File[/var/lib/puppet/ssl/public_keys]
Debug: /File[/var/lib/puppet/ssl/certs/ca.pem]: Autorequiring File[/var/lib/puppet/ssl/certs]
Debug: /File[/var/lib/puppet/facts.d]: Autorequiring File[/var/lib/puppet]
Debug: Finishing transaction 23414460
Debug: Using cached certificate for ca
Debug: Using cached certificate for slave1.zyxel.setup
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Using settings: adding file resource 'clientyamldir': 'File[/var/lib/puppet/client_yaml]{:path=>"/var/lib/puppet/client_yaml", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'client_datadir': 'File[/var/lib/puppet/client_data]{:path=>"/var/lib/puppet/client_data", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientbucketdir': 'File[/var/lib/puppet/clientbucket]{:path=>"/var/lib/puppet/clientbucket", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'lastrunfile': 'File[/var/lib/puppet/state/last_run_summary.yaml]{:path=>"/var/lib/puppet/state/last_run_summary.yaml", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'graphdir': 'File[/var/lib/puppet/state/graphs]{:path=>"/var/lib/puppet/state/graphs", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Finishing transaction 22539840
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Failed to load library 'msgpack' for feature 'msgpack'
Debug: Puppet::Network::Format[msgpack]: feature msgpack is missing
Debug: node supports formats: pson yaml b64_zlib_yaml raw
Debug: Using cached certificate for ca
Debug: Using cached certificate for slave1.zyxel.setup
Debug: Creating new connection for https://master1.zyxel.setup, master1.local:8140
Debug: Creating new connection for https://master1.zyxel.setup, master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup, master1.local:8140
Warning: Unable to fetch my node definition, but the agent run will continue:
Warning: Failed to open TCP connection to master1.zyxel.setup, master1.local:8140 (getaddrinfo: Name or service not known)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Info: Retrieving pluginfacts
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Failed to load library 'msgpack' for feature 'msgpack'
Debug: Puppet::Network::Format[msgpack]: feature msgpack is missing
Debug: file_metadata supports formats: pson yaml b64_zlib_yaml raw
Debug: Creating new connection for https://master1.zyxel.setup,%20master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup,%20master1.local:8140
Error: /File[/var/lib/puppet/facts.d]: Failed to generate additional resources using 'eval_generate': Failed to open TCP connection to master1.zyxel.setup,%20master1.local:8140 (getaddrinfo: Name or service not known)
Debug: Failed to load library 'msgpack' for feature 'msgpack'
Debug: Puppet::Network::Format[msgpack]: feature msgpack is missing
Debug: file_metadata supports formats: pson yaml b64_zlib_yaml raw
Debug: Creating new connection for https://master1.zyxel.setup,%20master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup,%20master1.local:8140
Error: /File[/var/lib/puppet/facts.d]: Could not evaluate: Could not retrieve file metadata for puppet://master1.zyxel.setup, master1.local/pluginfacts: Failed to open TCP connection to master1.zyxel.setup,%20master1.local:8140 (getaddrinfo: Name or service not known)
Debug: Finishing transaction 14904320
Info: Retrieving plugin
Debug: Failed to load library 'msgpack' for feature 'msgpack'
Debug: Puppet::Network::Format[msgpack]: feature msgpack is missing
Debug: file_metadata supports formats: pson yaml b64_zlib_yaml raw
Debug: Creating new connection for https://master1.zyxel.setup,%20master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup,%20master1.local:8140
Error: /File[/var/lib/puppet/lib]: Failed to generate additional resources using 'eval_generate': Failed to open TCP connection to master1.zyxel.setup,%20master1.local:8140 (getaddrinfo: Name or service not known)
Debug: Failed to load library 'msgpack' for feature 'msgpack'
Debug: Puppet::Network::Format[msgpack]: feature msgpack is missing
Debug: file_metadata supports formats: pson yaml b64_zlib_yaml raw
Debug: Creating new connection for https://master1.zyxel.setup,%20master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup,%20master1.local:8140
Error: /File[/var/lib/puppet/lib]: Could not evaluate: Could not retrieve file metadata for puppet://master1.zyxel.setup, master1.local/plugins: Failed to open TCP connection to master1.zyxel.setup,%20master1.local:8140 (getaddrinfo: Name or service not known)
Debug: Finishing transaction 23131540
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Loading external facts from /var/lib/puppet/facts.d
Debug: Failed to load library 'msgpack' for feature 'msgpack'
Debug: Puppet::Network::Format[msgpack]: feature msgpack is missing
Debug: catalog supports formats: pson yaml b64_zlib_yaml dot raw
Debug: Creating new connection for https://master1.zyxel.setup, master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup, master1.local:8140
Error: Could not retrieve catalog from remote server: Failed to open TCP connection to master1.zyxel.setup, master1.local:8140 (getaddrinfo: Name or service not known)
Warning: Not using cache on failed catalog
Error: Could not retrieve catalog; skipping run
Debug: Executing '/etc/puppet/etckeeper-commit-post'
Debug: Creating new connection for https://master1.zyxel.setup, master1.local:8140
Debug: Starting connection for https://master1.zyxel.setup, master1.local:8140
Error: Could not send report: Failed to open TCP connection to master1.zyxel.setup, master1.local:8140 (getaddrinfo: Name or service not known)
slave1@slave1:/etc/puppet$ puppet agent --test --debug
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Using settings: adding file resource 'confdir': 'File[/home/slave1/.puppet]{:path=>"/home/slave1/.puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'vardir': 'File[/home/slave1/.puppet/var]{:path=>"/home/slave1/.puppet/var", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/home/slave1/.puppet/var/log]{:path=>"/home/slave1/.puppet/var/log", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/home/slave1/.puppet/var/state]{:path=>"/home/slave1/.puppet/var/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/home/slave1/.puppet/var/run]{:path=>"/home/slave1/.puppet/var/run", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/home/slave1/.puppet/var/lib]{:path=>"/home/slave1/.puppet/var/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/home/slave1/.puppet/var/preview]{:path=>"/home/slave1/.puppet/var/preview", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/home/slave1/.puppet/ssl/certs]{:path=>"/home/slave1/.puppet/ssl/certs", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/home/slave1/.puppet/ssl]{:path=>"/home/slave1/.puppet/ssl", :mode=>"771", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/home/slave1/.puppet/ssl/public_keys]{:path=>"/home/slave1/.puppet/ssl/public_keys", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/home/slave1/.puppet/ssl/certificate_requests]{:path=>"/home/slave1/.puppet/ssl/certificate_requests", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/home/slave1/.puppet/ssl/private_keys]{:path=>"/home/slave1/.puppet/ssl/private_keys", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/home/slave1/.puppet/ssl/private]{:path=>"/home/slave1/.puppet/ssl/private", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostcert': 'File[/home/slave1/.puppet/ssl/certs/slave1.zyxel.setup.pem]{:path=>"/home/slave1/.puppet/ssl/certs/slave1.zyxel.setup.pem", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostprivkey': 'File[/home/slave1/.puppet/ssl/private_keys/slave1.zyxel.setup.pem]{:path=>"/home/slave1/.puppet/ssl/private_keys/slave1.zyxel.setup.pem", :mode=>"640", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostpubkey': 'File[/home/slave1/.puppet/ssl/public_keys/slave1.zyxel.setup.pem]{:path=>"/home/slave1/.puppet/ssl/public_keys/slave1.zyxel.setup.pem", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'localcacert': 'File[/home/slave1/.puppet/ssl/certs/ca.pem]{:path=>"/home/slave1/.puppet/ssl/certs/ca.pem", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientyamldir': 'File[/home/slave1/.puppet/var/client_yaml]{:path=>"/home/slave1/.puppet/var/client_yaml", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'client_datadir': 'File[/home/slave1/.puppet/var/client_data]{:path=>"/home/slave1/.puppet/var/client_data", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'clientbucketdir': 'File[/home/slave1/.puppet/var/clientbucket]{:path=>"/home/slave1/.puppet/var/clientbucket", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'graphdir': 'File[/home/slave1/.puppet/var/state/graphs]{:path=>"/home/slave1/.puppet/var/state/graphs", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/home/slave1/.puppet/var/facts.d]{:path=>"/home/slave1/.puppet/var/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: /File[/home/slave1/.puppet/var]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/var/log]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/state]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/run]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/lib]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/preview]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/ssl/certs]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/ssl/public_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/certificate_requests]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/certs/slave1.zyxel.setup.pem]: Autorequiring File[/home/slave1/.puppet/ssl/certs]
Debug: /File[/home/slave1/.puppet/ssl/private_keys/slave1.zyxel.setup.pem]: Autorequiring File[/home/slave1/.puppet/ssl/private_keys]
Debug: /File[/home/slave1/.puppet/ssl/public_keys/slave1.zyxel.setup.pem]: Autorequiring File[/home/slave1/.puppet/ssl/public_keys]
Debug: /File[/home/slave1/.puppet/ssl/certs/ca.pem]: Autorequiring File[/home/slave1/.puppet/ssl/certs]
Debug: /File[/home/slave1/.puppet/var/client_yaml]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/client_data]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/clientbucket]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/state/graphs]: Autorequiring File[/home/slave1/.puppet/var/state]
Debug: /File[/home/slave1/.puppet/var/facts.d]: Autorequiring File[/home/slave1/.puppet/var]
Debug: Finishing transaction 17200920
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Evicting cache entry for environment 'production'
Debug: Caching environment 'production' (ttl = 0 sec)
Debug: Runtime environment: puppet_version=3.8.5, ruby_version=2.3.1, run_mode=agent, default_encoding=UTF-8
Debug: Using settings: adding file resource 'confdir': 'File[/home/slave1/.puppet]{:path=>"/home/slave1/.puppet", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'vardir': 'File[/home/slave1/.puppet/var]{:path=>"/home/slave1/.puppet/var", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'logdir': 'File[/home/slave1/.puppet/var/log]{:path=>"/home/slave1/.puppet/var/log", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'statedir': 'File[/home/slave1/.puppet/var/state]{:path=>"/home/slave1/.puppet/var/state", :mode=>"1755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'rundir': 'File[/home/slave1/.puppet/var/run]{:path=>"/home/slave1/.puppet/var/run", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'libdir': 'File[/home/slave1/.puppet/var/lib]{:path=>"/home/slave1/.puppet/var/lib", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'preview_outputdir': 'File[/home/slave1/.puppet/var/preview]{:path=>"/home/slave1/.puppet/var/preview", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'certdir': 'File[/home/slave1/.puppet/ssl/certs]{:path=>"/home/slave1/.puppet/ssl/certs", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'ssldir': 'File[/home/slave1/.puppet/ssl]{:path=>"/home/slave1/.puppet/ssl", :mode=>"771", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'publickeydir': 'File[/home/slave1/.puppet/ssl/public_keys]{:path=>"/home/slave1/.puppet/ssl/public_keys", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'requestdir': 'File[/home/slave1/.puppet/ssl/certificate_requests]{:path=>"/home/slave1/.puppet/ssl/certificate_requests", :mode=>"755", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatekeydir': 'File[/home/slave1/.puppet/ssl/private_keys]{:path=>"/home/slave1/.puppet/ssl/private_keys", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'privatedir': 'File[/home/slave1/.puppet/ssl/private]{:path=>"/home/slave1/.puppet/ssl/private", :mode=>"750", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostcert': 'File[/home/slave1/.puppet/ssl/certs/slave1.zyxel.setup.pem]{:path=>"/home/slave1/.puppet/ssl/certs/slave1.zyxel.setup.pem", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostprivkey': 'File[/home/slave1/.puppet/ssl/private_keys/slave1.zyxel.setup.pem]{:path=>"/home/slave1/.puppet/ssl/private_keys/slave1.zyxel.setup.pem", :mode=>"640", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'hostpubkey': 'File[/home/slave1/.puppet/ssl/public_keys/slave1.zyxel.setup.pem]{:path=>"/home/slave1/.puppet/ssl/public_keys/slave1.zyxel.setup.pem", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'localcacert': 'File[/home/slave1/.puppet/ssl/certs/ca.pem]{:path=>"/home/slave1/.puppet/ssl/certs/ca.pem", :mode=>"644", :ensure=>:file, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: Using settings: adding file resource 'pluginfactdest': 'File[/home/slave1/.puppet/var/facts.d]{:path=>"/home/slave1/.puppet/var/facts.d", :ensure=>:directory, :loglevel=>:debug, :links=>:follow, :backup=>false}'
Debug: /File[/home/slave1/.puppet/var]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/var/log]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/state]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/run]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/lib]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/var/preview]: Autorequiring File[/home/slave1/.puppet/var]
Debug: /File[/home/slave1/.puppet/ssl/certs]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl]: Autorequiring File[/home/slave1/.puppet]
Debug: /File[/home/slave1/.puppet/ssl/public_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/certificate_requests]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private_keys]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/private]: Autorequiring File[/home/slave1/.puppet/ssl]
Debug: /File[/home/slave1/.puppet/ssl/certs/slave1.zyxel.setup.pem]: Autorequiring File[/home/slave1/.puppet/ssl/certs]
Debug: /File[/home/slave1/.puppet/ssl/private_keys/slave1.zyxel.setup.pem]: Autorequiring File[/home/slave1/.puppet/ssl/private_keys]
Debug: /File[/home/slave1/.puppet/ssl/public_keys/slave1.zyxel.setup.pem]: Autorequiring File[/home/slave1/.puppet/ssl/public_keys]
Debug: /File[/home/slave1/.puppet/ssl/certs/ca.pem]: Autorequiring File[/home/slave1/.puppet/ssl/certs]
Debug: /File[/home/slave1/.puppet/var/facts.d]: Autorequiring File[/home/slave1/.puppet/var]
Debug: Finishing transaction 3718300
Debug: Using cached certificate for ca
Debug: Using cached certificate for slave1.zyxel.setup
Error: Could not request certificate: The certificate retrieved from the master does not match the agent's private key.
Certificate fingerprint: 4F:BD:D1:6D:BE:63:E9:5C:06:39:E4:11:05:23:9E:E2:7F:47:3F:8E:0F:0C:3A:20:19:84:9B:B8:B6:BC:AC:F7
To fix this, remove the certificate from both the master and the agent and then start a puppet run, which will automatically regenerate a certficate.
On the master:
  puppet cert clean slave1.zyxel.setup
On the agent:
  1a. On most platforms: find /home/slave1/.puppet/ssl -name slave1.zyxel.setup.pem -delete
  1b. On Windows: del "/home/slave1/.puppet/ssl/slave1.zyxel.setup.pem" /f
  2. puppet agent -t

Exiting; failed to retrieve certificate and waitforcert is disabled
slave1@slave1:
```

Tässä välissä pidin päivän tauon. Seuraavana päivänä puhdistin certifikaatit koneilta ja ajoin testiajon komennolla 

puppet agent --test


slave1@slave1puppet agent --test
Info: Creating a new SSL key for slave1.zyxel.setup
Info: Caching certificate_request for slave1.zyxel.setup
Exiting; no certificate found and waitforcert is disabled

Tajusin että tämä komento luo jostain syystä aina uuden certifikaatin, ja sotkee siten aiemmat sertit kokonaan. Hyväksyin tämän testiajon jälkeen sertifikaatin ja päätin antaa koneen odottaa hetken ja sitten huomasin että puppet suostui asentamaan moduulit masterilta itsenäisesti.

Tarinan opetus: kun olet hyväksynyt sertifikaatit niin älä anna enää puppet test komentoja koska ne luovat uuden sertin ja sotkevat tilanteen täysin. Käytä sen sijaan waitforcert määritystä, jolla voit vaikuttaa siihen kuinka usein puppet hakee moduulit masterilta.


# Yllä oleva juttu on väärinj, koko ongelma johtuikin oikeasti siitä, että olin epähuomiossa antanut komennon ilman sudoa.

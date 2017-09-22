# Ansible
## Tutustuminen Ansibleen
Aloitin testauksen asentamalla kaksi kappaletta Xubuntua (16.04.3) Virtualboxiin. Toinen kone toimii masterina ja toinen kohteena. Tämän jälkeen aloin lukemaan Ansiblen [dokumentaatiota](https://docs.ansible.com/ansible/latest/intro.html) ja [Wikipedia-artikkelia](https://en.wikipedia.org/wiki/Ansible_(software)). 

Asennus masterille kävi kätevästi komennolla `sudo apt-get -y install ansible`. Lisäsin kohdekoneen IP-osoitteen `/etc/ansible/hosts` tiedostoon ja tein sille ryhmän test.
``` 
[test]
10.0.0.64
```
Ansible toimii SSH:n yli, joten asensin kohteelle SSH:n `sudo apt-get -y install ssh`. Tämän jälkeen lisäsin masterin julkisen avaimen kohteelle.
```
ssh-keygen -t rsa
ssh-copy-id joona@10.0.0.64
```
Kokeilin yhteyttä masterilla komennolla `ansible test -m ping`. Test on ryhmän nimi, johon kohde kuuluu ja ping on moduuli joka ajetaan.
```
10.0.0.64 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```
Pingi meni läpi ja kohde vastasi.

## Playbook

Playbookit ovat YAML-formaatissa kirjoitettuja ohjeita, jotka määrittelevät tehtävät kohteille. Kokeilin esimerkkinä äskeistä ping-komentoa. `sudoedit /etc/ansible/apache.yml`. Tiedoston nimenä on apache, sillä pingin jälkeen kokeilen apachen asennusta.
```
---
- hosts: test
  remote_user: joona
  tasks:
    - name: testing ping
      ping:
```
Ajoin playbookin komennolla `ansible-playbook /etc/ansible/apache.yml`
```
PLAY *************************

TASK [setup] ********************
ok: [10.0.0.64]

TASK [testing ping] **********
ok: [10.0.0.64]

PLAY RECAP ********************
10.0.0.64                  : ok=2    changed=0    unreachable=0    failed=0 
```
Tulosteesta näkyy, että playbookin ajaminen onnistui.

### Pakettien asennus playbookilla

Lisäsin apache.yml playbookiin Apachen asennuksen [dokumentaation](https://docs.ansible.com/ansible/latest/package_module.html) mukaan.
```
---
- hosts: test
  remote_user: joona
  tasks:
    - name: testing ping
      ping:
    - name: install apache
      package:
        name: apache2
        state: latest
```
Ennen playbookin ajamista avasin kohteella selaimen ja tarkastin ettei localhost osoitteessa näy mitään. Selain tarjosi "Unable to connect", joten Apachea ei koneesta löytynyt. Ajoin playbookin komennolla `ansible-playbook /etc/ansible/apache.yml`  ja sain pitkän virheilmoituksen käyttöoikeuksien puutteesta. Lisäsin playbookin loppuun `become: true`, jotta asennus ajetaan pääkäyttäjänä.
```
---
- hosts: test
  remote_user: joona
  tasks:
    - name: testing ping
      ping:
    - name: install apache
      package:
        name: apache2
        state: latest
      become: true
```
sain virheilmoituksen jossa valitetaan puuttuvaa salasanaa.
```
fatal: [10.0.0.64]: FAILED! => {"changed": false, "failed": true, "module_stderr": "", "module_stdout": "sudo: a password is required\r\n", "msg": "MODULE FAILURE", "parsed": false}
```
Dokumentaation kaivelemisen jälkeen lisäsin `--ask-become-pass` playbookin ajokomennon loppuun. Ajoin playbookin `ansible-playbook /etc/ansible/apache.yml --ask-become-pass` komennolla ja syötin kysytyn salasanan.
```
PLAY ***********************************

TASK [setup] *************************
ok: [10.0.0.64]

TASK [testing ping] ********************
ok: [10.0.0.64]

TASK [install apache] ***************
changed: [10.0.0.64]

PLAY RECAP *************************
10.0.0.64                  : ok=3    changed=1    unreachable=0    failed=0   
```
Tuloste kertoo että Ansible on tehnyt kohteessa muutoksia, eli asentanut Apachen. Avasin kohteella selaimen ja localhost osoitteessa komeili Apachen oletussivu. Playbookia uudelleen ajettaessa Ansible ilmoittaa että kaikki on ok ja muutoksia ei tehty. Kokeilin myös poistaa Apachen muuttamalla playbookissa Apachen kohdalla `state: absent`.  Ajoin playbookin ja tuloste näytti samalta kuin asentaessa, mutta nyt selain näyttää "Unable to connect" joten Apache on poistettu.

## Testiympäristö Vagrantilla

Vagrantin avulla voi luoda ja tuhota nopeasti virtuaalikoneita, joten se sopii mainiosti keskitetyn hallinnan testaamiseen. Yritin aluksi käyttää Vagrantia VirtualBoxin sisällä, jolloin se olisi luonut virtuaalikoneita virtuaalikoneen sisään, mutta törmäsin jatkuvasti ongelmiin, jotka todennäköisesti johtuivat sisäkkäisistä virtuaalikoneista. Lopulta päädyin asentamaan Vagrant ja Cygwin ohjelmat Windowsille. Cygwinin avulla pystyin käyttämään tuttuja Linux-komentoja Vagrantin hallintaan. Cygwinin emulaattorissa annoin seuraavat komennot: 
```
mkdir vagrant
cd vagrant
vagrant init bento/ubuntu-16.04
```
Tämän jälkeen virtuaalikoneen saa käyntiin `vagrant up` komennolla, mutta Ansible tarvitsee SSH-avaimen kohteelle, jotta se pystyy ottamaan siihen yhteyden. Siispä konfiguroin seuraavaksi provisioinnin, joka lisää virtuaalikoneeseen käyttäjän ja asettaa SSH-avaimen paikalleen.

### Provisiointi

Vagrant tukee provisiointia shell-scriptillä, Puppetilla, Chefillä, Saltilla, Dockerilla ja myös Ansiblella. Tutkin Vagrantin [dokumentaatiota](https://www.vagrantup.com/docs/provisioning/ansible.html), jonka perusteella määritin Ansiblen suorittamaan provisioinnin. 

#### Vagrantfile

`Vagrant init` komento luo Vagrantfile nimisen tiedoston, joka sitältää valmiiksi kommentoituja asetuksia. otin käyttöön public networkin, jotta saan masterilta yhteyden luotuun koneeseen: `config.vm.network "public_network", ip: "10.0.0.6"`, tämän lisäksi määritin provisioinnin tehtäväksi Ansiblella:
```
config.vm.provision "ansible_local" do |ansible|
	ansible.playbook = "vagrant.yml"
end
```

#### Provisiointi Ansiblella

Loin aluksi ansiblella käyttäjätunnuksen, mutta siinä oli ongelmia joita Vagrantin luomalla tunnuksella ei ollut. Esimerkiksi cd komennolla .ssh hakemistoon siirryttäessä sain virheilmoituksen `-sh: 3: cd: can't cd to .ssh`. Päätin käyttää vagrant käyttäjää testien ajamiseen, joten SSH-avaimen lisäys riitti provisiointiin. SSH:n Vagrant asentaa automaattisesti. Tein samaan hakemistoon jossa Vagrantfile sijaitsee, authorized_keys tiedoston jossa masterin julkinen avain on. Tein lisäksi samaan hakemistoon vagrant.yml playbookin, joka siirtää avaimen paikalleen:
```
---
- hosts: default
  remote_user: vagrant
  
  tasks:
    - template:
        src: authorized_keys
        dest: /home/vagrant/.ssh
        owner: vagrant
        group: vagrant
        mode: 0644
```
Tämä korvaa olemassaolevan avaimen, joten `vagrant ssh` komennolla ei enää pääse suoraan koneeseen, mutta salasana toimii yhä. Nyt saan masterilta suoraan yhteyden helposti uudelleenasennettavaan virtuaalikoneeseen.

### LAMP, roolit ja hakemistorakenne

Asensin aikaisemmin pelkän Apachen, mutta nyt on vuorossa koko LAMP-pino. Löysin hyvän [ohjeen](http://labs.qandidate.com/blog/2013/11/21/installing-a-lamp-server-with-ansible-playbooks-and-roles/) joka käy läpi LAMP asennuksen, sekä selventää rooleja ja hakemistorakennetta.

```
├── ansible.cfg
├── hosts
├── playbook.yml
└── roles
    ├── database
    │   ├── files
    │   └── tasks
    │       └── main.yml
    └── webserver
        ├── files
        │   └── index.php
        └── tasks
            └── main.yml
```
Ansiblen hakemistorakenne. Kaiken konfiguraation voisi kirjoittaa yhteen playbookiin, mutta silloin kaikki koneet konfiguroituisivat samalla tavalla. Roolien avulla voidaan päättää eri koneiden konfiguraatiot.
```
---
- hosts: all
  remote_user: vagrant
  become: yes
  roles:
    - webserver
    - database
```
Playbook.yml sisältö. Tällä hetkellä kaikille koneille annetaan roolit webserver ja database. Tässä playbookissa määritellään mitä rooleja annetaan millekin hostille.

```
---
- name: install apache
  package: name=apache2 state=present

- name: install php
  package: name=libapache2-mod-php state=present

- name: keep apache running
  service: name=apache2 state=running enabled=yes

- name: php test page
  copy: src=index.php dest=/var/www/html/index.php mode=0664
```
roles/webserver/tasks/main.yml sitältö, jossa asennetaan Apache ja PHP, pidetään huoli että Apache on käynnissä ja laitetaan roles/webserver/files/index.php paikalleen /var/www/html hakemistoon.

Index.php sisältää yksinkertaisen PHP testin.
```
<?php
echo "hello php!";
```
10.0.0.6/index.php osoitteessa näkyi "hello php!"

#### MariaDB

Löytämäni ohje asensi MariaDB:n, mutta kokeilen MySQL:ää myöhemmin.

```
---
- name: install mariaDB server
  package: name=mariadb-server state=present

- name: start mysql service
  service: name=mysql state=started enabled=true

- name: install python mysql package
  package: name=python-mysqldb state=present

- name: create new database
  mysql_db: name=vagrant state=present collation=utf8_general_ci

- name: create database user
  mysql_user: name=vagrant password=vagrant priv=*.*:ALL host=localhost state=present
```
roles/database/tasks/main.yml sisältö. Playbook asentaa MariaDB palvelun ja varmistaa että se on käynnissä. Sitten se asentaa python-mysqldb paketin, jolla tietokantaa hallitaan. Lopuksi luodaan tietokanta ja käyttäjä.

Asennuksen jälkeen otin SSH yhteyden kohdekoneelle ja kokeilin kirjautua tietokantaan `mysql -u vagrant -p`, salasanan syöttämisen jälkeen pääsin sisään. `Welcome to the MariaDB monitor.`

# Windowsin hallinta

### Masterin valmistelu

Seurasin Ansiblen [dokumentaatiota](https://docs.ansible.com/ansible/latest/intro_windows.html) Windowsiin liittyen. Ensimmäiseksi masterille täytyi asentaa pip, jotta sain pywinrm asennettua `sudo apt-get -y install python-pip` ja `pip install "pywinrm>=0.2.2"` Seuraavaksi loin /etc/ansible/group_vars/windows.yml tiedoston, jonka sisällöksi tuli seuraava:
```
ansible_user: joona
ansible_password: salasanatähän
ansible_port: 5986
ansible_connection: winrm
ansible_winrm_server_cert_validation: ignore
```
Lisäsin myös Windows koneen IP-osoitteen hosts tiedostoon omaan ryhmäänsä
```
[windows]
10.0.0.149
```

### Windowsin valmistelu

Asensin virtualboxiin Windows 10 Pro 64-bit käyttöjärjestelmän. Hain [powershell-scriptin](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1) joka valmistelee Windowsin PowerShell remoting yhteyden käyttöön ja tallensin sen työpöydälle nimellä `ansible.ps1`. Tämän jälkeen avasin PowerShellin pääkäyttäjänä ja yritin ajaa scriptin, mutta Windows sanoi että scriptien ajaminen on estetty. [Stackoverflow](https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system) auttoi ja komennon `Set-ExecutionPolicy RemoteSigned` jälkeen scriptin ajo onnistui.

### Windows ping moduulin testaus

`Ansible windows -m win_ping` komento testaa yhteyttä Windowsiin. Vastauksena tuli:
```
10.0.0.149 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
```


## Käytettyjä lähteitä

* https://docs.ansible.com/ansible/latest/intro.html
* https://en.wikipedia.org/wiki/Ansible_(software)
* https://docs.ansible.com/ansible/latest/package_module.html
* https://www.vagrantup.com/docs/provisioning/ansible.html
* http://labs.qandidate.com/blog/2013/11/21/installing-a-lamp-server-with-ansible-playbooks-and-roles/
* https://docs.ansible.com/ansible/latest/intro_windows.html
* https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system
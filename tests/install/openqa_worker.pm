use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub install_from_repos {
    diag('worker setup');
    assert_script_run('zypper --no-cd --non-interactive --gpg-auto-import-keys in os-autoinst', 600);
    assert_script_run('zypper --no-cd --non-interactive --gpg-auto-import-keys in openQA-worker', 600);
    diag('Login once with fake authentication on openqa webUI to actually create preconfigured API keys for worker authentication');
    assert_script_run('curl http://localhost/login');
    diag('adding temporary, preconfigured API keys to worker config');
    type_string('cat >> /etc/openqa/client.conf <<EOF
[localhost]
key = 1234567890ABCDEF
secret = 1234567890ABCDEF
EOF
');
    wait_still_screen(1);
    my $worker_setup = <<'EOF';
systemctl start openqa-worker@1
systemctl status --no-pager openqa-worker@1
systemctl enable openqa-worker@1
EOF
    assert_script_run($_) foreach (split /\n/, $worker_setup);
    save_screenshot;
    type_string "clear\n";
}

sub install_from_git {
    my $configure = <<'EOF';
su - postgres -c 'createuser root'
su - postgres -c 'createuser bernhard'
su - postgres -c 'createdb -O root openqa'
su - postgres -c 'createdb -O bernhard test'
su - bernhard
git clone https://github.com/os-autoinst/openQA.git
git clone https://github.com/os-autoinst/os-autoinst.git
cd openQA
for p in $(cpanfile-dump); do echo -n "perl($p) "; done | xargs zypper --non-interactive in -C
cpanm -nq --installdeps .
cd ..
do echo -n "perl($p) "; done | xargs zypper --non-interactive in -C
cpanm -nq --installdeps .
for i in headers proxy proxy_http proxy_wstunnel ; do a2enmod $i ; done
cp etc/apache2/vhosts.d/openqa-common.inc /etc/apache2/vhosts.d/
sed "s/#ServerName.*$/ServerName $(hostname)/" etc/apache2/vhosts.d/openqa.conf.template > /etc/apache2/vhosts.d/openqa.conf
systemctl restart apache2 || systemctl status --no-pager apache2
mkdir -p /var/lib/openqa/db
EOF
    script_run('zypper source-install -y --build-deps-only os-autoinst');

    sleep 3600;
}

sub run {
    #script_run('curl -O http://reflex.gforge.inria.fr/tests/xunit/jaxen/jaxen-err.xml');
    #parse_extra_log('XUnit', 'jaxen-err.xml');
    #script_run('curl -O http://e122.suse.de/tests/17321/file/slenkins_control-junit-results.xml');
    #parse_extra_log('JUnit', 'slenkins_control-junit-results.xml');
    script_run('zypper ref');
    script_run('zypper source-install -y --build-deps-only os-autoinst');
    script_run('zypper -n in -t pattern devel_basis devel_ruby devel_perl');
    script_run('cpanm -n  TAP::Formatter::JUnit');
    #install_from_git;
}

1;


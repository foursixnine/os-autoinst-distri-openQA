use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub run {
    send_key "ctrl-alt-f2";
    assert_screen "inst-console";
    type_string "root\n";
    assert_screen "password-prompt";
    type_string $testapi::password . "\n";
    wait_still_screen(2);
    diag('Ensure packagekit is not interfering with zypper calls');
    script_run('systemctl stop packagekit.service; systemctl mask packagekit.service');
    script_run('zypper rr NON_OSS');
    script_run('zypper rr OSS');
    script_run('zypper rr OSS_DEBUGINFO');
    script_run('zypper ar -Ge http://download.opensuse.org/tumbleweed/repo/oss/    repo-oss');
    script_run('zypper ar -Ge http://download.opensuse.org/tumbleweed/repo/non-oss/ repo-non-oss');
    script_run('zypper ar -Ge http://download.opensuse.org/update/tumbleweed/      repo-update');
    type_string "exit\n";
}

1;


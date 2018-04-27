use strict;
use base "openQAcoretest";
use testapi;
use utils;

sub download_and_parse {
my @tests =
    (
      { "noteasy-file.tap" => "https://gist.githubusercontent.com/foursixnine/806cd8302a4b9d6dd5d7f16fd39a489c/raw/65c40c2bdac64bf23f98f7bfed5b6a3cd401e017/test-file.tap"},
      { "scheduler_dependencies.tap" => "https://gist.githubusercontent.com/foursixnine/806cd8302a4b9d6dd5d7f16fd39a489c/raw/65c40c2bdac64bf23f98f7bfed5b6a3cd401e017/test-file.tap"},
      { "easy-file.tap" => "https://gist.githubusercontent.com/foursixnine/806cd8302a4b9d6dd5d7f16fd39a489c/raw/7428f87ecd0151b3e0a20462f760c72cc074888a/test-file.tap"},

  );
    for my $test (@tests) {
        my ($filename) = keys %{$test};
        my $url = $test->{$filename};
        script_run("curl -k -o $filename $url");
        parse_extra_log('TAP', $filename);
    }


}

sub run {
    download_and_parse;
    save_screenshot;
    script_run('prove --verbose --formatter=TAP::Formatter::JUnit t/28-logging.t > junit-logging.xml');
    parse_extra_log('XUnit', 'junit-logging.xml');
    #script_run('curl -k -O https://openqa.opensuse.org/tests/656338/file/result_array.json');
    #parse_extra_log('LTP', 'result_array.json');
}

1;


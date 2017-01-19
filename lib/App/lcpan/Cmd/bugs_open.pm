package App::lcpan::Cmd::bugs_open;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::Any::IfLOG '$log';

require App::lcpan;
require App::lcpan::Cmd::dist_meta;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Open a dist's bugtracker page in browser",
    args => {
        %App::lcpan::common_args,
        %App::lcpan::dist_args,
    },
};
sub handle_cmd {
    my %args = @_;
     my $dist = $args{dist};

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my $res = App::lcpan::Cmd::dist_meta::handle_cmd(%args);
    return [412, $res->[1]] unless $res->[0] == 200;
    my $meta = $res->[2];

    my $url;
    unless ($meta->{resources} &&
                $meta->{resources}{bugtracker} &&
                ($url = $meta->{resources}{bugtracker}{web})) {
        return [412, "No bugtracker web URL specified in the distmeta's resources"];
    }

    require Browser::Open;
    my $err = Browser::Open::open_browser($url);
    return [500, "Can't open browser"] if $err;
    [200];

}

1;
# ABSTRACT:

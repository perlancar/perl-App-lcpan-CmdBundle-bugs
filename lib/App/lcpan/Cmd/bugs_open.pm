package App::lcpan::Cmd::bugs_open;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

require App::lcpan;
require App::lcpan::Cmd::dist_meta;

our %SPEC;

$SPEC{handle_cmd} = {
    v => 1.1,
    summary => "Open a module/dist's bugtracker page in browser",
    args => {
        %App::lcpan::common_args,
        %App::lcpan::mod_or_dist_args,
    },
};
sub handle_cmd {
    my %args = @_;

    my $state = App::lcpan::_init(\%args, 'ro');
    my $dbh = $state->{dbh};

    my ($dist, $file_id);
    {
        # first find dist
        if (($file_id) = $dbh->selectrow_array(
            "SELECT file_id FROM dist WHERE name=? AND is_latest", {}, $args{module_or_dist})) {
            $dist = $args{module_or_dist};
            last;
        }
        # try mod
        if (($file_id, $dist) = $dbh->selectrow_array("SELECT m.file_id, d.name FROM module m JOIN dist d ON m.file_id=d.file_id WHERE m.name=?", {}, $args{module_or_dist})) {
            last;
        }
    }
    $file_id or return [404, "No such module/dist '$args{module_or_dist}'"];

    my $res = App::lcpan::Cmd::dist_meta::handle_cmd(%args, dist=>$dist);
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

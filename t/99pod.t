#perl -T

use Test::More;
eval "use Test::Pod 1.18";
plan skip_all => "Test::Pod 1.18 required for testing POD" if $@;

all_pod_files_ok(all_pod_files("."));

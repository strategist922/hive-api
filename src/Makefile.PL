use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'hive::api',
    AUTHOR        => 'Johan Gustavsson <johan@life-hack.org>',
    VERSION_FROM  => 'app.psgi',
    PREREQ_PM     => {
        'Amon2'                           => '3.55',
        'Amon2::Lite'                     => '0.08',
        'Text::Xslate'                    => '1.5006',
        'Plack::Session'                  => '0.14',
    },
    MIN_PERL_VERSION => '5.008001',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);

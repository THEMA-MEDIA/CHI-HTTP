# CHI::HTTP

## RFC 7234 HTTP Caching compliant CHI cache

## DESCRIPTION

This CHI subclass stores and retrieves a HTTP::Responses data, with the HTTP::Request as key. But unlike a normal key/value storage as most cages are build, this will respect the RFC 7234 HTTP Caching rules, in particular §3 (Storing Responses in Cache) and §4 (Constructing Responses from Caches).

## SYNOPSIS

    my $cache = CHI::HTTP->new( ... ); # choose your flavour
    my $agent = LWP::UserAgent->new;
    
    my $rqst = GET('http://...');
    my $resp = $cache->compute( $rqst, $options, sub { $agent->request($rqst) } );


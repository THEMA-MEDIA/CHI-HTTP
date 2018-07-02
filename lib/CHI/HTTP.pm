package CHI::HTTP;

=head1 NAME

CHI::HTTP - RFC 7234 HTTP Caching compliant CHI cache

=head1 VERSION

Version 0.00

=cut

our $VERSION = '0.00';

=head1 SYNOPSIS

    my $chi = CHI::HTTP->new( ... ); # choose your flavour
    my $agent = LWP::UserAgent->new;
    
    my $rqst = GET('http://...');
    my $resp = $chi->compute( $rqst, $options, sub { $agent->request($rqst) } );

or a very common usage pattern with caches in general, without using C<compute>:

    my $chi = CHI::HTTP->new( ... ); # choose your flavour
    my $agent = LWP::UserAgent->new;
    my $url = URI->new( 'http://...' );
    
    my $resp = $chi->get($url) or do {
        $result = $agent->get($url);
        $chi->set($url, $result->response)
    }

And it all automagically works with respect to RFC7234 - HTTP Caching.

=head1 DESCRIPTION

This L<CHI> subclass stores and retrieves a L<HTTP::Response> as data, with the
L<HTTP::Request> as key. But unlike a normal key/value storage as most caches
are build, this will respect the L<RFC 7234 Hypertext Transfer Protocol
(HTTPE<sol>1.1): Caching|http://tools.ietf.org/html/rfc7234> rules, in
particular section 3 (Storing Responses in Cache) and section 4 (Constructing
Responses from Caches).

Although the ussage of this module is first of al straightforward, it also gives
a very naive impression, at first glance.

=head1 ABOUT KEYS

As with any L<CHI> cache, we need to deal with keys to store or retrieve data.
But the keys for C<CHI::HTTP> are not just 'keys' but any of the following:

=over

=item a string, representing a URL

=item a C<URI> object

=item a C<HTTP::Request> object

=back

=head2 URLs as Keys
 
If either a string is used, or a URI object, both will be turned into a 'get'
request, using L<HTTP::Message::Common> with a C<GET> HTTP-Method.

That is why C<< $chi->get($uri) >> looks so simplistic and does what it is
suposed to do, it gets a C<HTTP::Response> if applicable.

The stringified URI part of the request will be used as the key.

=head2 C<Vary> response header

Since a server can return multiple representation variants, the HTTP Response
Header Field C<Vary> can nominate Request Header Fields that will define what
variant to choose. This implies that the same key in the Cache needs to be
capable to hold diverent variants. Because of that, some of the key-based
methods from L<CHI> will make no sense or will have different, but semantacaly
the same, behaviour.

=head1 ABOUT RFC 7234 - HTTP Caching

=head2 Storing Responses in Cache

Contrary of what normal caches will do, the C<set> method will not just store a
C<HTTP::Response> under a given C<HTTP::Request> object. There are numerous
conditions that determin whether or not a response may be stored. In short:

=over

=item HTTP Method: understood and defined as being cacheable

=item Statuscode: understood

=item Cache Directive: C<no-store>

=item Response Directive: C<private>

=item Header Field: C<Authorization>

=item Header: C<Expires>

=item Response Directive: C<max-age>

=item Response Directive: C<s-maxage>

=item Cache Control Extension

=item Status Code: defined as cacheable by default

=item Response Directive: C<public response>

=back

Unless dealt with those, a response might not be stored at all. For example, a
C<POST> request that gets a L<HTTP::Status> of C<201 - Created> will not be put
in the cache.

=head2 Constructing Responses from Caches

Just as with storing responses, there is also a whole list of conditions to be
considdered, before returning a (posibly modified) response:

=over

=item Header Field: C<Vary>

=item Pragma C<no-cache>

=item Cache Directive: C<no-cache>

=item Freshness

=item Stale Content

=back

Unlike normal responses where a normal expire duration can be obeserved, the
C<CHI::Cache> needs to consider a lot more than just that. It also will need to
add a C<Age> Response Header field.

=head1 METHODS

Since this module is a subclass of L<CHI>, one would expect that all the methods
of that parent class would be inherrited. But as described above, some methods
don't make sense and will cause runtime errors when used. The methods below
behave slightly different, but they have the same semantics as the parrent
class.

=head2 set

    $stored_resp = $chi->set( $presented_rqst, $received_resp );

This method will try to store the response for a given request. Try... because
of the RFC, not all responses may be stored.

Also, if the request was an unsafe method and the response was succesful, this
method will invalidate the stored responses, possibly by removing any associated
responses.

=head2 get

    $stored_resp = $chi->get( $presented_rqst );

This method will return a (modified) stored response, observing the rules of RFC
7234. It will return C<undef> if there is no response that can be constructed
from the Cache, without having to do a revalidation first.

=head2 compute

    $stored_resp = $chi->compute( $presented_rqst, options, CODEREF );

Just like L<CHI::compute>, this will combine the C<get> and C<set> methods. If
it can not get a response from the Cache, it will used the suplied CODEREF to
generate a respons. This would typically be a call through some UserAgent to the
origin server.

=head1 SEE ALSO

=over

=item L<RFC 7234 Hypertext Transfer Protocol (HTTPE<sol>1.1): Caching|
    http://tools.ietf.org/html/rfc7234>

=item L<HTTP::Cache>

=item L<HTTP::Caching>

=back

=head1 AUTHOR

Th. J. van Hoesel

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Theo J. van Hoesel - L<THEMA::MEDIA>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

1;

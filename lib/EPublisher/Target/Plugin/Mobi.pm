package EPublisher::Target::Plugin::Mobi;

# ABSTRACT: Use Mobi format as a target for EPublisher

use strict;
use warnings;

use File::Temp;
use EBook::MOBI;
use EPublisher::Target::Base;

our @ISA = qw(EPublisher::Target::Base);

our $VERSION = 0.01;
our $DEBUG   = 0;

sub deploy {
    my ($self) = @_;
    
    my $pods     = $self->_config->{source} || [];

    my $author         = $self->_config->{author}   || 'Perl Author';
    my $title          = $self->_config->{title}    || 'Pod Document';
    my $language       = $self->_config->{lang}     || 'en';
    my $out_filename   = $self->_config->{output}   || '';
    my $cover_filename = $self->_config->{cover}    || '';
    my $encoding       = $self->_config->{encoding} || 'utf-8';
    my $imgcover       = $self->_config->{imgcover} || '';
    my $htmcover       = $self->_config->{htmcover} || '';

    if ( !$out_filename ) {
        my $fh = File::Temp->new;
        $out_filename = $fh->filename;
    }

    # Create an object of a book
    my $book = EBook::MOBI->new();

    # give some meta information about this book
    $book->set_filename($out_filename);
    $book->set_title   ($title);
    $book->set_author  ($author);
    $book->set_encoding($encoding);

    # create title page from an image, if set
    if ($imgcover and -e $imgcover) {
        $book->add_pod_content("\n=image $imgcover\n\n");
        $book->add_pagebreak();
    }
    # create title page from mhtml, if set
    if ($htmcover) {
        $book->add_mhtml_content($htmcover);
        $book->add_pagebreak();
    }

    # insert a table of contents after the titlepage
    $book->add_toc_once();
    $book->add_pagebreak();

    # insert content of the book
    for my $data (@{$pods}) {

        my $chap = $data->{title};
        my $pod  = $data->{pod};

        $book->add_pod_content("\n=head1 $chap\n\n");
        # add the books text, which is e.g. in the POD format
        $book->add_pod_content($pod, 'pagemode', 'head0_mode');
    }

    # prepare the book (e.g. calculate the references for the TOC)
    $book->make();

    # let me see how this mobi-html looks like
    $book->print_mhtml();

    # ok, give me that mobi-book as a file!
    $book->save();

    
    return $out_filename;
}

1;


__END__
=pod

=head1 NAME

EPublisher::Target::Plugin::Text - Use Ascii text as a target for EPublisher

=head1 VERSION

version 0.4

=head1 SYNOPSIS

  use EPublisher::Target;
  my $Text = EPublisher::Target->new( { type => 'Text' } );
  $Text->deploy;

=head1 METHODS

=head2 deploy

creates the output.

  $Text->deploy;

=head2 testresult

=head1 YAML SPEC

  TextTest:
    source:
      #...
    target:
      type: Text
      output: /path/to/test.txt

=head1 COPYRIGHT & LICENSE

Copyright 2012 Renee Baecker, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms of Artistic License 2.0.

=head1 AUTHOR

Renee Baecker (E<lt>module@renee-baecker.deE<gt>)

=head1 AUTHOR

Renee Baecker <module@renee-baecker.de>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by Renee Baecker.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


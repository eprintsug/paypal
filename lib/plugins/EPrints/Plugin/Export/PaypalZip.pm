package EPrints::Plugin::Export::PaypalZip;

@ISA = ('EPrints::Plugin::Export');

use strict;

sub new
{
	my ($class, %opts) = @_;

	my $self = $class->SUPER::new(%opts);

	$self->{name} = 'Zip';
	$self->{accept} = [ 'dataobj/paypal_order' ];
	$self->{visible} = 'all';
	$self->{suffix} = '.zip';
	$self->{mimetype} = 'application/zip';

	my $rc = EPrints::Utils::require_if_exists('Archive::Any::Create');
	unless ($rc)
	{
		$self->{visible} = '';
		$self->{error} = 'Unable to load required module Archive::Any::Create';
	}

	return $self;
}

sub output_dataobj
{
	my ($plugin, $dataobj ) = @_;

	my $repo = $plugin->{repository};

	my $zip = Archive::Any::Create->new;
	$zip->container( $dataobj->value( "txn_id" ) );

	foreach my $docid ( @{ $dataobj->value( "items_document" ) } )
	{
		my $doc = $repo->dataset( "document" )->dataobj( $docid );
		next unless defined $doc;

		my $file = $doc->stored_file( $doc->value( "main" ) );
		next unless defined $file;

		my $fh = $file->get_local_copy;
		next unless defined $fh;

		my $data = '';
		open( my $dh,'>', \$data );

		while( <$fh> )
		{
			print {$dh} $_;
		}
		close $fh;

		$zip->add_file( sprintf( "%s/%s", $doc->path, $doc->value( "main" ) ), $data );
	}

	my $z = '';
	open( my $FH, '>', \$z );
	$zip->write_filehandle( $FH, 'zip' );
	return $z;
}

1;

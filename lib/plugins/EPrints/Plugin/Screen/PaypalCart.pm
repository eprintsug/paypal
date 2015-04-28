package EPrints::Plugin::Screen::Paypal;

use EPrints::Plugin::Screen;

@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);

	$self->{appears} = [
		{
			place => "key_tools",
			position => 9999,
		}
	];

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	return defined $self->{repository}->current_user;
}

sub render_action_link
{
	my( $self, %opts ) = @_;

	return $self->html_phrase( "btn" );
}

1;

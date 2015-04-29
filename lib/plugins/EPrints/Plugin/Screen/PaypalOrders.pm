package EPrints::Plugin::Screen::PaypalOrders;

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
			position => 350,
		},
		{
			place => "user_actions",
			position => 250,
		}
	];

	return $self;
}

sub can_be_viewed
{
	my( $self ) = @_;

	return defined $self->{repository}->current_user;
}

sub from
{
	my( $self ) = @_;

	my $url = URI->new( $self->{session}->current_url( path => "cgi", "users/home" ) );
	$url->query_form(	
		screen => "Listing",
		dataset => "paypal_order",
		userid => $self->{session}->current_user->id,
	);

	$self->{session}->redirect( $url );
	exit;
}

1;

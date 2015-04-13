
$c->{paypal}->{price} = sub {
	my( $user, $document ) = @_;

	# currency, price (set shipping and tax in paypal)
	return ( "EUR", 5 );
};

# This ID can either be your Secure Merchant ID, which can be found by logging 
# into your PayPal account and visiting your profile, or your email address.
$c->{paypal}->{merchantid} = '';

$c->{plugins}{'Screen::Paypal'}{params}{disable} = 0;
$c->{plugins}{'Screen::EPrint::Box::Paypal'}{params}{disable} = 0;



$c->{paypal}->{price_for_eprint} = sub {
	my( $eprint ) = @_;
	# currency, price, shipping, tax
	return ( "EUR", 5, 0, 0 );
};

# This ID can either be your Secure Merchant ID, which can be found by logging 
# into your PayPal account and visiting your profile, or your email address.
$c->{paypal}->{merchantid} = '';

# On completion of a transaction you can get a payment notification (IPN) on a callback URL
$c->{paypal}->{callback} = $c->{base_url} . '/paypal/callback';

$c->{plugins}{'Screen::Paypal'}{params}{disable} = 0;
$c->{plugins}{'Screen::EPrint::Box::Paypal'}{params}{disable} = 0;


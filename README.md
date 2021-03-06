# Paypal shopping basket

## Installation

In order to install from https://github.com/eprintsug/paypal/ you must have [gitaar](https://github.com/eprintsug/gitaar) up and running on your EPrints.

* cd to your eprints3 base root
* pull in git-hosted package

    ```
    git submodule add https://github.com/eprintsug/paypal.git lib/epm/paypal 
    ```
    use the -f option if you are using the standard eprints installation:
    
    ```
    git submodule add -f https://github.com/eprintsug/paypal.git lib/epm/paypal 
    ```
* generate paypal.epmi

    ```
    gitaar/gitaar build_epmi YOUR_ARCHIVE paypal
    ```
* install paypal.epmi

    ```
    tools/epm link_lib paypal
    ```
* enable paypal.epmi

    ```
    tools/epm enable YOUR_ARCHIVE paypal
    ```
* configure "YOUR_ARCHIVE/cfg/cfg/paypal.pl"
* customize your screen [See next session](#configuration)
* regenerate everything

    ```
    generate_static --prune YOUR_ARCHIVE && generate_abstracts YOUR_ARCHIVE  &&  generate_views YOUR_ARCHIVE && epadmin reload YOUR_ARCHIVE
    ```
* add the new fields to your repository

    ```
    epadmin update YOUR_ARCHIVE
    ```
* restart your webserver
* start selling!

## Setup

Add the IPN callback to your Paypal account: http://your.repository/cgi/paypal/callback

## Configuration
Three files need to be customized. Such modifications depend on the level of customization of your repository. Here we present the situation compared to the originals you can find in ``` lib/defaultcfg ```

### cfg/namedset/security
```perl
# types for document security

public
validuser
staffonly
```

should become
```perl
# types for document security

public
paypal
validuser
staffonly
```

### cfg/citations/eprint/summary_page.xml
Where you want to display your "buy" button
```xml
<epc:if test="$doc.property('security') != 'paypal'">
	<a href="{$doc.url()}" class="ep_document_link"><epc:phrase ref="summary_page:download"/> (<epc:print expr="$doc.doc_size().human_filesize()" />)</a>
</epc:if>
<epc:if test="$doc.property('security') = 'paypal'">
	<div class="paypal-container ep_only_js" data-docid="{$doc.property('docid')}"/>
</epc:if>
```

### cfg/cfg.d/security.pl
Add a section defining paypal roles.
```perl
if( $security eq "paypal" ){
	return "ALLOW" if $doc->repository->call( [qw( paypal can_user_view_document )], $user, $doc );
	return "ALLOW" if defined $doc->repository->call( [qw( paypal get_order_for_document )], $user, $doc );
}
```

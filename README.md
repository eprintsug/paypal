# Paypal shopping basket

## Installation

In order to install from https://github.com/eprintsug/paypal/ you must have [gitaar](https://github.com/eprintsug/gitaar) up and running on your EPrints.

* cd to your eprints3 base root
* pull in git-hosted package

    ```
    git submodule add https://github.com/eprintsug/paypal.git lib/epm/paypal 
    ```
* generate paypal.epmi

    ```
    gitaar/gitaar build_epmi YOUR_ARCHIVE paypal
    ```
* install paypal.epmi

    ```
    tools/epm link_lib paypal
    ```
* configure "YOUR_ARCHIVE/cfg/cfg/paypal.pl"
* customize your screen (See next session)
 
* enable paypal.epmi

    ```
    tools/epm enable YOUR_ARCHIVE paypal
    ```
* start selling!

## Configuration


	--- lib/defaultcfg/namedsets/security	2015-04-08 16:51:22.509117142 +0100
	+++ archives/xxx/cfg/namedsets/security	2015-04-13 19:14:43.969585073 +0100
	@@ -1,5 +1,6 @@
	 # types for document security 
	 
	 public
	+paypal
	 validuser
	 staffonly

	--- lib/defaultcfg/citations/eprint/summary_page.xml	2015-04-08 16:51:22.505117123 +0100
	+++ archives/xxx/cfg/citations/eprint/summary_page.xml	2015-04-13 21:05:44.957255816 +0100
	@@ -33,7 +33,9 @@
		     <td valign="top" align="right"><epc:print expr="$doc.icon('HoverPreview','noNewWindow')}" /></td>
		     <td valign="top">
		       <epc:print expr="$doc.citation('default')" /><br />
	-              <a href="{$doc.url()}" class="ep_document_link"><epc:phrase ref="summary_page:download"/> (<epc:print expr="$doc.doc_size().human_filesize()" />)</a>
	+              <epc:if test="$doc.property('security') != 'paypal'">
	+                <a href="{$doc.url()}" class="ep_document_link"><epc:phrase ref="summary_page:download"/> (<epc:print expr="$doc.doc_size().human_filesize()" />)</a>
	+              </epc:if>
		       <epc:if test="$doc.is_public()">
				  <epc:choose>
				  <epc:when test="$doc.thumbnail_url('video_mp4').is_set()">
	@@ -59,6 +61,9 @@
		       </epc:foreach>
		       </ul>
		     </td>
	+            <epc:if test="$doc.property('security') = 'paypal'">
	+              <td class="paypal-container ep_only_js" data-docid="{$doc.property('docid')}"/>
	+            </epc:if>
		   </tr>
		 </epc:foreach>
	       </table>
	--- lib/defaultcfg/cfg.d/security.pl	2015-04-08 16:51:22.505117123 +0100
	+++ archives/unesco/cfg/cfg.d/security.pl	2015-04-15 20:40:18.181556480 +0100
	@@ -127,6 +127,12 @@
			
		}
	 
	+	if( $security eq "paypal" )
	+	{
	+		return "ALLOW" if $doc->repository->call( [qw( paypal can_user_view_document )], $user, $doc );
	+		return "ALLOW" if defined $doc->repository->call( [qw( paypal get_order_for_document )], $user, $doc );
	+	}
	+
		$doc->repository->log( 
	 "unrecognized user security flag '$security' on document ".$doc->get_id );
		# Unknown security type, be paranoid and deny permission.

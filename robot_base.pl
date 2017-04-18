#!/usr/local/bin/perl -w

#
# This program walks through HTML pages, extracting all the links to other
# text/html pages and then walking those links. Basically the robot performs
# a breadth first search through an HTML directory structure.
#
# All other functionality must be implemented
#
# Example:
#
#    robot_base.pl mylogfile.log content.txt http://www.cs.jhu.edu/
#
# Note: you must use a command line argument of http://some.web.address
#       or else the program will fail with error code 404 (document not
#       found).

use strict;
use warnings;

use Carp;
use HTML::LinkExtor;
use HTTP::Request;
use HTTP::Response;
use HTTP::Status;
use LWP::RobotUA;
use URI::URL;
use WWW::Mechanize; 
use feature 'say';

URI::URL::strict( 1 );   # insure that we only traverse well formed URL's

$| = 1;

my $log_file = "C:/Users/Gitika/Documents/cs466/hw4/log_file2.txt"; #log file kaha pe hai 
my $content_file = "C:/Users/Gitika/Documents/cs466/hw4/content_file2.txt"; # content file kaha pe hai 

#my $log_file = shift (@ARGV);
#my $content_file = shift (@ARGV);

#my $log_file = shift (@ARGV);
#my $content_file = shift (@ARGV);

if ((!defined ($log_file)) || (!defined ($content_file))) { #ye bas check kar rha hai ki log file aur content file exist krte hai ya nhi 
    print STDERR "You must specify a log file, a content file and a base_url\n";
    print STDERR "when running the web robot:\n";
    print STDERR "  ./robot_base.pl mylogfile.log content.txt base_url\n";
    exit (1);
}


open LOG, ">", $log_file; #humne bas basically log file kholi hai isme
open CONTENT, ">", $content_file; #content file kholi hai 

############################################################
##               PLEASE CHANGE THESE DEFAULTS             ##
############################################################

# I don't want to be flamed by web site administrators for
# the lousy behavior of your robots. 

my $ROBOT_NAME = 'gvijhrobot/1.0'; #my robot name
my $ROBOT_MAIL = 'gvijh1@cs.jhu.edu'; #my email id

#
# create an instance of LWP::RobotUA. 
#
# Note: you _must_ include a name and email address during construction 
#       (web site administrators often times want to know who to bitch at 
#       for intrusive bugs).
#
# Note: the LWP::RobotUA delays a set amount of time before contacting a
#       server again. The robot will first contact the base server (www.
#       servername.tag) to retrieve the robots.txt file which tells the
#       robot where it can and can't go. It will then delay. The default 
#       delay is 1 minute (which is what I am using). You can change this 
#       with a call of
#
#         $robot->delay( $ROBOT_DELAY_IN_MINUTES );
#
#       At any rate, if your program seems to be doing nothing, wait for
#       at least 60 seconds (default delay) before concluding that some-
#       thing is wrong.
#

my $robot = new LWP::RobotUA $ROBOT_NAME, $ROBOT_MAIL; #robot banaya hai jisme mera naam aur email id hai 

#my $base_url    = shift(@ARGV);   # the root URL we will start from
my $base_url    ="http://www.cs.jhu.edu";   # the root URL we will start from # base url jis website ko ye visit krega
my @search_urls = ();    # current URL's waiting to be trapsed 
my @wanted_urls = ();    # URL's which contain info that we are looking for
my %relevance   = ();    # how relevant is a particular URL to our search
my %pushed      = ();    # URL's which have either been visited or are already
                         #  on the @search_urls array
    
push @search_urls, $base_url; 

#print "@search_urls\n";
# getting url links

# my $count=0;
# print "$search_urls[0]";
# print "\n";

# my $mech = WWW::Mechanize->new();
# $mech->get( @search_urls );
# my @links = $mech->links();
# for my $link ( @links ) 
# {
	# if ($link->url=~/#/ || $link->url!~/cs.jhu.edu/)
    # {
       # # print "bloop \n"; 
    # }
    # else
    # {
    # #printf "%s, %s\n", $link->text, $link->url;
   # # print "", $link->url;
    # push @search_urls, $link->url; #this will put all the url's to be traversed in @search_urls
    # #print "\n";
    # $count=$count+1;
    
    # }
    # #printf "%s, %s\n", $link->text, $link->url;
# }

# print "$search_urls[1] \n";
# print "$search_urls[2] \n";


##########################################this part works################# 
# my $mech = WWW::Mechanize->new();
# $mech->get( @search_urls );
# my @links = $mech->links();
# for my $link ( @links ) {
	# if ($link->url=~/#/ || $link->url!~/cs.jhu.edu/)
    # {
        # print "bloop \n";
    # }
    # else
    # {
    # #printf "%s, %s\n", $link->text, $link->url;
   # # print "", $link->url;
    # push @search_urls, $link->url; #this will put all the url's to be traversed in @search_urls
    # print "\n";
    # }
    # #printf "%s, %s\n", $link->text, $link->url;
# }
######################################3end of t]part i want#######################


# my $request  = new HTTP::Request 'GET' => $base_url;
# my $response = $robot->request( $request );
# my $html_tree = new HTML::TreeBuilder;
# $html_tree->parse( $response->content );
    
# foreach my $item (@{ $html_tree->extract_links( "a" )}) {

    # my $link = shift @$item;
    # my $furl = (new URI::URL $link)->abs( $response->base );
    # if ($furl=~/#/ || $furl!~/jhu.edu/)
    # {
        # print "bloop \n";
    # }
    # else
    # {
    # print $furl, "\n";
    # }
# }


######count of elements pushed in @search_urls and printing all the elements in the array####
# print "let's see the count of elements";
# print $count; 
# foreach my $n (@search_urls) {
  # say $n;
  # print "\n";
# }
# #say scalar @search_urls;
# print "let's see the first element";
# print "$search_urls[1] \n";
# print "let's see the first element";
################ends here the printing of the elements###################
my $count=0;

while (@search_urls) {

    $count = $count+1;
    my $url = shift @search_urls;
    
    #
    # insure that the URL is well-formed, otherwise skip it
    # if not or something other than HTTP
    #
    
    if ($url =~/cs.jhu.edu/ )
{
    my $parsed_url = eval { new URI::URL $url; };  #eval is parsing the content
    
    
   # print "THIS IS IT .......................................................................................................................................................................";
    #print $parsed_url;

    next if $@;
    
    print $parsed_url->scheme;
    if($parsed_url =~/cs.jhu.edu/)
    {
	   # print "yes this condition works";
    
    next if $parsed_url->scheme !~/http/i;
    #next if $parsed_url =~/cs.jhu.edu/;
    #print "do we have a problem here??";
    
    #next if $parsed_url =~/cs.jhu.edu/;
    #next if $parsed_url->as_string !~/cs.jhu.edu/;  
    
   # next if $parsed_url->scheme !~/cs.jhu.edu/;
   # next if $parsed_url->scheme =~/#/; 
	
    #
    # get header information on URL to see it's status (exis-
    # tant, accessible, etc.) and content type. If the status
    # is not okay or the content type is not what we are 
    # looking for skip the URL and move on
    # 

    print LOG "[HEAD ] $url\n";
    my $request  = new HTTP::Request HEAD => $url;
    my $response = $robot->request( $request );
	
    next if $response->code != RC_OK;
    next if ! &wanted_content( $response->content_type );
    
    

    print LOG "[GET  ] $url\n";
    
    $request->method( 'GET' );
    $response = $robot->request( $request );

    next if $response->code != RC_OK;
    next if $response->content_type !~ m@text/html@;
    
    print LOG "[LINKS] $url\n";

   &extract_content ($response->content, $url);
  
    my @related_urls  = &grab_urls( $response->content );
    #print ".............................................................LETS SEE IF GREP IS WORKING HERE IN RELATED URLS.............................................................";
    #print @related_urls;
    @related_urls = grep { $_ !~/#/} @related_urls;
    @related_urls = grep { $_ =~/cs.jhu.edu/} @related_urls;
    #print ".............................................................LETS SEE IF GREP IS WORKING HERE IN RELATED URLS2.............................................................";
    #print @related_urls;
    
    foreach my $link (@related_urls) {

	my $full_url = eval { (new URI::URL $link, $response->base)->abs; };
	    
	delete $relevance{ $link } and next if $@;

	$relevance{ $full_url } = $relevance{ $link };
	delete $relevance{ $link } if $full_url ne $link;


	push @search_urls, $full_url and $pushed{ $full_url } = 1
	    if ! exists $pushed{ $full_url };
	   
	
    }

    #
    # reorder the urls base upon relevance so that we search
    # areas which seem most relevant to us first.
    #
    @search_urls = grep { $_ !~/#/} @search_urls;
    @search_urls = grep { $_ =~/cs.jhu.edu/} @search_urls;
    @search_urls = sort { $relevance{ $a } <=> $relevance{ $b }; } @search_urls;
    }
    
    if ($count ==1)
    {
    close LOG;
    close CONTENT;
    }
}
}

close LOG;
close CONTENT;

exit (0);
    
#
# wanted_content
#
#    UNIMPLEMENTED
#
#  this function should check to see if the current URL content
#  is something which is either
#
#    a) something we are looking for (e.g. postscript, pdf,
#       plain text, or html). In this case we should save the URL in the
#       @wanted_urls array.
#
#    b) something we can traverse and search for links
#       (this can be just text/html).
#

sub wanted_content {
    my $content = shift;
    # if( $content =~ m@text/html@ || $content =~m@application/postscript@)
    # {
	    # push @wanted_urls, $content;
    
    # print "I came in the loop";
    # print @wanted_urls;
    # return ($content->type);
    # }
    return ($content=~ m@text/html@ || $content =~m@application/postscript@);
}

#
# extract_content
#
#    UNIMPLEMENTED
#
#  this function should read through the context of all the text/html
#  documents retrieved by the web robot and extract three types of
#  contact information described in the assignment
# &extract_content ($response->content, $url);
# sub extract_content {

    # my $content = shift;
    # my $url = shift;

    # my $email;
    # my $phone;
    # my $address;

    # my @email = ( );
    # my @phone = ( );
    # my @address = ( );
     # print $content;
    # # parse out information you want
    # # print it in the tuple format to the CONTENT and LOG files, for example:

    # # Phone extraction
    # @phone = $content =~ m/((1[-| ]?)?\(?(\d{3})\)?[- ]?(\d{3})[-](\d{4}))/g; 

    # print @phone;
    # foreach my $index (@phone) {    
        # $phone = $1;
        # print CONTENT "($url; PHONE; $phone)\n";
        # print LOG "($url; PHONE; $phone)\n";
    # }

    # # Email extraction
    # @email = $content =~ m/([-A-z0-9.]+@[-A-z0-9.]+)/g;
    # foreach my $index (@email) {   
        # $email = $1;
        # print CONTENT "($url; EMAIL; $email)\n";
        # print LOG "($url; EMAIL; $email)\n";
    # }

    # # Mail address extraction
    # @address = $content =~ m/([A-Za-z\s]*,\s*(\w{2})\s*(\d{5}(?:-\d{4})?))/g;
    # foreach my $index (@address) {
        # $address = $1;
        # print CONTENT "($url; CITY; $address)\n";
        # print LOG "($url; CITY; $address)\n";
    # }

# }



sub extract_content {
    my $content = shift;
    my $url = shift;
    my @email =();
    my @phone=();
  
    
  
    
    
   #print ".............................................................LETS SEE IF GREP IS WORKING HERE IN RELATED URLS.............................................................";
   # @email = $content =~ m/^[a-z0-9.]+\@[a-z0-9.-]+$/g;
    
    #@email = $content =~ /([a-z0-9][-a-z0-9_\+\.]*[a-z0-9])@([a-z0-9][-a-z0-9\.]*[a-z0-9]\.(arpa|root|aero|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)|([0-9]{1,3}\.{3}[0-9]{1,3}))/g;
   # @email = $content =~ m/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}/g;
   
    
    #@email = $content =~ m/([-A-z0-9.]+@[-A-z0-9.]+\.(arpa|root|aero|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw))/g;
    #@email = $content =~ m/^([-A-z0-9.]+@[-A-z0-9.]+\.(arpa|root|aero|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|um|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw))/g;
    @email = $content =~ m/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}/g;
     @email = grep { $_ !~/.png/} @email;
     @email = grep { $_ !~/.jpeg/} @email;
     @email = grep { $_ !~/.gif/} @email;
     foreach (@email) {
	   
	# print "\nEmail: ";
	# my $email = $1;
	# print $email; 
	
	#print CONTENT "($url; EMAIL; $_)\n";
	#print LOG "($url; EMAIL; $_)\n";
    }
    # foreach my $value (@email) {
	   
	# print "\nEmail: ";
	# my $email = $1;
	# print $email; 
	# print CONTENT "($url; EMAIL; $email)\n";
	# print LOG "($url; EMAIL; $email)\n";
    # }

    #@phone = $content =~ m/^(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}$/g;
    @phone = $content =~ /((1[-| ]?)?\(?(\d{3})\)?[- ]?(\d{3})[-](\d{4}))/g;
    foreach my $value (@phone) {
	   
	#print "\nPhone: ";
	my $phone = $1;
	#print CONTENT "($url; Phone; $phone)\n";
	#print LOG "($url; Phone; $phone)\n";
    }  
    
    # print CONTENT $content;
    
    # #@address = $content =~ m/([A-Za-z\s]*,\s*(\w{2})\s*(\d{5}(?:-\d{4})?))/g;
   # # @address = $content =~ /([A-Za-z]+(?: [A-Za-z]+){0,2},\s(?:(?:\w{2})|[A-Za-z]+\.)\s(?:\d{5}(?:-\d{4})?))/g;
   # my @address = ($content =~ /([A-Za-z]+(?: [A-Za-z]+){0,2},\s(?:(?:\w{2})|[A-Za-z]+\.)\s(?:\d{5}(?:-\d{4})?))/g );
    # #@address = $content =~ /([A-Za-z]+(?: [A-Za-z]+){0,2},\s(?:(?:\w{2})|[A-Za-z]+\.)\s(?:\d{5}(?:-\d{4})?))/g;
    # print LOG @address;
    # foreach (@address) {
	   
	# # print "\nEmail: ";
	# # my $email = $1;
	# # print $email; 
	# print CONTENT "($url; ADDRESS; $_)\n";
	# print LOG "($url; ADDRESS; $_)\n";
    # }
    
    my $address;
    while ($content =~ s/([A-Za-z]+,{0,1}\s[A-Za-z]+,{0,1}\s\d{5}(.\d{4}){0,1})//)
	{
		$address = $1;
		print CONTENT "($url; ADDRESS; $address)\n";
		print LOG "($url; ADDRESS; $address)\n";
		print "ADDRESS: ", $address, "\n";
	}
    
    # foreach my $value (@address) {
	   
	# print "\nAddress: ";
	# my $address = $1;
	# print CONTENT "($url; Address; $address)\n";
	# print LOG "($url; Address; $address)\n";
    # }  
	  
    # print "\nEmail: ";
    # print $email;
    # print CONTENT "($url; EMAIL; $email)\n";
    # print LOG "($url; EMAIL; $email)\n";
    # print "Phone: ";
    # print $phone;
    # print CONTENT "($url; PHONE; $phone)\n";
    # print LOG "($url; PHONE; $phone)\n";

    return;
}

#
# grab_urls
#
#    PARTIALLY IMPLEMENTED
#
#   this function parses through the content of a passed HTML page and
#   picks out all links and any immediately related text.
#
#   Example:
#
#     given 
#
#       <a href="somepage.html">This is some web page</a>
#
#     the link "somepage.html" and related text "This is some web page"
#     will be parsed out. However, given
#
#       <a href="anotherpage.html"><img src="image.jpg">
#
#       Further text which does not relate to the link . . .
# 
#     the link "anotherpage.html" will be parse out but the text "Further
#     text which . . . " will be ignored.
#
#   Relevancy based on both the link itself and the related text should
#   be calculated and stored in the %relevance hash
#
#   Example:
#
#      $relevance{ $link } = &your_relevance_method( $link, $text );
#
#   Currently _no_ relevance calculations are made and each link is 
#   given a relevance value of 1.
#

sub grab_urls {
    my $content = shift;
    my %urls    = ();    # NOTE: this is an associative array so that we only
                         #       push the same "href" value once.

    
  skip:
    while ($content =~ s/<\s*[aA] ([^>]*)>\s*(?:<[^>]*>)*(?:([^<]*)(?:<[^aA>]*>)*<\/\s*[aA]\s*>)?//) {
	    
	my $tag_text = $1;
	my $reg_text = $2;
	my $link = "";

	if (defined $reg_text) {
	    $reg_text =~ s/[\n\r]/ /;
	    $reg_text =~ s/\s{2,}/ /;
	    
	    

	    #
	    # compute some relevancy function here
	    #
	}

	if ($tag_text =~ /href\s*=\s*(?:["']([^"']*)["']|([^\s])*)/i) {
	    $link = $1 || $2;

	    #
	    # okay, the same link may occur more than once in a
	    # document, but currently I only consider the last
	    # instance of a particular link
	    #

	    $relevance{ $link } = 1;
	    $urls{ $link }      = 1;
	}

	print $reg_text, "\n" if defined $reg_text;
	print $link, "\n\n";
    }

    return keys %urls;   # the keys of the associative array hold all the
                         # links we've found (no repeats).
}

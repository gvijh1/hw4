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
# use WWW::Mechanize; 
use feature 'say';

URI::URL::strict( 1 );   # insure that we only traverse well formed URL's

$| = 1;

my $log_file = 'C:/Users/Gitika/Documents/cs466/hw4/log_file2.txt';
my $content_file = 'C:/Users/Gitika/Documents/cs466/hw4/content_file2.txt';
print 'Printing in ',$log_file;
print "\n";
print 'Printing in ',$content_file,"\n";
print "\n";



# if ((!defined ($log_file)) || (!defined ($content_file))) { 
#     print STDERR "You must specify a log file, a content file and a base_url\n";
#     print STDERR "when running the web robot:\n";
#     print STDERR "  ./robot_base.pl mylogfile.log content.txt base_url\n";
#     exit (1);
# }

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
$robot -> delay( 2/60 );
my $base_url    = 'http://www.cs.jhu.edu';   # the root URL we will start from
my @search_urls = ();    # current URL's waiting to be trapsed 
my @wanted_urls = ();    # URL's which contain info that we are looking for
my %relevance   = ();    # how relevant is a particular URL to our search
my %pushed      = ();    # URL's which have either been visited or are already
                         #  on the @search_urls array
    
push @search_urls, $base_url; 

my $count=0;

while (@search_urls) {

    $count = $count+1;
    my $url = shift @search_urls;
    if ($url =~/cs.jhu.edu/ )
    {
        my $parsed_url = eval { new URI::URL $url; };  #eval is parsing the content
        
        next if $@;

        if($parsed_url =~/cs.jhu.edu/)
        {
        
            next if $parsed_url->scheme !~/http/i;

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
          
            @related_urls = grep { $_ !~/#/} @related_urls;
            @related_urls = grep { $_ =~/cs.jhu.edu/} @related_urls;
          
            
            foreach my $link (@related_urls) {

        	my $full_url = eval { (new URI::URL $link, $response->base)->abs; };
        	    
        	delete $relevance{ $link } and next if $@;

        	$relevance{ $full_url } = $relevance{ $link };
        	delete $relevance{ $link } if $full_url ne $link;


        	push @search_urls, $full_url and $pushed{ $full_url } = 1
        	    if ! exists $pushed{ $full_url };
        	   
        	
            }

            @search_urls = grep { $_ !~/#/} @search_urls;
            @search_urls = grep { $_ =~/cs.jhu.edu/} @search_urls;
            @search_urls = sort { $relevance{ $a } <=> $relevance{ $b }; } @search_urls;
        }
    }
}

print 'Closing log files at the end';
close LOG;
close CONTENT;
exit (0);
    

sub wanted_content {
    my $content = shift;
    if ($content=~ m@text/html@ || $content =~m@application/postscript@)
    {
    	push @wanted_urls, $content;
    }
    return ($content=~ m@text/html@ || $content =~m@application/postscript@);
}


sub extract_content {
    my $content = shift;
    my $url = shift;
    
    my @emails =();
    my @phones =();


    # Detects Emails
    @emails = $content =~ m/[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}/g;
    @emails = grep { $_ !~/.png/} @emails;
    @emails = grep { $_ !~/.jpeg/} @emails;
    @emails = grep { $_ !~/.gif/} @emails;

    for my $email (@emails)
    {
        print "$url Email $email\n";
        print CONTENT "($url; EMAIL; $email)\n";
        print LOG "($url; EMAIL; $email)\n";
    }
    
    # Detects Phones
    @phones = $content =~ /((1[-| ]?)?\(?(\d{3})\)?[- ]?(\d{3})[-](\d{4}))/g;
    foreach my $value (@phones) {
    	my $phone = $1;
        print CONTENT "($url; PHONE; $phone)\n";
        print LOG "($url; PHONE; $phone)\n";
        print "$url Phone: ", $phone, "\n";
    }

    # Detects Addresses
    my $addresses;
    while ($content =~ s/([A-Za-z]+,{0,1}\s[A-Za-z]+,{0,1}\s\d{5}(.\d{4}){0,1})//)
	{
		$addresses = $1;
		print CONTENT "($url; ADDRESS; $addresses)\n";
		print LOG "($url; ADDRESS; $addresses)\n";
		print "$url ADDRESS: ", $addresses, "\n";
	}
    return;
}

sub grab_urls 
{
	my $content = shift;
	my %urls    = ();		# NOTE: this is an associative array so that we only
					# push the same "href" value once.

	skip:

	while ($content =~ s/<\s*[aA] ([^>]*)>\s*(?:<[^>]*>)*(?:([^<]*)(?:<[^aA>]*>)*<\/\s*[aA]\s*>)?//) 
	{
		my $tag_text = $1;
		my $reg_text = $2;

		if (defined $reg_text) 
		{
			$reg_text =~ s/[\n\r]/ /;
			$reg_text =~ s/\s{2,}/ /;
		}

		my $link = "";
		$reg_text = "" if (!defined $reg_text);

		if ($tag_text =~ /href\s*=\s*(?:["']([^"']*)["']|([^\s])*)/i) 
		{
			$link = $1 || $2;
			$link = "" if (!defined $link);


			$relevance{ $link } = &compute_relevance( $link, $reg_text );
			$urls{ $link }      = 1;
		}

		# print $reg_text, "\n" if defined $reg_text;
		# print $link, "\n";
	}

	return keys %urls;	
			
}

# compute_relevance

sub compute_relevance
{
	my $link = shift;
	my $text = shift;
	if ($link =~ /~\w+$/)
	{ 
		return 1; 
	}
	if ($link =~ /research/)
	{ 
		return 2; 
	}
	if ($link =~ /undergraduate-studies/)
	{ 
		return 3; 
	}
	if ($link =~ /graduate-studies/)
	{ 
		return 4; 
		}
	if ($link =~ /people/)
	{ 
		return 5; 
		}
	if ($link =~ /news-events/)
	{ 
		return 6; 
		}
	if ($link =~ /alumni-giving/)
	{ 
		return 7; 
		}
	if ($link =~ /adminsupport/)
	{ 
		return 8; 
		}
	return 9;
}

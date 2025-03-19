#!/usr/bin/perl
#
# bandwidth consumption
#
use strict;
use warnings;

use JSON;

my %hash;
my ($since, $ds_day, $us_day, $total_day, $ds_month, $us_month, $total_month, $ds_total, $us_total);
# Total consumption per day and month
my $consum = `vnstat --oneline`;

if ($consum =~ /s0\;(.*?)\;(.*?)\;(.*?)\;(.*?)\;.*?\;.*?\;(.*?)\;(.*?)\;(.*?)\;(.*?)\;(.*?)\;(.*?)\;/g) {
  $since = $1;
  $ds_day = $2;
  $us_day = $3;
  $total_day = $4;
  $ds_month = $5;
  $us_month = $6;
  $total_month = $7;
  $ds_total = $10;
  $us_total = $9;
}

# convert GiB and MiB to GB and MB
$us_day =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$ds_day =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$total_day =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$us_month =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$ds_month =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$total_month =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$ds_total =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;
$us_total =~ s/(\d+\.\d)\d\s(\w)iB/$1 $2B/;

$hash{'bw_us_day'} = $us_day;
$hash{'bw_ds_day'} = $ds_day;
$hash{'bw_us_month'} = $us_month;
$hash{'bw_ds_month'} = $ds_month;
$hash{'bw_us_all_time'} = $us_total;
$hash{'bw_ds_all_time'} = $ds_total;

# current bandwidth month
my $day = `date \"+month: \%d \%B\" | awk \'{print \$2}\'`;
my $month = `date \"+month: \%d \%B\" | awk \'{print \$3}\'`;
chomp ($day,$month);
$hash{'day'} = $day;
$hash{'month'} = $month;

my $json = JSON->new->utf8->pretty(1)->encode (\%hash);
print "Content-type:application/json\r\n\r\n";
print $json;

1;

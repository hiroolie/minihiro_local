#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX qw/strftime/;
use Fcntl qw/:flock :seek/;

# �����̏���
# my $file = shift;
my $repoList = "E:/Develop/Scripts/conf/repository_list.txt";

unless( $repoList ){
    die "Usage: $0 Needs Repository List (reponame,revision)"; # �������Ȃ��Ƃ��́A�g�p���@�������ďI���B
}

# �t�@�C������͂���csv�`���̃f�[�^��z��̔z��ɕϊ��B
my @recs = parse_file( $repoList );

#CSV�t�@�C���o��(�J���Ƃ��Ƀt�@�C���T�C�Y��0�ɂ���)
open my $LOG, "+>", $repoList or die $!;
# �o��( 2�����z��Ȃ̂ŁAforeach�ł��ǂ� )
foreach my $items ( @recs ){
    print join( ',', @{ $items } ), "\n"; # �J���}�ŘA�����ďo�́B

    #yyyy-mm-dd hh:mm:ss�`���̌��ݎ��Ԃ��擾
    my @now = localtime();
    my $logtime = strftime "%Y-%m-%d %H:%M:%S", @now;
    
    my $csvdate = join(',', @{ $items } , $logtime ) . "\n";

    flock $LOG, LOCK_EX;
    seek $LOG, 0, SEEK_END;
    print $LOG $csvdate;
    flock $LOG, LOCK_UN;

}
close $LOG;

sub parse_file{

    my $first_rev = "";
    my $last_rev = "";
    my $backups_dir = "D:/Users/hiRo/Documents/My Dropbox/Backup/repository";
    my $repository_dir = "E:/Deployment/Repositories";
    my $svn_bin = '"E:/Deployment/VisualSVN Server/bin"';
    my $svnadmin_cmd = "E:/Deployment/VisualSVN Server/bin/svnadmin.exe";

    open( my $fh, "<", $repoList )
        or die "Cannot open $repoList for read: $!";

    my @recs; # �z��ɕύX
    while( my $line = <$fh> ){

        chomp $line; # ���s����菜��

        my @items; # �z��ɕύX
        @items= split( /,/, $line );

        my $target = $items[0];
        my $previous_youngest = $items[1];
        my $youngest = `$svn_bin/svnlook.exe youngest $repository_dir/$target`;
        chomp $youngest;

        if($youngest eq $previous_youngest) {
            print "No new revisions to back up for $target. \n";
        } else {
          my $next_backup_file = $target . "_" . $previous_youngest . "to" . $youngest . ".dump";
          
          print "Back up Repository for $target revisions $previous_youngest to $youngest... \n";
          
          my $svndump_cmd = "\"" . "$svnadmin_cmd". "\"" . " dump --incremental " .
                          "--revision $previous_youngest:$youngest " .
                          "$repository_dir/$target > \"$backups_dir/$target/$next_backup_file\"";
                          
          `$svndump_cmd`;
        }
        $items[1] = $youngest;
        push @recs, [ @items ]; # push����Ƃ��ɁA[ ]�Ń��t�@�����X���쐬�B 
    }
    close $fh;
    return @recs; 
}


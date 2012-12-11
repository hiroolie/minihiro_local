#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX qw/strftime/;
use Fcntl qw/:flock :seek/;

# 引数の処理
# my $file = shift;
my $repoList = "E:/Develop/Scripts/conf/repository_list.txt";

unless( $repoList ){
    die "Usage: $0 Needs Repository List (reponame,revision)"; # 引数がないときは、使用方法を示して終了。
}

# ファイルを解析してcsv形式のデータを配列の配列に変換。
my @recs = parse_file( $repoList );

#CSVファイル出力(開くときにファイルサイズを0にする)
open my $LOG, "+>", $repoList or die $!;
# 出力( 2次元配列なので、foreachでたどる )
foreach my $items ( @recs ){
    print join( ',', @{ $items } ), "\n"; # カンマで連結して出力。

    #yyyy-mm-dd hh:mm:ss形式の現在時間を取得
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

    my @recs; # 配列に変更
    while( my $line = <$fh> ){

        chomp $line; # 改行を取り除く

        my @items; # 配列に変更
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
        push @recs, [ @items ]; # pushするときに、[ ]でリファレンスを作成。 
    }
    close $fh;
    return @recs; 
}


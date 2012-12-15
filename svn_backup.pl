#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX qw/strftime/;
use Fcntl qw/:flock :seek/;
use Time::Local;

# 引数の処理
# my $repoList = shift;
my $repoList = "E:/Develop/Scripts/conf/repository_list.txt";

unless( $repoList ){
    die "Usage: $0 Needs Repository List (reponame,revision) \n"; # 引数がないときは、使用方法を示して終了。
}

# 変数を定義する。
my $backups_dir = "D:/Users/hiRo/Documents/My Dropbox/Backup/repository";  # バックアップ先ディレクトリ
my $repository_dir = "E:/Repositories";                         # リポジトリの場所
my $svn_bin =      "D:/ProgramFilesD/VisualSVN Server/bin";                      # svnコマンドの場所
my $svnadmin_cmd = "D:/ProgramFilesD/VisualSVN Server/bin/svnadmin.exe";      # 空白の関係で面倒だが別変数に格納しておく

# 曜日によって実行する処理を振り分ける。
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
print "WDAY:" . $wday;

# ファイルを解析してcsv形式のデータを配列の配列に変換。
# 実処理はサブルーチン
my @recs = parse_conf( $repoList );

# 返ってきた配列を元のファイルに出力
# (開くときにファイルサイズを0にする)
open my $LOG, "+>", $repoList or die $!;

# 出力( 戻り値は2次元配列なので、foreachでたどる )
foreach my $items ( @recs ){
    print join( ',', @{ $items } ), "\n"; # カンマで連結して出力。

    #yyyy-mm-dd hh:mm:ss形式の現在時間を取得
    my @now = localtime();
    my $logtime = strftime "%Y-%m-%d %H:%M:%S", @now;
    
    # csvデータの最後にバックアップした時間を付け加える
    my $csvdate = join(',', @{ $items } , $logtime ) . "\n";
    
    # 排他制御でファイルが壊れるのを防ぐ
    flock $LOG, LOCK_EX;
    seek $LOG, 0, SEEK_END;
    print $LOG $csvdate;
    flock $LOG, LOCK_UN;

}
close $LOG;


# ファイルを解析してcsv形式のデータを配列の配列に変換。
sub parse_conf{

    # 引数(CSVファイル)が開けなかったらエラー終了
    open( my $confHandle, "<", $repoList )
        or die "Cannot open $repoList for read: $!";

    my @recs; # 使用する配列を宣言
    
    # CSVデータを読み取って1行ずつ処理実行
    while( my $line = <$confHandle> ){

        chomp $line; # 改行を取り除く

        my @items; # 配列に変更
        @items = split( /,/, $line );
        
        # 配列の最後の要素(前回バックアップ時間)を削除
        pop @items ;

        # 配列の一列目はリポジトリの名前
        my $target = $items[0];
        # 配列の二列目は前回バックアップしたリビジョン
        my $previous_youngest = $items[1];
        
        # 処理中のリポジトリのリビジョンを調べる
        my $youngest = `$svn_bin/svnlook.exe youngest $repository_dir/$target`;
        chomp $youngest;
        
        my $next_backup_file ="";
        my $svndump_cmd = "";
        
        if ( $wday eq 0 ) {
            # 日曜ならフルバック用のコマンドを作る
            $next_backup_file = $target . "_0" . "to" . $youngest . ".dump";
            $svndump_cmd = "\"" . "$svnadmin_cmd". "\"" . " dump " .
                "$repository_dir/$target > \"$backups_dir/$target/$next_backup_file\"";
                
            # 後の処理でコマンドを実行させたいので
            # 前回バックアップリビジョン数を0に見せておく。
            $previous_youngest = 0;
            
        } else {
            # 平日なら増分バックアップ用のコマンドを作る
             $next_backup_file = $target . "_" . $previous_youngest . "to" . $youngest . ".dump";
             $svndump_cmd = "\"" . "$svnadmin_cmd". "\"" . " dump --incremental " .
                  "--revision $previous_youngest:$youngest " .
                  "$repository_dir/$target > \"$backups_dir/$target/$next_backup_file\"";
                  
        }
        
        if( $previous_youngest eq $youngest ) {
            # 前回バックアップしたリビジョンと変わらなければバックアップしない。
            print "No new revisions to back up for $target. \n";
            
        } else {
            # 前回バックアップしたリビジョンと変化があればバックアップ実行
            print "Back up Repository for $target revisions $previous_youngest to $youngest. \n";
            
            # print "CMD:" . $svndump_cmd;
            `$svndump_cmd`; # 作ったコマンドをOSで実行
            
            $items[1] = $youngest; # 前回バックアップリビジョンを更新
        }
        push @recs, [ @items ]; # pushするときに、[ ]でリファレンスを作成。 
    }
    close $confHandle;
    return @recs; 
}
#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX qw/strftime/;
use Fcntl qw/:flock :seek/;

# 引数の処理
my $repoList = shift;
# my $repoList = "E:/Develop/Scripts/conf/repository_list.txt";

unless( $repoList ){
    die "Usage: $0 Needs Repository List (reponame,revision) \n"; # 引数がないときは、使用方法を示して終了。
}

# 変数を定義する。
my $backups_dir = "D:/Users/hiRo/Documents/My Dropbox/Backup/repository";  # バックアップ先ディレクトリ
my $repository_dir = "E:/Deployment/Repositories";                         # リポジトリの場所
my $svn_bin = '"E:/Deployment/VisualSVN Server/bin"';                      # svnコマンドの場所
my $svnadmin_cmd = "E:/Deployment/VisualSVN Server/bin/svnadmin.exe";      # 空白の関係で面倒だが別変数に格納しておく

# ファイルを解析してcsv形式のデータを配列の配列に変換。
# 実処理はサブルーチン
my @recs = parse_file( $repoList );

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
sub parse_file{

    # 引数(CSVファイル)が開けなかったらエラー終了
    open( my $confHandle, "<", $repoList )
        or die "Cannot open $repoList for read: $!";

    my @recs; # 使用する配列を宣言
    while( my $line = <$confHandle> ){

        chomp $line; # 改行を取り除く

        my @items; # 配列に変更
        @items= split( /,/, $line );

        # 配列の一列目はリポジトリの名前
        my $target = $items[0];
        # 配列の二列目は前回バックアップしたリビジョン
        my $previous_youngest = $items[1];
        
        # 処理中のリポジトリのリビジョンを調べる
        my $youngest = `$svn_bin/svnlook.exe youngest $repository_dir/$target`;
        chomp $youngest;

        if($youngest eq $previous_youngest) {
            # 前回バックアップしたリビジョンと変わらなければバックアップしない。
            print "No new revisions to back up for $target. \n";
            
        } else {
          # 前回バックアップしたリビジョンと変化があればバックアップ実行
          print "Back up Repository for $target revisions $previous_youngest to $youngest... \n";
          

                          
          `$svndump_cmd`; # 作ったコマンドをOSで実行
          $items[1] = $youngest; # 前回バックアップリビジョンを更新
        }
        push @recs, [ @items ]; # pushするときに、[ ]でリファレンスを作成。 
    }
    # ファイルハンドルを閉じて2次元配列の結果を戻す
    close $confHandle;
    return @recs; 
}
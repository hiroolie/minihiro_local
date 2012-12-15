#!/usr/bin/perl -w

use strict;
use warnings;
use POSIX qw/strftime/;
use Fcntl qw/:flock :seek/;

# �����̏���
my $repoList = shift;
# my $repoList = "E:/Develop/Scripts/conf/repository_list.txt";

unless( $repoList ){
    die "Usage: $0 Needs Repository List (reponame,revision) \n"; # �������Ȃ��Ƃ��́A�g�p���@�������ďI���B
}

# �ϐ����`����B
my $backups_dir = "D:/Users/hiRo/Documents/My Dropbox/Backup/repository";  # �o�b�N�A�b�v��f�B���N�g��
my $repository_dir = "E:/Deployment/Repositories";                         # ���|�W�g���̏ꏊ
my $svn_bin = '"E:/Deployment/VisualSVN Server/bin"';                      # svn�R�}���h�̏ꏊ
my $svnadmin_cmd = "E:/Deployment/VisualSVN Server/bin/svnadmin.exe";      # �󔒂̊֌W�Ŗʓ|�����ʕϐ��Ɋi�[���Ă���

# �t�@�C������͂���csv�`���̃f�[�^��z��̔z��ɕϊ��B
# �������̓T�u���[�`��
my @recs = parse_file( $repoList );

# �Ԃ��Ă����z������̃t�@�C���ɏo��
# (�J���Ƃ��Ƀt�@�C���T�C�Y��0�ɂ���)
open my $LOG, "+>", $repoList or die $!;

# �o��( �߂�l��2�����z��Ȃ̂ŁAforeach�ł��ǂ� )
foreach my $items ( @recs ){
    print join( ',', @{ $items } ), "\n"; # �J���}�ŘA�����ďo�́B

    #yyyy-mm-dd hh:mm:ss�`���̌��ݎ��Ԃ��擾
    my @now = localtime();
    my $logtime = strftime "%Y-%m-%d %H:%M:%S", @now;
    
    # csv�f�[�^�̍Ō�Ƀo�b�N�A�b�v�������Ԃ�t��������
    my $csvdate = join(',', @{ $items } , $logtime ) . "\n";
    
    # �r������Ńt�@�C��������̂�h��
    flock $LOG, LOCK_EX;
    seek $LOG, 0, SEEK_END;
    print $LOG $csvdate;
    flock $LOG, LOCK_UN;

}
close $LOG;

# �t�@�C������͂���csv�`���̃f�[�^��z��̔z��ɕϊ��B
sub parse_file{

    # ����(CSV�t�@�C��)���J���Ȃ�������G���[�I��
    open( my $confHandle, "<", $repoList )
        or die "Cannot open $repoList for read: $!";

    my @recs; # �g�p����z���錾
    while( my $line = <$confHandle> ){

        chomp $line; # ���s����菜��

        my @items; # �z��ɕύX
        @items= split( /,/, $line );

        # �z��̈��ڂ̓��|�W�g���̖��O
        my $target = $items[0];
        # �z��̓��ڂ͑O��o�b�N�A�b�v�������r�W����
        my $previous_youngest = $items[1];
        
        # �������̃��|�W�g���̃��r�W�����𒲂ׂ�
        my $youngest = `$svn_bin/svnlook.exe youngest $repository_dir/$target`;
        chomp $youngest;

        if($youngest eq $previous_youngest) {
            # �O��o�b�N�A�b�v�������r�W�����ƕς��Ȃ���΃o�b�N�A�b�v���Ȃ��B
            print "No new revisions to back up for $target. \n";
            
        } else {
          # �O��o�b�N�A�b�v�������r�W�����ƕω�������΃o�b�N�A�b�v���s
          print "Back up Repository for $target revisions $previous_youngest to $youngest... \n";
          

                          
          `$svndump_cmd`; # ������R�}���h��OS�Ŏ��s
          $items[1] = $youngest; # �O��o�b�N�A�b�v���r�W�������X�V
        }
        push @recs, [ @items ]; # push����Ƃ��ɁA[ ]�Ń��t�@�����X���쐬�B 
    }
    # �t�@�C���n���h�������2�����z��̌��ʂ�߂�
    close $confHandle;
    return @recs; 
}
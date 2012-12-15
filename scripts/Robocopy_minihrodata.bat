@echo off

robocopy "Z:\dbdata" "D:\Users\hiRo\Documents\My Dropbox\Backup\bkupdir\dbdata" /NP /mir /LOG:"E:\Develop\Scripts\log\minihirobackup\dbdata.log"
robocopy "Z:\webdata" "D:\Users\hiRo\Documents\My Dropbox\Backup\bkupdir\webdata" /NP /mir /LOG:"E:\Develop\Scripts\log\minihirobackup\webdata.log"

exit
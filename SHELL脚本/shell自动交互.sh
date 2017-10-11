#!/usr/bin/env expect
set timeout 30 
set GITUSER "TSKY.hu.qiu"
set SERVER_IP "192.168.2.250"
set passwd "huq1u"
cd /app
#echo "OJDP  git clone end##############"
spawn git clone ssh://$GITUSER@$SERVER_IP/data/git/IBE.git
#expect "Password:"  
expect {
     "(yes/no)?" {send "yes\r";exp_continue}
      "Password:" {exp_send "$passwd\r"}
}
#send "huq1u\r"
interact

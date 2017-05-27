#!/usr/bin/expect

set path http://ec2-52-221-25-114.ap-southeast-1.compute.amazonaws.com/tradingplatformserver/alphadeploy.git
set name [lindex $argv 0]
set ip 192.168.10.200
set local_user tim
set local_password tim
set g_name tim
set g_password tsx,871024

spawn ssh $local_user@$ip
    #expect "Are you sure you want to continue connecting (yes/no)?"
    #send "yes\r"
    expect "*password:"
    send "$local_password\r"
    expect "*#"
    #send "cd /home/tim/alphadeploy/tradingengine00\r"
	send "cd $name\r"
    send "git config --global user.email tim@1stellar.com\r"
    send "git config --global user.name tim\r"
    send "git status\r";
    send "git add *\r";
    send "git commit -m 'update'\r"
 #   expect "Username*"
 #   send "$g_name\r"
 #   expect "Password*"
 #   send "$g_password\r"
    send "git push origin master\r"
 #   expect "Username*"
 #   send "$g_name\r"
 #   expect "Password*"
 #   send "$g_password\r"
    send "exit\r";
    expect eof


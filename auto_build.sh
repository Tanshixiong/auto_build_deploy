#!/usr/bin/env bash
source push_git.sh

# Define variables
define_var (){
    echo "******************************step: define variables******************************"
    #module_name=$JOB_NAME
    module_name=$m_name
    path=/root/.jenkins/workspace/$module_name
    compiler_ip=192.168.10.200
    user=tim
    password=tim
    auto_path=/home/auto
   # remote_path="/home/$user/source"
    bak_path="/home/$user/bak"
    te_git_path="/home/$user/alphadeploy/tradingengine00"
    se_git_path="/home/$user/alphadeploy/signalengine"
}

#check variables
check_variables(){
    echo "******************************step: check variables******************************"
    echo "[value:module_name]"$module_name
    echo "[value:compiler_ip]"$compiler_ip
    echo "[value:user]"$user
    echo "[value:auto_path]"$auto_path
    echo "[value:remote_path]"$remote_path
}

#Backup source file
backup_file(){
     echo "******************************step: bakup_file ******************************"
     /usr/bin/sshpass -p $password  ssh -o StrictHostKeyChecking=no $user@${compiler_ip} 2> /dev/null <<@
        cd $remote_path
        cd ../
        echo "[info] current dir is:";pwd
        if [ ! -x $bak_path ]; then
            echo "[info] /home/tim/bak not exist,start create..."
            mkdir $bak_path
            tar czf $bak_path/$module_name_$(date +%Y%m%d-%H%M).tar.gz $remote_path
            [[ $? -eq 0 ]] && echo "[info] backup success!" || exit -1
        else
            echo "[info] /home/tim/bak exist,start backup...."
            tar czf $bak_path/$module_$(date +%Y%m%d-%H%M).tar.gz $remote_path
            [[ $? -eq 0 ]] && echo "[info] backup success!" || exit -1
        fi
        echo "backup end"
@

}
#delete old files
remove_old_module_files(){
    echo "******************************step: remove_old_module_files******************************"
    /usr/bin/sshpass -p $password  ssh -o StrictHostKeyChecking=no $user@${compiler_ip} 2> /dev/null <<@
        if [ ! -x $remote_path ];then
            echo "[error]" $remote_path "is not exist"
            exit -1
        else
            cd $remote_path
            echo "[info] current dir is:"; pwd
            if [ ! -d $module_name ]; then
                echo ["error]" $module_name "is not exit"
                exit 1
            else
                echo "[info] begin to remove" $module_name
                rm -rf ${module_name}
                [[ $? == 0 ]] && echo "[info]delete old module files success!" || exit -1
            fi
        fi
@
}

#Copy the code to the compiler
copy_code_to_compiler(){
    echo "******************************step: copy_code_to_compiler******************************"
    cd  $path
    rm -rf $path/.git
    scp -r $path ${user}@${compiler_ip}:${remote_path}
    if [ $? -eq 0 ];
    then
        echo "[info] copy code to compiler success"
    else
        echo "[error:] copy code to compiler failed"
        exit -1
    fi
}

#start compile on remote compiler
exec_compiler(){
    echo "******************************step: exec_compiler******************************"
    cd ${auto_path}
    /usr/bin/sshpass -p $password  ssh -o StrictHostKeyChecking=no $user@${compiler_ip}<<EOF
        cd ${remote_path}
		echo "[info]"$remote_path
		echo "[info]"$module_name
        case $module_name in
           "tradingengine")
                ls
                cp xservice/xlogger.h $module_name/include/
                [[ $? == 0 ]] && echo "[info]copy xlogger.h success" || exit -1
                cp -rf lib $module_name
                [[ $? == 0 ]] && echo "[info]copy lib success" || exit -1

                cd $module_name
                [[ $? == 0 ]] && echo "[info] change dir success" || echo "failed"
                ;;
           "signalengine")
                cd $module_name
                ls
                ;;
            *)
                echo "m_name is wrong!"
            ;;
            esac


        echo "***********************start build*************************************"
        cmake .
        [[ $? == 0 ]] && echo "[info] cmake success" || exit -1
        make
        [[ $? == 0 ]] && echo "[info] make success" || exit -1

        echo "end"
EOF
}

#put executable program to gitlab service
push_exe(){
     echo "******************************step: put file******************************"
      /usr/bin/sshpass -p $password  ssh -o StrictHostKeyChecking=no $user@${compiler_ip}<<EOF
      case $module_name in
       "tradingengine")
           cp $remote_path/$module_name/$module_name $te_git_path
            [[ $? == 0 ]] && echo "[info] copy file success!" || exit -1
            ;;
       "signalengine")
            cp $remote_path/$module_name/$module_name $se_git_path
            [[ $? == 0 ]] && echo "[info] copy file success!" || exit -1
            ;;
        *)
            echo "m_name is wrong!"
        ;;
        esac

EOF
}

#upload gitlab
upload_git(){
   echo "******************************step: upload git******************************"
   echo "te_git_path:" $te_git_path
   echo "se_git_path:" $se_git_path

	case $module_name in
   "tradingengine")
        echo "upto" $te_git_path
		./push_git.sh $te_git_path
        ;;
   "signalengine")
        echo "upto" $signalengine
		./push_git.sh $se_git_path
        ;;
    *)
        echo "m_name is wrong!"
    ;;
    esac   
}

main(){
    define_var
    check_variables
    backup_file
    remove_old_module_files
    copy_code_to_compiler
    exec_compiler
    push_exe
    upload_git
}

main

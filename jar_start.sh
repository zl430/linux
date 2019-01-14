#!/bin/bash
#date 2018/12/6
echo -e "\033[31mע���˽ű�����jar����������ֹͣ��������������־��\n    ��Ŀ¼Ϊ/data/gamelog/�£���������ʱ������\033[0m"
date=`date +%Y-%m-%d_%H:%S:%M`
if [ ! -d /data/gamelog/ ];then
   mkdir -p /data/gamelog/
fi
if [ ! -d /usr/newGames/ ];then
     game_dir="/usr/newgames/"
else
     game_dir="/usr/newGames/"
fi
cd
wc_l=`find  $game_dir  -name  cat*.jar |   grep  -v   "lib" | wc -l`
game=`find  $game_dir  -name  cat*.jar |   grep  -v   "lib"`
echo "-------------------------------------------------"
t=0
for i  in $game
do
        t=`expr $t + 1`
        echo "| $t | $i "
        echo "-------------------------------------------------"
done
read -p "����Ҫ����ID:" g_ID
if [ -z "$g_ID" ];then 
   echo "ID����Ϊ��"
   exit 1
elif [ "$g_ID" -gt $t ];then
   echo "������ȷID"
   exit 1
else
   for o in `seq 1 $t`;do
      if [ "$g_ID" -eq "$o" ];then
         package=`echo $game | awk '{print $'$o'}'`
         ps1=`echo "$package" | awk -F\/ '{print $NF}'`
         package_dir=`echo  $package |awk  -F\/ '{$NF="""";print}'|sed 's/ /\//g'`
         cd  $package_dir
      fi
   done
#         ps1=`echo "$package" | awk -F\/ '{print $NF}'`
         ps2=`ps -ef | grep "$ps1" |grep -v "grep"| awk '{print $2}'`
         if [ -n "$ps2" ];then
            echo -e "\033[32m$package ����������PID:$ps2\033[0m"
         else
            echo -e "\033[31m$package ��δ����\033[0m"
         fi
         echo "---------------"
         echo "| 1 |  start  |"
         echo "---------------"
         echo "| 2 |  stop   |"
         echo "---------------"
         echo "| 3 | restart |"
         echo "---------------"
         read -p "��Ҫ����ID:" sta
         if [ "$sta" -eq 1 ];then
            nohup java -jar $package  > /data/gamelog/${ps1}_${date}.log 2>&1 &
            
            new_ps1=`ps -ef | grep "$ps1" |grep -viPa 'grep'| awk '{print $2}'`
            if [ -n "$new_ps1" ];then
                echo -e "\033[32m$package �������ɹ���PID:$new_ps1\033[0m"
            else
                echo -e "\033[31m$package ������ʧ��\033[0m"
            fi
         elif [ "$sta" -eq 2 ];then
            echo $ps2
            kill  -9  $ps2   > /dev/null
            if [ $? -eq 0 ];then
                echo -e "\033[32m$package ��ֹͣ�ɹ�\033[0m"
            else
                kill  -9  $ps2
                if [ $? -eq 0 ];then
                    echo -e "\033[32m$package ��ֹͣ�ɹ�\033[0m"
                else
                    echo -e "\033[31m$package ��ֹͣʧ��\033[0m"
                fi
            fi
         elif [ "$sta" -eq 3 ];then
            kill  -9  $ps2
            nohup java -jar $package > /data/gamelog/${ps1}_${date}.log 2>&1 &
            new_ps2=`ps -ef | grep "$ps1" |grep -v "grep"| awk '{print $2}'`
            if [ -n "$new_ps2" ];then
                if [ "$new_ps2" -ne "$ps2" ];then
                   echo -e "\033[32m$package �������ɹ���PID:$new_ps2\033[0m"
                else
                   echo -e "\033[31m$package ������ʧ��\033[0m"
                fi
            fi
         fi
fi
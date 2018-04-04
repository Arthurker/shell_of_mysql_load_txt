#!/bin/sh
table_data="staff_date_done.txt"
cache_data="/home/CC/staff_date_done_utf8.txt"
cache_table="cache_staff_date_done"
target_table="staff_date_done"
if [ -f ${table_data} ];then
   echo "${table_data} exist"
   old_encoding=$(file -b --mime-encoding ${table_data})
   echo ${old_encoding}
   iconv -f $old_encoding -t utf-8 ${table_data}>${cache_data}
   #判断转码是否成功
   if [ $? -ne 0 ];then
      echo "change fail"
      exit
   else
      echo "change success"
      mysql -ukqx test -e "load data local infile '${cache_data}' into table ${cache_table} character set utf8 ignore 1 lines;"
      #判断加载文件是否成功
      if [ $? -ne 0 ];then
         echo "load fail"
         exit
      else
         echo "load success"
         #rm -rf staff_date_done_utf8.txt
         mysql -ukqx test -e "replace into ${target_table} (id,date,sold) select ${cache_table}.id,${cache_table}.date,${cache_table}.sold from ${cache_table}"
         exit
      fi
   fi
else
   echo "${table_data} not exist"
   exit
fi

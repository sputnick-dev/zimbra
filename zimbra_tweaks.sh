#!/bin/bash

# http://www.sputnick.fr/how-to-use-zimbra-zcs-on-a-small-linux-box-for-a-few-users/
su - zimbra -c /bin/bash<<EOF
host=$(zmhostname)
set -x

zmlocalconfig -e mysql_table_cache=250
zmlocalconfig -e mysql_memory_percent=10
zmlocalconfig -e zmmtaconfig_interval=86400
zmlocalconfig -e mailboxd_java_heap_memory_percent=10
zmlocalconfig -e mailboxd_java_heap_size=200
zmlocalconfig -e mailboxd_java_heap_new_size_percent=5
zmlocalconfig -e tomcat_java_heap_memory_percent=40
zmlocalconfig -e mailboxd_thread_stack_size=256k
zmlocalconfig -e mailboxd_java_options="-server -Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djdk.tls.client.protocols=TLSv1,TLSv1.1,TLSv1.2 -Djava.awt.headless=true -Dsun.net.inetaddr.ttl=${networkaddress_cache_ttl} -Dorg.apache.jasper.compiler.disablejsr199=true -XX:+UseConcMarkSweepGC -XX:PermSize=64m -XX:MaxPermSize=128m -XX:SoftRefLRUPolicyMSPerMB=1 -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCApplicationStoppedTime -XX:-OmitStackTraceInFastThrow -Xloggc:/opt/zimbra/log/gc.log -XX:-UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=4096K -Djava.net.preferIPv4Stack=true"
zmprov -l ms $host -zimbraServiceEnabled amavis
zmprov -l ms $host -zimbraServiceEnabled logger
zmprov -l ms $host -zimbraServiceEnabled antispam
zmprov -l ms $host -zimbraServiceEnabled antivirus
zmprov -l ms $host -zimbraServiceEnabled opendkim
zmprov -l ms $host -zimbraServiceEnabled stats
zmprov -l ms $host zimbraHttpNumThreads 18
zmprov -l ms $host zimbraLmtpNumThreads 2
EOF

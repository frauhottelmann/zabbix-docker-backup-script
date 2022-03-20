### Name of backup files
fileNameBackupDataDir="zabbix-datadir.tar.gz"
fileNameBackupEnvDir="zabbix-envdir.tar.gz"
fileNameBackupDb="zabbix-db.sql"

### Read date
currentDate=$(date +"%Y%m%d_%H%M%S")

#
# Please change configuration to match your system
#

# Deletes backups older than x days
backupage="14"

# Backup dir
backupMainDir="/home/user/backup/"
backupdir="${backupMainDir}/${currentDate}/"

# Zabbix data dir
zabbixDataDir="/export/docker/config/zabbix/zbx_env"

# Compose path
zabbixComposeFile="/export/docker/config/zabbix/docker-compose.yml"

# Zabbix ENV-files dir
zabbixEnvDir="/export/docker/config/zabbix/env_vars"

# Name of Zabbix database
zabbixDatabase="zabbix"

# Name of Zabbix database user
dbUser="zabbix"

# Password of Zabbix database user
dbPassword="password"

# Name of Zabbix database container
dockerdb="zabbix-mysql"


##### End of Configuration ######

#
# Date
#
echo
echo Backup of $currentDate
echo

#
# Check for root
#
if [ "$(id -u)" != "0" ]
then
        errorecho "ERROR: This script has to be run as root!"
        exit 1
fi

#
# Check if backup dir already exists
#
if [ ! -d "${backupdir}" ]
then
        mkdir -p "${backupdir}"
else
        errorecho "ERROR: The backup directory ${backupdir} already exists!"
        exit 1
fi

#
# Backup file and data directory
#

echo "Creating Zabbix data backup"
tar -cpzf "${backupdir}/${fileNameBackupDataDir}"  -C "${zabbixDataDir}" .
echo "Status: OK"
echo

echo "Creating backup of compose file"
cp "${zabbixComposeFile}" "${backupdir}"
echo "Status: OK"
echo

echo "Creating backup of ENV files"
tar -cpzf "${backupdir}/${fileNameBackupEnvDir}"  -C "${zabbixEnvDir}" .
echo "Status: OK"
echo

#
# Backup DB
#
echo "Creating backup of Zabbix database"
docker exec "${dockerdb}" mysqldump --ignore-table=zabbix.history --ignore-table=zabbix.history_uint --ignore-table=zabbix.trends --ignore-table=zabbix.trends_uint -u "${dbUser}"  -p"${dbPassword}" "${zabbixDatabase}" | gzip -c > "${backupdir}/${fileNameBackupDb}"
echo "Status: OK"
echo


#
# Delete old Files
#
echo "Deleting files older than" "${backupage}" "days"
find "${backupMainDir}" -type f -mtime +"${backupage}" -delete
echo "Deleting empty folders"
find "${backupMainDir}" -type d -empty -delete

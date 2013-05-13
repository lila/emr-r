# Makefile for EMR-R
#
# sample EMR project that uses R for data analysis
#
# run 
# % make
# to get the list of options.

# commands setup (ADJUST THESE IF NEEDED)
# 
S3CMD                   = s3cmd
EMR			= elastic-mapreduce
CLUSTERSIZE		= 2
REGION                  = us-east
KEY			= normal
KEYPATH			= ${HOME}/.ssh/normal.pem
BUCKET			= ${USER}.r.emr


# 
# make targets 
#

help:
	@echo "help for Makefile for SimpleEMR sample project"
	@echo "make bootstrap	     - create a new s3 bucket and copy the data and scripts to s3"
	@echo "make create           - create an EMR Cluster with default settings (2 x c1.medium)"
	@echo "make destroy          - clean up everything (terminate cluster and remove s3 bucket)"
	@echo "make submitjob        - submit a job to the cluster with default settings"
	@echo "make logs             - show the stdout of job"
	@echo "make ssh              - log into head node of cluster"

#
# push data into s3 
#
bootstrap: 
	-${S3CMD} mb s3://$(BUCKET)/
	${S3CMD} sync --acl-public ./config s3://${BUCKET}/
	${S3CMD} sync --acl-public ./r s3://${BUCKET}/
	${S3CMD} sync --acl-public ./data s3://${BUCKET}/

#
# top level target for removing all derived data
#
clean: cleanbootstrap
	@echo "removed all unnecessary files"

#
# removes all data copied to s3
#
cleanbootstrap:
	-${S3CMD} -r rb s3://$(BUCKET)/

#
# top level target to tear down cluster and cleanup everything
#
destroy: cleanbootstrap
	@ echo deleting server stack simple.emr
	-${EMR} -j `cat ./jobflowid` --terminate
	rm ./jobflowid

#
# top level target to create a new cluster of c1.mediums
#
create: 
	@ if [ -a ./jobflowid ]; then echo "jobflowid exists! exiting"; exit 1; fi
	@ echo creating EMR cluster
	${EMR} --create --alive --name "$(USER)'s R Cluster" \
	--num-instances ${CLUSTERSIZE} \
	--bootstrap-action s3://${BUCKET}/config/config-r.sh \
	--instance-type c1.medium | cut -d " " -f 4 > ./jobflowid

submitjob: 
	${EMR} -j `cat ./jobflowid` --jar /home/hadoop/contrib/streaming/hadoop-streaming.jar \
	--arg -Dmapred.max.split.size=1000000 --arg -Dmapred.min.split.size=1000000 \
	--arg -input --arg s3://${BUCKET}/data/nips_05102013.txt \
	--arg -output --arg s3://${BUCKET}/output \
	--arg -mapper --arg s3://${BUCKET}/r/sample.r \
	--arg -reducer --arg s3://${BUCKET}/r/sampleReduce.r

#
# logs:  use this to see output of jobs
#

logs: 
	${EMR} -j `cat ./jobflowid` --logs

#
# ssh: quick wrapper to ssh into the master node of the cluster that sets up the ssh proxy
#
ssh:
	j=`cat ./jobflowid`; h=`${EMR} --describe -j $$j | grep "MasterPublicDnsName" | cut -d "\"" -f 4`; echo "h=$$h"; if [ -z "$$h" ]; then echo "master not provisioned"; exit 1; fi
	j=`cat ./jobflowid`; h=`${EMR} --describe $$j | grep "MasterPublicDnsName" | cut -d "\"" -f 4`; ssh -L 9100:localhost:9100 -i ${KEYPATH} hadoop@$$h


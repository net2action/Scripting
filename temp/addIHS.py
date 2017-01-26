# License Header Section #
#
# To invoke the script, type:
#   wsadmin -f addIHS.py <node_name>
#      node_name      - Name of the node, i.e. hostnameNode01
#
# Example:
#   wsadmin -f addIHS.py hostnameNode01 
#
#--------------------------------------------------------------------
from time import sleep
MAX_ITERATIONS = 10
SLEEP_SYNC_FEDERATE = 25

#---------------------------------------------
# Check/Print Usage
#---------------------------------------------
def printUsageAndExit (  ):
        print " "
        print "Usage: wsadmin -f addIHS.py <node_name> <hostName> <ihsHome> <plgHome> <whvUser> <whvPassword>"
        sys.exit()
#endDef

#---------------------------------------------
# Parse command line arguments
#---------------------------------------------
if (len(sys.argv) < 6):
        printUsageAndExit( )
else:
        #parse the parameters from command line
        nodeName = sys.argv[0];
        hostName = sys.argv[1];
        ihsHome = sys.argv[2];
        plgHome = sys.argv[3];
        whvUser = sys.argv[4];
        whvPassword = sys.argv[5];
        #print all values
        print "Node:       "+`nodeName`
        print "Host:       "+`hostName`
        print "ihsHome:    "+`ihsHome`
        print "plgHome:    "+`plgHome`
        print "whvUser:    "+`whvUser`
        print "whvPassword: *******"
#endElse

i = 0
while i < MAX_ITERATIONS:
        try:
                print "Adding IHS attempt ",i," ..."
                AdminTask.createUnmanagedNode('[-nodeName '+nodeName+' -hostName '+hostName+' -nodeOperatingSystem linux ]')
                AdminTask.createWebServer( nodeName, '[-name webserver1 -templateName IHS -serverConfig [[80 '+ihsHome+' '+plgHome+' '+ihsHome+'/conf/httpd.conf windows_service '+ihsHome+'/logs/error_log '+ihsHome+'/logs/access_log  http]] -remoteServerConfig [[8008 '+whvUser+' '+whvPassword+' http]]]')
                print "Saving config ..."
                AdminConfig.save()
                break
        except NameError:
                print "WARNING: NameError"
                i = MAX_ITERATIONS
                break
        except:
                print "WARNING:", sys.exc_info()[0], sys.exc_info()[1], sys.exc_info()[2]
                try:
                        AdminConfig.reset()
                except:
                        print "Cannot reset"
                print "Failed to federate IHS, delaying ",SLEEP_SYNC_FEDERATE," to retry ..."
                sleep(SLEEP_SYNC_FEDERATE)
                i = i + 1

if i < MAX_ITERATIONS:
        print "Done (success) rc=0"
        sys.exit(0)
else:
        print "WARNING: (failed) rc=1"
        sys.exit(1)



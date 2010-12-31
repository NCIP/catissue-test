# Search for the jboss process for the caTissue Nightly Build for BO Automation test script execution
$grep = `ps -ef | grep "jboss-4.2.2.G*" | grep -v grep | awk '{print $2}'`;

print "$grep\n";

# Split the string for process
@taskid = split(' ',$grep);

# Print the Process Id
print "$taskid[1]";

# Kill the Process

$kill = `kill -9 $taskid[1]`;


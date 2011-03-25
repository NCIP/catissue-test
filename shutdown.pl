# Search for the jboss process for the caTissue Nightly Build for BO Automation test script execution
$grep = `ps -ef | grep "jboss" | grep -v grep | awk '{print $2}'`;

print "$grep\n";

@tasklist = split('\n',$grep);
#print "$tasklist[0]\n";
#print "$tasklist[1]\n";
print "_________________________________________________________";
foreach $value (@tasklist)
{
# Split the string for process
#print "$value\n";
@taskid = split(' ',$value);

# Print the Process Id
print "$taskid[1]\n";
$kill = `kill -9 $taskid[1]`;
print "#############";
}
# Split the string for process
#@taskid = split(' ',$grep);

# Print the Process Id
#print "$taskid[1]";

# Kill the Process

#$kill = `kill -9 $taskid[1]`;

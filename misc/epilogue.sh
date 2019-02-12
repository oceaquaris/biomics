#!/bin/bash

echo "Param\tDesc\tValue\n" \
     "\$1\tJob ID\t$1\n" \
     "\$2\tUser Name\t$2\n" \
     "\$3\tGroup Name\t$3\n" \
     "\$4\tJob Name\t$4\n" \
     "\$5\tSession ID\t$5\n" \
     "\$6\tResources Requested\t$6\n" \
     "\$7\tResources Used\t$7\n" \
     "\$8\tQueue\t$8\n" \
     "\$9\tJob Account\t$9\n" \
     "\$10\tJob exit status\t${10}" >&1

# Exit the script
exit 0

# le9 Unofficial

**Working Set Protection Compatible with Traditional LRU and Multi-Gen LRU (a.k.a. lru_gen)**  

## How it works

![alt le9uo illustrated](https://raw.githubusercontent.com/firelzrd/le9uo/main/le9uo-illustrated.png)

This feature benefits in three key scenarios:  

1. **During Physical Memory Exhaustion**  
   While the memory manager evicts the oldest pages from the page LRU list to swap devices, le9uo preserves a certain amount of page cache, preventing excessive page faults and maintaining system responsiveness.  
   In an experiment (demonstrated below), file access performance showed an approximate +3700% improvement (38 times faster) under continuous memory pressure compared to the vanilla kernel.

2. **Near Out-of-Memory Conditions**  
   When virtual memory is fully utilized and no space remains in the system requiring process termination, le9uo enables immediate detection of this state and instantly invokes the OOM Killer to recover from the critical situation. This prevents thrashing or prolonged live-locking, ensuring stable and smooth system operation during such events.  
   As shown in the following YouTube demo video, in best cases, recovery occurs with faster than a blink of negligible delay, and users may not even notice when the OOM Killer has acted.  
   In contrast, the vanilla kernel may experience severe issues under these conditions, including extreme slowdowns, system unstability, prolonged system unresponsiveness, or even complete failure to respond indefinitely.

3. **After Out-of-Memory Conditions**  
   Even immediately after an OOM event, the system continues operating smoothly because le9uo has protected a portion of the page cache in memory, preventing the need to reload it from storage.  

In summary, le9uo significantly mitigates performance and stability issues caused by severe memory pressure.

## Demo

https://youtu.be/z12b4e-vSVw

le9uo's positive effect is so obvious to see by running the following 3 continuous workers at the same time:
- `$ while true; do tail /dev/zero; done` to impose continuous memory stress
- `$ cat /path/to/some_huge_file > /dev/null` to fill and rotate file cache LRU
- `$ while true; do time cat /path/to/some_moderately_large_file > /dev/null; sleep $(($(cat /sys/kernel/mm/lru_gen/min_ttl_ms)/1000+1)); done` to measure file access time

Results:
```
vm.workingset_protection=1
real	0m0.135s
real	0m0.136s
real	0m0.141s
real	0m0.849s
real	0m0.403s
real	0m1.374s
real	0m0.209s
real	0m0.214s
real	0m0.143s
real	0m0.145s
real	0m0.141s
real	0m0.147s
real	0m0.145s
real	0m0.915s
real	0m0.237s

vm.workingset_protection=0
real	0m5.248s
real	0m5.361s
real	0m5.249s
real	0m5.520s
real	0m5.332s
real	0m6.152s
real	0m5.229s
real	0m5.787s
```
![access-latencies](https://github.com/user-attachments/assets/69f5d9e2-43f4-4024-9c7d-44a3165ca80c)

In this specific test case, it shows approximately +3700% improvement in file access performance.

## Forked from

https://github.com/hakavlad/le9-patch

## Tunables

### Example
`$ sudo sysctl -w vm.workingset_protection=1`

### workingset_protection (range: 0 - 1, default: 0)

1 Enables le9uo.  
0 Disables le9uo.

### anon_min_ratio (range: 0 - 100, default: 15)

How much in percentile of total physical memory to preserve for HARD protection of anonymous pages.

### clean_min_ratio (range: 0 - 100, default: 15)

How much in percentile of total physical memory to preserve for HARD protection of clean file pages.

### clean_low_ratio (range: 0 - 100, default: 0)

How much in percentile of total physical memory to preserve for SOFT protection of clean file pages.

## See Also: Re-swappiness

A companion patch that fixes MGLRU's broken `vm.swappiness` behavior. Combined with le9uo, it provides full working set protection with proper `swappiness` control on MGLRU-enabled kernels.

https://github.com/firelzrd/re-swappiness

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y5NHO2I)


# le9 Unofficial

Working set protection that is compatible with both the traditional LRU and the Multi-Gen LRU (a.k.a. lru_gen)

## How it works

![alt Without le9uo](https://raw.githubusercontent.com/firelzrd/le9uo/main/without-le9uo.png)
![alt With le9uo](https://raw.githubusercontent.com/firelzrd/le9uo/main/with-le9uo.png)  

## Demo

https://youtu.be/FaEc5AeJEAU

le9uo's positive effect is so obvious to see by running the following 3 continuous workers at the same time:
- `$ while true; do tail /dev/zero; done` to impose continuous memory stress
- `$ cat /path/to/some_huge_file > /dev/null` to fill and rotate file cache LRU
- `$ while true; do time cat /path/to/some_moderately_large_file > /dev/null; sleep $(($(cat /sys/kernel/mm/lru_gen/min_ttl_ms)/1000)); done` to measure file access time

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

## Forked from

https://github.com/hakavlad/le9-patch

## Multi-Gen LRU compatibility
le9uo 1.3 and above comes with a long-waited **Multi-Gen LRU** (MGLRU, or lru_gen) compatibility.
It comes with the working set protection features like it has to the traditional LRU.

Please be aware that there is an MGLRU-specific limitation.
At the latest Linux kernel (version 6.7.5 at the time this is written), Multi-gen LRU lacks the ability to comply with the `vm.swappiness` sysctl knob like it was initially designed.
Almost regardless of what value is put in `vm.swappiness` (as long as greater than 0), it seems to evict whatever it finds first.
This behavior is coming from MGLRU's page-scanner design/implementation, and it causes to start to thrash much earlier and easier than the traditional LRU.
MGLRU does rather temporal approach called `min_ttl`, but this design has another problem; it's much more difficult to estimate each system's optimal effective value than traditional LRU + le9's spacial approach, and when the value is out of the effective range, it easily results either in too early invocation of OOM killer, or thrashing.

le9uo does not fix this issue, but greatly mitigates it so that these limitations due to MGLRU's design/implementation isn't a problem anymore.

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


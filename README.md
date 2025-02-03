# le9 Unofficial

Working set protection that is compatible with both the traditional LRU and the Multi-Gen LRU (a.k.a. lru_gen)

## How it works

![alt le9uo illustrated](https://raw.githubusercontent.com/firelzrd/le9uo/main/le9uo-illustrated.png)

## Demo

https://youtu.be/jammtrHNeKM

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

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y5NHO2I)


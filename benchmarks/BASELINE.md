# Benchmark baseline

Recorded `2026-10-13` while completing the modernization TODOs. Numbers are
indicative only: they come from a containerized dev machine and will vary with
hardware, Ruby build, and load. Re-run locally before drawing conclusions.

## Environment

| | |
|---|---|
| Ruby | 3.4.9 (2026-03-11) `+PRISM` |
| Rack | 3.x |
| benchmark-ips | 2.15.x |
| CPU | x86_64-linux (container) |

## Running

```sh
bundle exec rake bench                              # whole suite
bundle exec ruby -Ilib benchmarks/bench_app.rb      # app-level
bundle exec ruby -Ilib benchmarks/bench_routing.rb  # router-level
bundle exec rackup benchmarks/bench_rack.ru         # serve for ab/wrk
```

## Optimizations shipped

### 1. Single-pass recognizer (`lib/eldr/recognizer.rb`)

The old matcher built the route list with `reject`, then sorted. The new one
walks the verb's routes once, appends matches, and only sorts when more than one
route matched.

| Benchmark (params route) | Before | After | Change |
|---|---:|---:|---:|
| `Recognizer#call` | 340.3k i/s (2.94 µs) | 406.3k i/s (2.46 µs) | ~1.19× faster (−16%) |

### 2. Skip matching for literal paths (`lib/eldr/matcher.rb`)

`Matcher#params` now returns `{}` immediately when the pattern has no named
captures (plain literal paths such as `/static`), instead of re-running
Mustermann. Parameterized patterns are unchanged.

| Benchmark | Before | After | Change |
|---|---:|---:|---:|
| `app#call!` (static route) | 172.5k i/s (5.80 µs) | 200.9k i/s (4.98 µs) | ~1.16× faster (−14%) |
| `App.call` class method (static) | 155.4k i/s (6.44 µs) | 177.8k i/s (5.62 µs) | ~1.14× faster (−13%) |
| `built app.call` (static) | 168.0k i/s (5.95 µs) | 195.6k i/s (5.11 µs) | ~1.16× faster (−14%) |
| `app#call!` (params + query) | 114.2k i/s (8.76 µs) | 115.4k i/s (8.67 µs) | unchanged (noise) |

## Not optimized (deliberately)

Reusing the `MatchData` from routing for `params` extraction would avoid a
second Mustermann traversal on parameterized routes (~0.5 µs/request, ~6% on
the params benchmark). It requires stashing per-request match data on the
thread-safe `env`, touching `Recognizer`, `Route`, `Matcher`, and `App#call!`.
Given the strict 100% branch-coverage gate and the modest payoff, it is left as
future work (see `.ai/plans/TODOsFinishModernize.org`, Phase 2).

## Reference micro-benchmarks (single-run, not part of the suite)

| Call | Time |
|---|---:|
| `App.call` | ~5.7 µs |
| `app#call!` | ~3.0 µs |
| `Recognizer#call` (3 routes) | ~1.3 µs |
| `Builder#to_app` | ~0.19 µs |
| `Route#match` | ~0.48 µs |
| `Route#params` (params route) | ~2.0 µs |
| `Rack::Request#params` | ~0.27 µs |

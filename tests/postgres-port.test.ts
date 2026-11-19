// Regression check: install.sh moves postgresql@18 to port 54320 once, and
// restarts the service only when it changes the config. Runs the real step from
// install.sh against a temp config, with `brew` stubbed.
// Run: node --test tests/postgres-port.test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync, existsSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, join, dirname } from 'node:path';
import { spawnSync } from 'node:child_process';

const installer = readFileSync(resolve(import.meta.dirname, '../install.sh'), 'utf8');
const step = installer.match(/^# Piumosso's worktrees share[\s\S]*?^fi$/m)?.[0];

test('install moves postgresql@18 to port 54320 once', () => {
  assert.ok(step, 'installer has a testable Postgres port step');
  const tmp = mkdtempSync(join(tmpdir(), 'postgres-port-'));
  try {
    const conf = join(tmp, 'var/postgresql@18/postgresql.conf');
    const calls = join(tmp, 'brew-calls');
    const brewCalls = () => (existsSync(calls) ? readFileSync(calls, 'utf8') : '');
    // The stub reports the temp dir as Homebrew's prefix and logs any other call.
    // It must be a function: ~/.zshenv puts the real brew first on PATH, so a
    // PATH stub loses and the step would edit the machine's real config.
    const stub = 'brew() { if [[ "$1" == --prefix ]]; then print -r -- "$STUB_PREFIX"; else print -r -- "$*" >> "$STUB_CALLS"; fi }';
    const run = () => {
      const script = `set -euo pipefail; ${stub}; CHANGED=(); WARNINGS=()\n${step}\nprint -r -- "changed=$#CHANGED warnings=$#WARNINGS"`;
      const result = spawnSync('zsh', ['-f', '-c', script], {
        env: { ...process.env, HOME: tmp, STUB_PREFIX: tmp, STUB_CALLS: calls }, encoding: 'utf8',
      });
      assert.equal(result.status, 0, result.stderr);
      return result.stdout.trim().split('\n').at(-1);
    };

    assert.equal(run(), 'changed=0 warnings=1', 'a missing config is a warning');
    assert.ok(!existsSync(conf), 'a missing config is not created');
    assert.equal(brewCalls(), '');

    mkdirSync(dirname(conf), { recursive: true });
    // No trailing newline: the setting must still land on its own line.
    writeFileSync(conf, '#port = 5432\t\t\t\t# (change requires restart)\nmax_connections = 100');
    assert.equal(run(), 'changed=1 warnings=0');
    const moved = readFileSync(conf, 'utf8');
    assert.deepEqual(moved.split('\n').filter(line => line.includes('54320')), ['port = 54320']);
    assert.ok(moved.includes('max_connections = 100\n'), 'existing settings are kept intact');
    assert.equal(brewCalls(), 'services restart postgresql@18\n');

    assert.equal(run(), 'changed=0 warnings=0');
    assert.equal(readFileSync(conf, 'utf8'), moved, 'a second run leaves the config alone');
    assert.equal(brewCalls(), 'services restart postgresql@18\n', 'a second run does not restart');
  } finally {
    rmSync(tmp, { recursive: true, force: true });
  }
});

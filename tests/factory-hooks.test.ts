import { test } from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, join, dirname } from 'node:path';
import { spawnSync } from 'node:child_process';

const root = resolve(import.meta.dirname, '..');
const installer = readFileSync(join(root, 'install.sh'), 'utf8');

test('install merges one factory hook, preserving existing Codex entries', () => {
  const home = mkdtempSync(join(tmpdir(), 'factory-hooks-'));
  try {
    mkdirSync(join(home, '.codex'));
    const file = join(home, '.codex/hooks.json');
    const orca = { matcher: 'startup', hooks: [{ type: 'command', command: 'orca-original', timeout: 10 }] };
    const settings = JSON.parse(readFileSync(join(root, 'agents/claude/settings.json'), 'utf8'));
    const unnamed = settings.hooks.SessionStart.find(entry => entry.hooks.some(hook => hook.command.includes('check-skills.ts')));
    delete unnamed.hooks[0].statusMessage;
    const existing = { extra: 'keep', hooks: { SessionStart: [orca, unnamed], Stop: [orca] } };
    writeFileSync(file, JSON.stringify(existing));
    const step = installer.match(/^# Factory skills hook\n([\s\S]*?)^# End factory skills hook/m)?.[1];
    assert.ok(step, 'installer has a testable factory hook step');
    const run = () => {
      const result = spawnSync('zsh', ['-c', 'CHANGED=(); WARNINGS=(); ' + step], {
        env: { ...process.env, HOME: home, DOTFILES_DIR: root }, encoding: 'utf8',
      });
      assert.equal(result.status, 0, result.stderr);
    };
    run();
    const first = readFileSync(file, 'utf8');
    run();
    assert.equal(readFileSync(file, 'utf8'), first);
    const result = JSON.parse(first);
    assert.equal(result.hooks.SessionStart.length, 2);
    assert.equal(result.hooks.SessionStart[1].hooks[0].statusMessage, 'Checking Factory skills');
    assert.deepEqual(result.hooks.SessionStart[0], orca);
    assert.deepEqual(result.hooks.Stop, [orca]);
    assert.equal(result.extra, 'keep');
    assert.match(result.hooks.SessionStart[1].hooks[0].command, /check-skills\.ts/);
  } finally { rmSync(home, { recursive: true, force: true }); }
});

test('hook displays stale skills as JSON and stays silent for current or unavailable skills', () => {
  const home = mkdtempSync(join(tmpdir(), 'factory-output-'));
  try {
    const skill = join(home, '.agents/skills/do-factory-setup');
    mkdirSync(skill, { recursive: true });
    const checker = join(skill, 'check-skills.ts');
    // A fixture at the external checker boundary; the checker itself lives in Factory.
    writeFileSync(checker, 'console.log("Out of date: do-refine. Run: npx skills update -g -y do-refine")');
    const settings = JSON.parse(readFileSync(join(root, 'agents/claude/settings.json'), 'utf8'));
    const command = settings.hooks.SessionStart.flatMap(entry => entry.hooks)
      .find(hook => hook.command.includes('/do-factory-setup/check-skills.ts')).command;
    const run = (path = process.env.PATH) => {
      const result = spawnSync('/bin/sh', ['-c', command], {
        env: { ...process.env, HOME: home, ZDOTDIR: home, PATH: path }, encoding: 'utf8', timeout: 6000,
      });
      assert.equal(result.status, 0, result.stderr);
      assert.equal(result.stderr, '');
      return result.stdout;
    };
    // Mirror nvm exposing Node while the launcher supplies only system paths.
    writeFileSync(join(home, '.zshenv'), `export PATH="${dirname(process.execPath)}:$PATH"\n`);
    assert.deepEqual(JSON.parse(run('/usr/bin:/bin')), { systemMessage: 'Out of date: do-refine. Run: npx skills update -g -y do-refine' });
    assert.deepEqual(JSON.parse(run()), { systemMessage: 'Out of date: do-refine. Run: npx skills update -g -y do-refine' });
    writeFileSync(checker, '');
    assert.equal(run(), '');
    writeFileSync(checker, 'throw new Error("unavailable")');
    assert.equal(run(), '');
    rmSync(join(home, '.zshenv'));
    assert.equal(run('/usr/bin:/bin'), '');
    rmSync(checker);
    assert.equal(run(), '');
  } finally { rmSync(home, { recursive: true, force: true }); }
});

test('Claude filter retains factory hook and restores Orca hooks without committing them', () => {
  const home = mkdtempSync(join(tmpdir(), 'factory-filter-'));
  try {
    const settings = JSON.parse(readFileSync(join(root, 'agents/claude/settings.json'), 'utf8'));
    const factory = settings.hooks.SessionStart.find(entry => entry.hooks.some(hook => hook.command.includes('check-skills.ts')));
    const orca = { hooks: [{ type: 'command', command: '~/.orca/agent-hooks/claude-hook.sh' }] };
    settings.hooks.SessionStart.push(orca);
    const filter = (mode, input) => {
      const result = spawnSync('sh', [join(root, 'agents/claude/settings-filter.sh'), mode], {
        input: JSON.stringify(input), encoding: 'utf8',
        env: { ...process.env, CLAUDE_SETTINGS_PRIVATE_FILE: join(home, 'private.json') },
      });
      assert.equal(result.status, 0, result.stderr);
      return JSON.parse(result.stdout);
    };
    const clean = filter('clean', settings);
    assert.deepEqual(clean.hooks.SessionStart, [factory]);
    assert.deepEqual(filter('smudge', clean).hooks.SessionStart, [factory, ...settings.hooks.SessionStart.filter(e => e !== factory)]);
  } finally { rmSync(home, { recursive: true, force: true }); }
});
